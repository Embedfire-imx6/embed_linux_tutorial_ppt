## 设备驱动的阻塞IO：等待队列

请求数据没有准备好时，让该进程睡眠直到数据准备好为止

#### 等待队列头

 include/linux/wait.h

```
struct wait_queue_head {
	spinlock_t		lock;
	struct list_head	head;
};
typedef struct wait_queue_head wait_queue_head_t;
```

#### 初始化等待队列头

##### init_waitqueue_head()

 include/linux/wait.h

```
#define init_waitqueue_head(wq_head)						\
	do {									\
		static struct lock_class_key __key;				\
										\
		__init_waitqueue_head((wq_head), #wq_head, &__key);		\
	} while (0)

```

##### 静态定义并初始化

```
#define DECLARE_WAIT_QUEUE_HEAD(name) \
	struct wait_queue_head name = __WAIT_QUEUE_HEAD_INITIALIZER(name)
```

#### 等待队列元素

 include/linux/wait.h

```
struct wait_queue_entry {
	unsigned int		flags;
	void			*private;
	wait_queue_func_t	func;
	struct list_head	entry;
};
typedef struct wait_queue_entry wait_queue_entry_t
```

#### 初始化静态队列

##### 静态定义并初始化

include/linux/wait.h

```
#define DECLARE_WAITQUEUE(name, tsk)						\
	struct wait_queue_entry name = __WAITQUEUE_INITIALIZER(name, tsk)
```

#### 添加等待队列

add_wait_queue()函数

kernel/sched/wait.c

```
void add_wait_queue(struct wait_queue_head *wq_head, struct wait_queue_entry *wq_entry);
```

参数：
- q ：等待队列项要加入的等待队列头。

- wq_entry：要加入的等待队列项。

返回值：无

#### 移除等待队列

remove_wait_queue()函数

kernel/sched/wait.c

```
void remove_wait_queue(struct wait_queue_head *wq_head, struct wait_queue_entry *wq_entry);
```

参数：

- q ：等待队列项要加入的等待队列头。

- wq_entry：要删除的等待队列项。

返回值：无

#### 等待事件

include/linux/wait.h

```
wait_event(wq_head, condition)
wait_event_interruptible(wq_head, condition)
wait_event_timeout(wq_head, condition, timeout)	
```

参数：

- wq_head ：等待队列项要加入的等待队列头。

- condition：唤醒条件
- timeout：超时时间

#### 等待唤醒

kernel/sched/wait.c

```
void wake_up(wait_queue_head_t *q)
void wake_up_interruptible(wait_queue_head_t *q)
```

参数：

- q 就是要唤醒的等待队列头

返回值：无

