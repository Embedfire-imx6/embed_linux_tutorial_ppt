## IIC驱动框架简介

#### iic物理总线

- SCL：时钟线，数据收发同步
- SDA：数据线，具体数据

支持一主多从，各设备地址独立，标准模式传输速率为100kbit/s，快速模式为400kbit/s

##### 常见iic设备

- eeprom

- 触摸芯片

- 温湿度传感器

- mpu6050

  ...

#### 框架图

![image-20200901213737995](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200901213737995.png)

- I2C核心

  提供I2C总线驱动和设备驱动的注册方法、注销方法、I2C通信硬件无关代码

- I2C 总线驱动

  主要包含I2C硬件体系结构中适配器(iic控制器)的控制，用于I2C 读写时序

  主要数据结构：I2C_adapter、i2c_algorithm

- I2C设备驱动

  通过I2C适配器与CPU交换数据

  主要数据结构：i2c_driver和i2c_client

#### 核心数据结构

##### i2c_adapter

include/linux/i2c.h

```
struct i2c_adapter {
	struct module *owner;
	unsigned int class;		  /* classes to allow probing for */
	const struct i2c_algorithm *algo; /* the algorithm to access the bus */
	void *algo_data;

	...
};
```

- 对应一个IIC控制器

- 相关API

  - int i2c_add_adapter(struct i2c_adapter *adapter)

    注册一个i2c_adapter ，系统分配编号

  - int i2c_add_numbered_adapter(struct i2c_adapter *adapter)

    注册一个i2c_adapter ，自己指定编号

  - void i2c_del_adapter(struct i2c_adapter * adap)

    注销一个i2c_adapter 

#####  i2c_algorithm

include/linux/i2c.h

```
struct i2c_algorithm {
	int (*master_xfer)(struct i2c_adapter *adap, struct i2c_msg *msgs,
			   int num);
	int (*smbus_xfer) (struct i2c_adapter *adap, u16 addr,
			   unsigned short flags, char read_write,
			   u8 command, int size, union i2c_smbus_data *data);

	/* To determine what the adapter supports */
	u32 (*functionality) (struct i2c_adapter *);

#if IS_ENABLED(CONFIG_I2C_SLAVE)
	int (*reg_slave)(struct i2c_client *client);
	int (*unreg_slave)(struct i2c_client *client);
#endif
};
```

- 对应一套具体的通信方法

- master_xfer：产生I2C通信时序

##### struct i2c_client

include/linux/i2c.h

```
struct i2c_client {
	unsigned short flags;		/* div., see below		*/
	unsigned short addr;		/* chip address - NOTE: 7bit	*/

	char name[I2C_NAME_SIZE];
	struct i2c_adapter *adapter;	/* the adapter we sit on	*/
	struct device dev;		/* the device structure		*/
	int init_irq;			/* irq set at initialization	*/
	int irq;			/* irq issued by device		*/
	struct list_head detected;
#if IS_ENABLED(CONFIG_I2C_SLAVE)
	i2c_slave_cb_t slave_cb;	/* callback for slave mode	*/
#endif
};
```

- addr：i2c设备地址

##### struct i2c_driver

include/linux/i2c.h

```
struct i2c_driver {
	unsigned int class;

	/* Standard driver model interfaces */
	int (*probe)(struct i2c_client *, const struct i2c_device_id *);
	int (*remove)(struct i2c_client *);
	...
	struct device_driver driver;
	const struct i2c_device_id *id_table;
	...
}
```

- id_table：i2c总线传统匹配方式

- probe：i2c设备和i2c驱动匹配后，回调该函数指针

- 相关API

  - int i2c_add_driver (struct i2c_driver *driver)

    注册一个i2c_driver

  - void i2c_del_driver(struct i2c_driver *driver)

    注销一个i2c_driver

#### I2C 总线驱动分析

##### i2c总线注册

drivers/i2c/i2c-core-base.c

```
static int __init i2c_init(void)
{
	int retval;
	...
	retval = bus_register(&i2c_bus_type);
	if (retval)
		return retval;

	is_registered = true;
	...
	retval = i2c_add_driver(&dummy_driver);
	if (retval)
		goto class_err;

	if (IS_ENABLED(CONFIG_OF_DYNAMIC))
		WARN_ON(of_reconfig_notifier_register(&i2c_of_notifier));
	if (IS_ENABLED(CONFIG_ACPI))
		WARN_ON(acpi_reconfig_notifier_register(&i2c_acpi_notifier));

	return 0;
	...
}
```

##### i2c总线定义

```
struct bus_type i2c_bus_type = {
	.name		= "i2c",
	.match		= i2c_device_match,
	.probe		= i2c_device_probe,
	.remove		= i2c_device_remove,
	.shutdown	= i2c_device_shutdown,
};
```

##### i2c设备和i2c驱动匹配规则

```
static int i2c_device_match(struct device *dev, struct device_driver *drv)
{
	struct i2c_client	*client = i2c_verify_client(dev);
	struct i2c_driver	*driver;


	/* Attempt an OF style match */
	if (i2c_of_match_device(drv->of_match_table, client))
		return 1;

	/* Then ACPI style match */
	if (acpi_driver_match_device(dev, drv))
		return 1;

	driver = to_i2c_driver(drv);

	/* Finally an I2C match */
	if (i2c_match_id(driver->id_table, client))
		return 1;

	return 0;
}
```

- of_driver_match_device：设备树匹配方式
  - 比较 I2C 设备节点的 compatible 属性和 of_device_id 中的 compatible 属性

- acpi_driver_match_device ： ACPI 匹配方式
- i2c_match_id：i2c总线传统匹配方式
  - 比较 I2C设备名字和 i2c驱动的id_table->name 字段是否相等

##### 设备树节点

arch/arm/boot/dts/imx6ull.dtsi

```
i2c1: i2c@21a0000 {
				#address-cells = <1>;
				#size-cells = <0>;
				compatible = "fsl,imx6ul-i2c", "fsl,imx21-i2c";
				reg = <0x21a0000 0x4000>;
				interrupts = <GIC_SPI 36 IRQ_TYPE_LEVEL_HIGH>;
				clocks = <&clks IMX6UL_CLK_I2C1>;
				status = "disabled";
			};
```

##### i2c_imx_probe()函数

drivers/i2c/busses/i2c-imx.c

```
static int i2c_imx_probe(struct platform_device *pdev)
{
	const struct of_device_id *of_id = of_match_device(i2c_imx_dt_ids,
							   &pdev->dev);
	struct imx_i2c_struct *i2c_imx;
	struct resource *res;
	struct imxi2c_platform_data *pdata = dev_get_platdata(&pdev->dev);
	void __iomem *base;
	int irq, ret;
	dma_addr_t phy_addr;
	
	...
	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	base = devm_ioremap_resource(&pdev->dev, res);
	
	phy_addr = (dma_addr_t)res->start;
	i2c_imx = devm_kzalloc(&pdev->dev, sizeof(*i2c_imx), GFP_KERNEL);
	...
	i2c_imx->adapter.algo		= &i2c_imx_algo;
	...
	i2c_imx->base			= base;
	...
	ret = i2c_add_numbered_adapter(&i2c_imx->adapter);
	...
}
```

#### i2c_imx_algo结构体变量

drivers/i2c/busses/i2c-imx.c

```
static const struct i2c_algorithm i2c_imx_algo = {
	.master_xfer	= i2c_imx_xfer,
	.functionality	= i2c_imx_func,
};
```

- i2c_imx_xfer：iic通信函数
- i2c_imx_func：查询iic通信协议类型

#### i2c_imx_func()函数

drivers/i2c/busses/i2c-imx.c

```
static u32 i2c_imx_func(struct i2c_adapter *adapter)
{
	return I2C_FUNC_I2C | I2C_FUNC_SMBUS_EMUL
		| I2C_FUNC_SMBUS_READ_BLOCK_DATA;
}
```

#### i2c_imx_xfer()函数

drivers/i2c/busses/i2c-imx.c

```
static int i2c_imx_xfer(struct i2c_adapter *adapter,
						struct i2c_msg *msgs, int num)
{
	unsigned int i, temp;
	int result;
	bool is_lastmsg = false;
	bool enable_runtime_pm = false;
	struct imx_i2c_struct *i2c_imx = i2c_get_adapdata(adapter);
	...
	result = i2c_imx_start(i2c_imx);
	...
		for (i = 0; i < num; i++) {
		if (i == num - 1)
			is_lastmsg = true;

		if (i) {
			dev_dbg(&i2c_imx->adapter.dev,
				"<%s> repeated start\n", __func__);
			temp = imx_i2c_read_reg(i2c_imx, IMX_I2C_I2CR);
			temp |= I2CR_RSTA;
			imx_i2c_write_reg(temp, i2c_imx, IMX_I2C_I2CR);
			result = i2c_imx_bus_busy(i2c_imx, 1);
			if (result)
				goto fail0;
		}
	...
		if (msgs[i].flags & I2C_M_RD)
			result = i2c_imx_read(i2c_imx, &msgs[i], is_lastmsg);
		else {
			if (i2c_imx->dma && msgs[i].len >= DMA_THRESHOLD)
				result = i2c_imx_dma_write(i2c_imx, &msgs[i]);
			else
				result = i2c_imx_write(i2c_imx, &msgs[i]);
		}
		if (result)
			goto fail0;
	}

fail0:
	/* Stop I2C transfer */
	i2c_imx_stop(i2c_imx);
	...
}
	
```

