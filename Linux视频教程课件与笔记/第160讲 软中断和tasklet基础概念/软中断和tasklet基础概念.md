## 软中断和tasklet基础概念

#### 中断函数

##### 设计原则

- 执行越快越好

##### 根源

- 打断其他重要代码的执行
- 中断函数通常在关中断情况下执行

#### 中断上下半部机制

##### 上半部

传统的中断处理函数

- 表明中断已经被系统捕获
- 对响应时间有苛刻要求的操作

- 执行速度快的操作
- 硬件信号控制
- ...

下半部

非中断处理函数，由上半部设置工作任务

- 数据复制
- 数据包装和转发
- 计算时间长的数据处理
- 读取外部数据
- ...

#### 软中断

中断下半部的一种机制

##### softirq_action结构体

 include/linux/interrupt.h

```
struct softirq_action
{
	void (*action)(struct softirq_action *);
};
```

##### softirq_vec数组

 kernel/softirq.c

```
static struct softirq_action softirq_vec[NR_SOFTIRQS];
```

##### NR_SOFTIRQS变量

```
enum
{
    HI_SOFTIRQ=0, /* 最高优先级软中断 */
    TIMER_SOFTIRQ, /* 定时器软中断 */
    NET_TX_SOFTIRQ, /* 网络数据发送软中断 */
    NET_RX_SOFTIRQ, /* 网络数据接收软中断 */
    BLOCK_SOFTIRQ,	/*块设备软中断*/
    BLOCK_IOPOLL_SOFTIRQ,
    TASKLET_SOFTIRQ, /* tasklet 软中断 */
    SCHED_SOFTIRQ, /* 调度软中断 */
    HRTIMER_SOFTIRQ, /* 高精度定时器软中断  */
    RCU_SOFTIRQ, /* RCU服务软中断  */
    NR_SOFTIRQS
};
```

- 内核已经规定了所有软中断的用法

#### open_softirq()函数

include/linux/interrupt.h

注册一个软中断

```
void open_softirq(int nr, void (*action)(struct softirq_action *));
```

参数：

- nr：要开启的软中断
- action：相应的处理函数

返回值：无



#### raise_softirq()函数

include/linux/interrupt.h

主动触发指定软中断

```
void raise_softirq(unsigned int nr);
```

参数：

- nr：指定激活的软中断

返回值：无



#### tasklet机制

基于软中断实现的下半部机制，运行在软中断环境下

##### softirq_init()函数

 kernel/softirq.c

```
void __init softirq_init(void)
{
	int cpu;

	for_each_possible_cpu(cpu) {
		per_cpu(tasklet_vec, cpu).tail =
			&per_cpu(tasklet_vec, cpu).head;
		per_cpu(tasklet_hi_vec, cpu).tail =
			&per_cpu(tasklet_hi_vec, cpu).head;
	}

	open_softirq(TASKLET_SOFTIRQ, tasklet_action);
	open_softirq(HI_SOFTIRQ, tasklet_hi_action);
}
```



##### tasklet_struct结构体

include/linux/interrupt.h

```
struct tasklet_struct
{
	struct tasklet_struct *next;
	unsigned long state;
	atomic_t count;
	void (*func)(unsigned long);
	unsigned long data;
};

```

- next：下一个tasket
- state：tasklet状态
- count：计数器，记录对tasket的引用数
- func：tasklet执行的函数
- data：函数参数



##### tasklet_init()函数

初始化一个tasket对象

include/linux/interrupt.h

```
void tasklet_init(struct tasklet_struct *t,
		  void (*func)(unsigned long), unsigned long data)
```

参数：

- t：要初始化的tasket
- func：tasklet执行的函数
- data：函数参数

返回值：无



##### tasklet_schedule()函数

调度执行tasket对象

include/linux/interrupt.h

```
static inline void tasklet_schedule(struct tasklet_struct *t)
```

参数：

- t：要调度的tasket对象

返回值：无



##### tasklet_kill()函数

注销tasket对象

include/linux/interrupt.h

```
void tasklet_kill(struct tasklet_struct *t);
```

参数：

- t：要注销的tasket对象

返回值：无