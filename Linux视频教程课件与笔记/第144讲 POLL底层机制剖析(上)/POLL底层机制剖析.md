## POLL底层机制剖析

#### 系统调用接口sys_poll

fs/select.c

```
SYSCALL_DEFINE3(poll, struct pollfd __user *, ufds, unsigned int, nfds,int, timeout_msecs)
{
	struct timespec64 end_time, *to = NULL;
	int ret;

	if (timeout_msecs >= 0) {
		to = &end_time;
		poll_select_set_timeout(to, timeout_msecs / MSEC_PER_SEC,
			NSEC_PER_MSEC * (timeout_msecs % MSEC_PER_SEC));
	}

	ret = do_sys_poll(ufds, nfds, to);
	...
	return ret;
}
```

#### SYSCALL_DEFINE3()宏

```
#define SYSCALL_DEFINE3(name, ...) SYSCALL_DEFINEx(3, _##name, __VA_ARGS__)
```

#### SYSCALL_DEFINEx()宏

```
#define SYSCALL_DEFINEx(x, sname, ...)				\
	SYSCALL_METADATA(sname, x, __VA_ARGS__)			\
	__SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
```

#### __SYSCALL_DEFINEx()宏

```
#ifndef __SYSCALL_DEFINEx
#define __SYSCALL_DEFINEx(x, name, ...)					\
	
	asmlinkage long sys##name(__MAP(x,__SC_DECL,__VA_ARGS__))	\
		__attribute__((alias(__stringify(__se_sys##name))));	\
	...
#endif /* __SYSCALL_DEFINEx */
```



#### timespec64结构体

include/linux/time64.h

```
struct timespec64 {
	time64_t	tv_sec;			/* seconds */
	long		tv_nsec;		/* nanoseconds */
};
```



#### do_sys_poll()函数

fs/select.c

- 复制用户空间pollfd数组到内核空间
  - 分配静态数组内存(一个poll_list结构体）
  - 动态分配内存（一组poll_list结构体）
- 调用do_poll函数
- 返回修改后的pollfd数组到用户空间
  - 主要是返回修改后revents值

```
static int do_sys_poll(struct pollfd __user *ufds, unsigned int nfds,struct timespec64 *end_time)
{
	struct poll_wqueues table;
 	int err = -EFAULT, fdcount, len, size;
 	long stack_pps[POLL_STACK_ALLOC/sizeof(long)];
	struct poll_list *const head = (struct poll_list *)stack_pps;
 	struct poll_list *walk = head;
 	unsigned long todo = nfds;
 	...
 	//获取静态分配的数组大小
 	len = min_t(unsigned int, nfds, N_STACK_PPS);
	for (;;) {
		walk->next = NULL;
		walk->len = len;
		if (!len)
			break;

		if (copy_from_user(walk->entries, ufds + nfds-todo,
					sizeof(struct pollfd) * walk->len))
			goto out_fds;

		todo -= walk->len;
		if (!todo)
			break;
		//计算剩下的文件描述符所需空间大小，最大为一个页
		len = min(todo, POLLFD_PER_PAGE);
		size = sizeof(struct poll_list) + sizeof(struct pollfd) * len;
		walk = walk->next = kmalloc(size, GFP_KERNEL);
		if (!walk) {
			err = -ENOMEM;
			goto out_fds;
		}
	}
 	
 	poll_initwait(&table);
	fdcount = do_poll(head, &table, end_time);
	poll_freewait(&table);

	for (walk = head; walk; walk = walk->next) {
		struct pollfd *fds = walk->entries;
		int j;

		for (j = 0; j < walk->len; j++, ufds++)
			if (__put_user(fds[j].revents, &ufds->revents))
				goto out_fds;
  	}
	...
}
```

##### 相关宏定义

```
#define FRONTEND_STACK_ALLOC	256
#define POLL_STACK_ALLOC	FRONTEND_STACK_ALLOC
#define N_STACK_PPS ((sizeof(stack_pps) - sizeof(struct poll_list))  / \
			sizeof(struct pollfd))
```



#### poll_initwait()函数

fs/select.c

```
void poll_initwait(struct poll_wqueues *pwq)
{
	init_poll_funcptr(&pwq->pt, __pollwait);
	...
}
```



#### init_poll_funcptr()函数

include/linux/poll.h

```
static inline void init_poll_funcptr(poll_table *pt, poll_queue_proc qproc)
{
	pt->_qproc = qproc;
	pt->_key   = ~(__poll_t)0; /* all events enabled */
}
```



#### __pollwait()函数

fs/select.c

```
static void __pollwait(struct file *filp, wait_queue_head_t *wait_address,
				poll_table *p)
{
	struct poll_wqueues *pwq = container_of(p, struct poll_wqueues,pt);
	struct poll_table_entry *entry = poll_get_entry(pwq);
	if (!entry)
		return;
	entry->filp = get_file(filp);
	entry->wait_address = wait_address;
	entry->key = p->_key;
	init_waitqueue_func_entry(&entry->wait, pollwake);
	entry->wait.private = pwq;
	add_wait_queue(wait_address, &entry->wait);
}
```



#### poll_get_entry()函数

fs/select.c

```
static struct poll_table_entry *poll_get_entry(struct poll_wqueues *p)
{
	struct poll_table_page *table = p->table;

	if (p->inline_index < N_INLINE_POLL_ENTRIES)
		return p->inline_entries + p->inline_index++;

	if (!table || POLL_TABLE_FULL(table)) {
		struct poll_table_page *new_table;

		new_table = (struct poll_table_page *) __get_free_page(GFP_KERNEL);
		if (!new_table) {
			p->error = -ENOMEM;
			return NULL;
		}
		new_table->entry = new_table->entries;
		new_table->next = table;
		p->table = new_table;
		table = new_table;
	}

	return table->entry++;
}
```



#### do_poll()函数

fs/select.c

- 第一重for：确保线程/进程被唤醒后，继续执行一次循环体内容
- 第二重for：遍历一组poll_list
- 第二重for：遍历每个poll_list中的一组pollfd

```
static int do_poll(struct poll_list *list, struct poll_wqueues *wait,
		   struct timespec64 *end_time)
{
	poll_table* pt = &wait->pt;
	ktime_t expire, *to = NULL;
	int timed_out = 0, count = 0;
	u64 slack = 0;
	__poll_t busy_flag = net_busy_loop_on() ? POLL_BUSY_LOOP : 0;
	unsigned long busy_start = 0;
	...
	for (;;) {
		struct poll_list *walk;
		bool can_busy_loop = false;

		for (walk = list; walk != NULL; walk = walk->next) {
			struct pollfd * pfd, * pfd_end;

			pfd = walk->entries;
			pfd_end = pfd + walk->len;
			for (; pfd != pfd_end; pfd++) {
				if (do_pollfd(pfd, pt, &can_busy_loop,
					      busy_flag)) {
					count++;
					pt->_qproc = NULL;
					/* found something, stop busy polling */
					busy_flag = 0;
					can_busy_loop = false;
				}
			}
		}
		pt->_qproc = NULL;
		if (!count) {
			count = wait->error;
			//检查是否有信号处理
			if (signal_pending(current))
				count = -EINTR;
		}
		if (count || timed_out)
			break;
		...
		if (!poll_schedule_timeout(wait, TASK_INTERRUPTIBLE, to, slack))
			timed_out = 1;
	}
	return count;
}
```



#### do_pollfd()函数

fs/select.c

```
static inline __poll_t do_pollfd(struct pollfd *pollfd, poll_table *pwait,
				     bool *can_busy_poll,
				     __poll_t busy_flag)
{
	int fd = pollfd->fd;
	__poll_t mask = 0, filter;
	struct fd f;

	if (fd < 0)
		goto out;
	...
	mask = vfs_poll(f.file, pwait);
	...
}
```



#### vfs_poll()函数

include/linux/poll.h

```
tatic inline __poll_t vfs_poll(struct file *file, struct poll_table_struct *pt)
{
	if (unlikely(!file->f_op->poll))
		return DEFAULT_POLLMASK;
	return file->f_op->poll(file, pt);
}
```



#### 驱动层poll底层接口

include/linux/fs.h

```
__poll_t (*poll) (struct file *, struct poll_table_struct *);
```

参数：

- filp ：要打开的设备文件
- wait ：结构体 poll_table_struct 类型指针

返回值：

- 文件可用事件类型



##### poll驱动模板

```
static __poll_t xxx_poll(struct file *filp, struct poll_table_struct *wait)
{
	unsigned int mask = 0;

	poll_wait(filp, &yyy, wait);

	if(...)
	{
		mask |= POLLOUT | ...;
	}
	return mask;
}
```



#### poll_wait()函数

include/linux/poll.h

```
static inline void poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
{
	if (p && p->_qproc && wait_address)
		p->_qproc(filp, wait_address, p);
}
```

