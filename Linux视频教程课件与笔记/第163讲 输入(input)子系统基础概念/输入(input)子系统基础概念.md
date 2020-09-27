##  输入(input)子系统基础概念

统一管理外部输入设备

- 按键
- 键盘
- 鼠标
- 触摸屏

...

#### 用户空间接口

- /dev/input/event0/1/2/...
- /dev/input/mouse0/1/2/...
- /dev/input/sj0/1/2/...
- ...

#### 分层模型

- ##### 核心层

  - 创建input设备类
  - 根据输入设备种类、分发事件到不同事件处理器

- ##### 事件处理层

  提供具体设备的操作接口，为输入设备(input_dev)创建具体设备文件

  - 通用事件处理器(drivers/input/evdev.c)

  - 鼠标事件处理器(drivers/input/mousedev.c)
  - 摇杆事件处理器(drivers/input/joydev.c)
  - ...

#### 创建input设备类

##### input_init()函数

 drivers/input/input.c

```
static int __init input_init(void)
{
	int err;

	err = class_register(&input_class);
	if (err) {
		pr_err("unable to register input_dev class\n");
		return err;
	}
	...
	err = register_chrdev_region(MKDEV(INPUT_MAJOR, 0),
				     INPUT_MAX_CHAR_DEVICES, "input");
	if (err) {
		pr_err("unable to register char major %d", INPUT_MAJOR);
		goto fail2;
	}

	return 0;

 fail2:	input_proc_exit();
 fail1:	class_unregister(&input_class);
	return err;
}
```

##### input_class定义

drivers/input/input.c

```
struct class input_class = {
	.name		= "input",
	.devnode	= input_devnode,
};
```

##### INPUT_MAJOR定义

 include/uapi/linux/major.h

```
#define INPUT_MAJOR  13
```

##### INPUT_MAX_CHAR_DEVICES定义

drivers/input/input.c

```
#define INPUT_MAX_CHAR_DEVICES		1024
```



### input_dev结构体

include/linux/input.h

```
struct input_dev {
	const char *name;
	const char *phys;
	const char *uniq;
	struct input_id id;

	unsigned long propbit[BITS_TO_LONGS(INPUT_PROP_CNT)];

	unsigned long evbit[BITS_TO_LONGS(EV_CNT)];
	unsigned long keybit[BITS_TO_LONGS(KEY_CNT)];
	unsigned long relbit[BITS_TO_LONGS(REL_CNT)];
	unsigned long absbit[BITS_TO_LONGS(ABS_CNT)];
	unsigned long mscbit[BITS_TO_LONGS(MSC_CNT)];
	unsigned long ledbit[BITS_TO_LONGS(LED_CNT)];
	unsigned long sndbit[BITS_TO_LONGS(SND_CNT)];
	unsigned long ffbit[BITS_TO_LONGS(FF_CNT)];
	unsigned long swbit[BITS_TO_LONGS(SW_CNT)];
	...
	int (*open)(struct input_dev *dev);
	void (*close)(struct input_dev *dev);
	int (*flush)(struct input_dev *dev, struct file *file);
	int (*event)(struct input_dev *dev, unsigned int type, unsigned int code, int value);
	...
	struct device dev;

	struct list_head	h_list;
	struct list_head	node;

	unsigned int num_vals;
	unsigned int max_vals;
	struct input_value *vals;

	bool devres_managed;
};
```

- name：输入设备名
- id：输入设备与事件处理器的匹配信息
- evbit：指定支持的事件类型
  - 同步事件、按键事件、坐标事件...
- keybit：指定支持的按键值类型
  - key1、key2...
- relbit：指定支持相对坐标类型
  - x轴、y轴、z轴、滑轮...

- absbit：指定支持绝对坐标类型
  - x轴、y轴、z轴、滑轮...

##### 事件类型

include/linux/input.h

```
#define EV_SYN			0x00
#define EV_KEY			0x01
#define EV_REL			0x02
#define EV_ABS			0x03
...
#define EV_CNT			(EV_MAX+1)
```

##### 按键值类型

include/linux/input.h

```
#define KEY_RESERVED		0
#define KEY_ESC			1
#define KEY_1			2
#define KEY_2			3
#define KEY_3			4
#define KEY_4			5
#define KEY_5			6
...
```



#### 注册/销毁输入设备

##### input_allocate_device()函数

drivers/input/input.c

分配并初步初始化 input_dev 结构体变量

```
struct input_dev *input_allocate_device(void)
```

##### input_register_device()函数

drivers/input/input.c

向系统注册输入设备

```
int input_register_device(struct input_dev *dev)
```

##### input_unregister_device()函数

drivers/input/input.c

向系统注释输入设备

```
void input_unregister_device(struct input_dev *dev)
```

##### input_free_device()函数

drivers/input/input.c

释放 input_dev 结构体变量

```
void input_free_device(struct input_dev *dev)
```



#### 上报输入事件

##### input_event()函数

drivers/input/input.c

通用事件上报接口

```
void input_event(struct input_dev *dev,unsigned int type, unsigned int code, int value)
```

参数：

- dev：需要上报信息的输入设备

- type：上报的具体输入事件类型

  - 按键输入类型：EV_KEY
  - 坐标输入类型：EV_REL、EV_ABS
  - 特殊类型：EV_SYN
    - 同步事件：通知用户空间的程序接收消息

  - ...

- code：记录输入事件类型中的具体事件

  - 键盘发生按键输入类型事件时，记录键盘那个值被按下

  - ...

- value：具体事件的对应值

  - 按键按下，value值为1；按键松开，value值为0

  - ...

返回值：无

##### input_report_key()函数

include/linux/input.h

按键事件上报接口

```
static inline void input_report_key(struct input_dev *dev, unsigned int code, int value)
{
	input_event(dev, EV_KEY, code, !!value);
}
```

##### input_report_rel()函数

include/linux/input.h

相对坐标事件上报接口

```
static inline void input_report_rel(struct input_dev *dev, unsigned int code, int value)
{
	input_event(dev, EV_REL, code, value);
}
```

##### input_report_abs()函数

include/linux/input.h

绝对坐标事件上报接口

```
static inline void input_report_abs(struct input_dev *dev, unsigned int code, int value)
{
	input_event(dev, EV_ABS, code, value);
}
```

##### input_sync()函数

include/linux/input.h

同步事件上报接口

```
static inline void input_sync(struct input_dev *dev)
{
	input_event(dev, EV_SYN, SYN_REPORT, 0);
}
```

