## Linux中断基础概念

#### 回顾

裸机开发

- 通用中断控制器(GIC)
  - 中断类型、硬件中断号、分发器和cpu接口单元

- 中断向量表
  - 一级查表、二级查表

- 中断处理流程
  - 进入irq模式、保护现场、获取硬件中断编号、执行中断处理函数、还原现场

#### GIC中断控制器节点

arch/arm/boot/dts/imx6ull.dtsi

初始化中断控制器、设置其他中断控制器节点的描述格式

```
intc: interrupt-controller@a01000 {
		compatible = "arm,cortex-a7-gic";
		#interrupt-cells = <3>;
		interrupt-controller;
		reg = <0xa01000 0x1000>,
		      <0xa02000 0x100>;
	};
```

- #interrupt-cells：描述下一级中断信息所需要的单元个数
- interrupt-controller：表示该设备是一个中断控制器，外设可以连接在该中断控制器上
- reg：GIC的分发器和cpu接口单元寄存器地址

#### 外设中断控制器节点

arch/arm/boot/dts/imx6ull.dtsi

管理某一种具体中断

```
gpio5: gpio@20ac000 {
				compatible = "fsl,imx6ul-gpio", "fsl,imx35-gpio";
				reg = <0x20ac000 0x4000>;
				interrupts = <GIC_SPI 74 IRQ_TYPE_LEVEL_HIGH>,
					     <GIC_SPI 75 IRQ_TYPE_LEVEL_HIGH>;
				clocks = <&clks IMX6UL_CLK_GPIO5>;
				gpio-controller;
				#gpio-cells = <2>;
				interrupt-controller;
				#interrupt-cells = <2>;
				gpio-ranges = <&iomuxc 0 7 10>, <&iomuxc 10 5 2>;
			};
```

- interrupts：

  - GIC_SPI：中断类型，0 表示 SPI 中断，1 表示 PPI 中断

  - 74：中断号，对于 SPI 中断来说中断号的范围为 0~987，对于 PPI 中断来说中断号的范围为 0~15

  - IRQ_TYPE_LEVEL_HIGH：中断类型，高电平触发

#### 其他设备使用中断节点

使用某一种具体中断

```
button_interrupt {
    compatible = "button_interrupt";
    pinctrl-names = "default";
    pinctrl-0 = <&pinctrl_button>;
    button_gpio = <&gpio5 1 GPIO_ACTIVE_LOW>;
    status = "okay";
    interrupt-parent = <&gpio5>;
    interrupts = <1 IRQ_TYPE_EDGE_RISING>;
};
```

- interrupt-parent：表明归属的上一级中断

- interrupts：

  - 1：具体中断源，GPIO5-1
- IRQ_TYPE_EDGE_RISING：中断类型，上升沿触发

##### 中断类型

 include/linux/irq.h

```
enum {
	IRQ_TYPE_NONE		= 0x00000000,
	IRQ_TYPE_EDGE_RISING	= 0x00000001,
	IRQ_TYPE_EDGE_FALLING	= 0x00000002,
	IRQ_TYPE_EDGE_BOTH	= (IRQ_TYPE_EDGE_FALLING | IRQ_TYPE_EDGE_RISING),
	IRQ_TYPE_LEVEL_HIGH	= 0x00000004,
	IRQ_TYPE_LEVEL_LOW	= 0x00000008,
	...
	}
```



#### 常用函数

##### request_irq()函数

申请中断

include/linux/interrupt.h

```
static inline int __must_check
request_irq(unsigned int irq, irq_handler_t handler, unsigned long flags,
	    const char *name, void *dev)
```

参数：

- irq：要申请的中断号
- handler：中断处理函数
- flags：中断标志
- name：中断名字
- dev：传递给中断处理函数的第二个参数
  - device结构体变量，区分不同设备共用同一中断

返回值：

- 成功：0

- 失败：负数

###### irq_handler_t

```
typedef irqreturn_t (*irq_handler_t)(int, void *);
```

###### irqreturn_t

```
enum irqreturn {
    IRQ_NONE                = (0 << 0),
    IRQ_HANDLED             = (1 << 0),
    IRQ_WAKE_THREAD         = (1 << 1),
};

typedef enum irqreturn irqreturn_t;
```

- IRQ_NONE：不是本驱动程序的中断，不处理
- IRQ_HANDLED：正常处理
- IRQ_WAKE_THREAD：使用中断下半部处理

###### flags

include/linux/interrupt.h

```
#define IRQF_SHARED		0x00000080
#define IRQF_ONESHOT		0x00002000
#define IRQF_TRIGGER_NONE	0x00000000
#define IRQF_TRIGGER_RISING	0x00000001
#define IRQF_TRIGGER_FALLING	0x00000002
#define IRQF_TRIGGER_HIGH	0x00000004
#define IRQF_TRIGGER_LOW	0x00000008
```



##### free_irq()函数

释放中断

include/linux/interrupt.h

```
const void *free_irq(unsigned int irq, void *dev_id)
```

参数：

- irq：要释放的中断号

- dev：传递给中断处理函数的第二个参数

返回值：

​	无



##### enable_irq()函数

使能中断

kernel/irq/manage.c

```
void enable_irq(unsigned int irq)
```

参数：

- irq：要使能的中断号

返回值：

​	无



##### disable_irq()函数

禁止中断，等待中断执行完毕

kernel/irq/manage.c

```
void disable_irq(unsigned int irq)
```

参数：

- irq：要禁止的中断号

返回值：

​	无



##### disable_irq_nosync()函数

禁止中断，不等待中断执行完

kernel/irq/manage.c

```
void disable_irq_nosync(unsigned int irq)
```

参数：

- irq：要禁止的中断号

返回值：

​	无



##### local_irq_disable()宏

include/linux/irqflags.h

禁止处理器中断

```
#define local_irq_disable()	do { raw_local_irq_disable(); } while (0)
```



##### local_irq_enable()宏

include/linux/irqflags.h

开处理器中断

```
#define local_irq_enable()	do { raw_local_irq_enable(); } while (0)
```

