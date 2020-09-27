## completion机制基本概念

完成量：用于进程/线程同步，与信号量/互斥量类似

#### 语义

信号量/互斥量：资源对所有进程/线程是公平的，按先来后到顺序使用

完成量：一个线程的运行依赖另一个线程

#### completion结构体

include/linux/completion.h

```
struct completion {
	unsigned int done;
	wait_queue_head_t wait;
};
```

- done：表示当前completion的状态
- wait：等待队列头

#### 初始化completion

##### init_completion()宏

include/linux/completion.h

```
#define init_completion(x) __init_completion(x)
```

###### __init_completion()函数

include/linux/completion.h

```
static inline void __init_completion(struct completion *x)
{
	x->done = 0;
	init_waitqueue_head(&x->wait);
}
```

##### 静态定义并初始化

###### DECLARE_COMPLETION宏

```
#define DECLARE_COMPLETION(work) \
	struct completion work = COMPLETION_INITIALIZER(work)
```

###### COMPLETION_INITIALIZER宏

```
#define COMPLETION_INITIALIZER(work) \
	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait) }
```

#### completion休眠

##### wait_for_completion()函数

kernel/sched/completion.c

```
void __sched wait_for_completion(struct completion *x)
```

参数：

- x：完成量结构体指针

##### wait_for_completion_timeout()函数

kernel/sched/completion.c

```
unsigned long __sched
wait_for_completion_timeout(struct completion *x, unsigned long timeout)
```

参数：

- x：完成量结构体指针

- timeout：超时事件

##### wait_for_completion_interruptible()函数

kernel/sched/completion.c

```
int __sched wait_for_completion_interruptible(struct completion *x)
```

参数：

- x：完成量结构体指针

#### complete唤醒

##### complete()函数

kernel/sched/completion.c

```
void complete(struct completion *x)
```

参数：

- x：完成量结构体指针

##### complete_all()函数

kernel/sched/completion.c

```
void complete_all(struct completion *x)
```

参数：

- x：完成量结构体指针