## SPI驱动框架简介

#### SPI框架图

![image-20200904124712459](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200904124712459.png)

- SPI核心层

  提供SPI控制器驱动和设备驱动的注册方法、注销方法、SPI通信硬件无关接口

- SPI主机驱动

  主要包含SPI硬件体系结构中适配器(spi控制器)的控制，用于产生SPI 读写时序

  主要数据结构：spi_master(spi_controller)

- SPI设备驱动

  通过SPI主机驱动与CPU交换数据

  主要数据结构：spi_device和spi_driver

#### 核心数据结构

##### spi_master

include/linux/spi/spi.h

```
#define spi_master			spi_controller
```

##### spi_controller

include/linux/spi/spi.h

```
struct spi_controller {
	struct device	dev;
	...
	struct list_head list;
	s16			bus_num;
	u16			num_chipselect;
	...
	struct spi_message		*cur_msg;
	...
	int			(*setup)(struct spi_device *spi);
	int			(*transfer)(struct spi_device *spi,
						struct spi_message *mesg);
	void		(*cleanup)(struct spi_device *spi);
	struct kthread_worker		kworker;
	struct task_struct		*kworker_task;
	struct kthread_work		pump_messages;
	struct list_head		queue;
	struct spi_message		*cur_msg;
	
	...
	int (*transfer_one)(struct spi_controller *ctlr, struct spi_device *spi,struct spi_transfer *transfer);
	int (*prepare_transfer_hardware)(struct spi_controller *ctlr);
	int (*transfer_one_message)(struct spi_controller *ctlr,struct spi_message *mesg);
	void (*set_cs)(struct spi_device *spi, bool enable);
	...
	int			*cs_gpios;
}
```

- list：链表节点，芯片可能有多个spi控制器

- bus_num：spi控制器编号

- num_chipselect：片选信号的个数

- cur_msg：当前正带处理的消息队列

- transfer ：用于把数据加入控制器的消息链表中

- cleanup：当spi_master被释放的时候，完成清理工作

- kworker：内核线程工人，spi可以使用异步传输方式发送数据

- pump_messages：具体传输工作

- queue：所有等待传输的消息队列挂在该链表下

- transfer_one_message：发送一个spi消息，类似IIC适配器里的algo->master_xfer，产生spi通信时序

- 相关API

  - int spi_register_master(struct spi_master *master)

    注册一个spi_controller

  - void spi_unregister_master(struct spi_master *master)

    注销一个spi_controller

##### spi_device

include/linux/spi/spi.h

```
struct spi_device {
	struct device		dev;
	struct spi_controller	*controller;
	struct spi_controller	*master;	/* compatibility layer */
	u32			max_speed_hz;
	u8			chip_select;
	u8			bits_per_word;
	u16			mode;
#define	SPI_CPHA	0x01			/* clock phase */
#define	SPI_CPOL	0x02			/* clock polarity */
#define	SPI_MODE_0	(0|0)			/* (original MicroWire) */
#define	SPI_MODE_1	(0|SPI_CPHA)
#define	SPI_MODE_2	(SPI_CPOL|0)
#define	SPI_MODE_3	(SPI_CPOL|SPI_CPHA)
#define	SPI_CS_HIGH	0x04			/* chipselect active high? */
#define	SPI_LSB_FIRST	0x08			/* per-word bits-on-wire */
#define	SPI_3WIRE	0x10			/* SI/SO signals shared */
#define	SPI_LOOP	0x20			/* loopback mode */
#define	SPI_NO_CS	0x40			/* 1 dev/bus, no chipselect */
#define	SPI_READY	0x80			/* slave pulls low to pause */
#define	SPI_TX_DUAL	0x100			/* transmit with 2 wires */
#define	SPI_TX_QUAD	0x200			/* transmit with 4 wires */
#define	SPI_RX_DUAL	0x400			/* receive with 2 wires */
#define	SPI_RX_QUAD	0x800			/* receive with 4 wires */
...
	char			modalias[SPI_NAME_SIZE];
...
}
```

##### spi_driver

include/linux/spi/spi.h

```
struct spi_driver {
	const struct spi_device_id *id_table;
	int			(*probe)(struct spi_device *spi);
	int			(*remove)(struct spi_device *spi);
	void			(*shutdown)(struct spi_device *spi);
	struct device_driver	driver;
};
```

- probe：spi设备和spi驱动匹配后，回调该函数指针

- 相关API：

  - int spi_register_driver(struct spi_driver *sdrv)

    注册一个spi驱动

  - void spi_unregister_driver(struct spi_driver *sdrv)

    注册一个spi驱动

#### spi 总线注册

drivers/spi/spi.c

```
static int __init spi_init(void)
{
	int	status;
	...
	status = bus_register(&spi_bus_type);
	...
	status = class_register(&spi_master_class);
	...
}
```

- sys/bus/spi
- sys/class/spi_master

#### spi总线定义

```
struct bus_type spi_bus_type = {
	.name		= "spi",
	.dev_groups	= spi_dev_groups,
	.match		= spi_match_device,
	.uevent		= spi_uevent,
};
```

#### spi_match_device()函数

drivers/spi/spi.c

```
static int spi_match_device(struct device *dev, struct device_driver *drv)
{
	const struct spi_device	*spi = to_spi_device(dev);
	const struct spi_driver	*sdrv = to_spi_driver(drv);

	/* Attempt an OF style match */
	if (of_driver_match_device(dev, drv))
		return 1;

	/* Then try ACPI */
	if (acpi_driver_match_device(dev, drv))
		return 1;

	if (sdrv->id_table)
		return !!spi_match_id(sdrv->id_table, spi);

	return strcmp(spi->modalias, drv->name) == 0;
}
```

#### spi控制器驱动

##### 设备树节点

arch/arm/boot/dts/imx6ull.dtsi

4个spi控制器节点

```
ecspi3: ecspi@2010000 {
					#address-cells = <1>;
					#size-cells = <0>;
					compatible = "fsl,imx6ul-ecspi", "fsl,imx51-ecspi";
					reg = <0x2010000 0x4000>;
					interrupts = <GIC_SPI 33 IRQ_TYPE_LEVEL_HIGH>;
					clocks = <&clks IMX6UL_CLK_ECSPI3>,
						 <&clks IMX6UL_CLK_ECSPI3>;
					clock-names = "ipg", "per";
					dmas = <&sdma 7 7 1>, <&sdma 8 7 2>;
					dma-names = "rx", "tx";
					status = "disabled";
				};
```

##### module_platform_driver()宏

include/linux/platform_device.h

```
#define module_platform_driver(__platform_driver) \
	module_driver(__platform_driver, platform_driver_register, \
			platform_driver_unregister)
```

#### module_driver()宏

include/linux/device.h

```
#define module_driver(__driver, __register, __unregister, ...) \
static int __init __driver##_init(void) \
{ \
	return __register(&(__driver) , ##__VA_ARGS__); \
} \
module_init(__driver##_init); \
```

- __driver：spi_imx_driver
- __register：platform_driver_register

- __unregister：platform_driver_unregister
- \##\__VA_ARGS__：可变参数

##### module_platform_driver(spi_imx_driver)

```
static int __init spi_imx_driver_init(void) \
{ \
	return platform_driver_register(&(spi_imx_driver) , ##__VA_ARGS__); \
} \
module_init(spi_imx_driver_init); \
```
