## kthread_worker：怎么把内核线程当工人？

#### 驱动传输数据 

- 低速数据：驱动同步传输
  - 简单直接、传输效率低

- 高速数据：驱动交给内核来异步传输
  - 机制复杂、无阻塞

#### kthread_worker结构体

include/linux/kthread.h

表示把内核线程抽象为流水线工人，按序处理其他线程/进程交付的批量工作

```
struct kthread_worker {
	unsigned int		flags;
	spinlock_t		lock;
	struct list_head	work_list;
	struct list_head	delayed_work_list;
	struct task_struct	*task;
	struct kthread_work	*current_work;
};
```

- lock：自旋锁
- work_list：链表节点，按序记录工作
- delayed_work_list：
- task：内核线程

- current_work：指向正在处理的具体工作

#### kthread_work结构体

include/linux/kthread.h

表示等待内核线程处理的具体工作

```
struct kthread_work {
	struct list_head	node;
	kthread_work_func_t	func;
	struct kthread_worker	*worker;
	/* Number of canceling calls that are running at the moment. */
	int			canceling;
};
```

- node：链表节点
- func：函数指针
- worker：处理该工作的内核线程工人

##### kthread_work_func_t数据类型定义

```
typedef void (*kthread_work_func_t)(struct kthread_work *work);
```

#### kthread_flush_work结构体

kernel/kthread.c

表示等待某个内核线程工人处理完所有工作

```
struct kthread_flush_work {
	struct kthread_work	work;
	struct completion	done;
};
```

- work：具体内核线程工人
- done：完成量，等待所有工作处理完毕

#### 初始化kthread_worker

##### kthread_init_worker函数

```
struct kthread_worker hi_worker; 
kthread_init_worker(&hi_worker); 
```

- 先定义，后初始化

#### 为kthread_worker创建内核线程

```
struct task_struct *kworker_task;

kworker_task =kthread_run(kthread_worker_fn, &hi_worker, "nvme%d", 1);
```

- 先定义，后初始化
- kthread_worker_fn：内核线程一直运行的函数
- hi_worker：已初始化的kthread_worker结构体变量
- "nvme%d"：为内核线程设置名字

#### 初始化kthread_work

```
struct kthread_work hi_work;
kthread_init_work(&hi_work, xxx_work_fn); 
```

- 先定义，后初始化
- xxx_work_fn：处理该工作的具体函数，自定义实现

#### 启动工作

交付工作给内核线程工人

```
kthread_queue_work(&hi_worker, &hi_work);
```

- hi_worker：具体内核线程工人
- hi_work：具体工作

#### FLUSH工作队列

刷新指定 kthread_worker上所有 work

```
kthread_flush_worker(&hi_worker);
```

- hi_worker：具体内核线程工人

#### 停止内核线程

```
kthread_stop(kworker_task);
```

