## platform：虚拟的平台总线

- platform_device：继承device，关联硬件代码

- platform_driver：继承device_driver，重设probe函数指针

- platform(bus_type)：统一管理、设置match匹配规则

#### 平台总线注册

drivers/base/platform.c

/sys/bus/platform

##### platform_bus_init()函数

```
struct bus_type platform_bus_type = {
	.name		= "platform",
	.dev_groups	= platform_dev_groups,
	.match		= platform_match,
	.uevent		= platform_uevent,
	.dma_configure	= platform_dma_configure,
	.pm		= &platform_dev_pm_ops,
};

int __init platform_bus_init(void)
{
...
	error =  bus_register(&platform_bus_type);
...
	return error;
}
```

###### platform_match()函数

设置匹配规则

```
static int platform_match(struct device *dev, struct device_driver *drv)
{
	struct platform_device *pdev = to_platform_device(dev);
	struct platform_driver *pdrv = to_platform_driver(drv);

	/* When driver_override is set, only bind to the matching driver */
	if (pdev->driver_override)
		return !strcmp(pdev->driver_override, drv->name);

	/* Attempt an OF style match first */
	if (of_driver_match_device(dev, drv))
		return 1;

	/* Then try ACPI style match */
	if (acpi_driver_match_device(dev, drv))
		return 1;

	/* Then try to match against the id table */
	if (pdrv->id_table)
		return platform_match_id(pdrv->id_table, pdev) != NULL;

	/* fall-back to driver name match */
	return (strcmp(pdev->name, drv->name) == 0);
}
```

- of_driver_match_device：设备树匹配
- acpi_driver_match_device：ACPI匹配
- platform_match_id：id_table匹配
- strcmp(pdev->name, drv->name)：设备名和驱动名匹配



#### 平台设备注册

drivers/base/platform.c

##### platform_device_register()函数

```
int platform_device_register(struct platform_device *pdev)
```

- 继承device

###### resources结构体

描述驱动的硬件资源

- start：资源的开始值
- end：资源的结束值
- flasg：资源的类型
  - IORESOURCE_MEM：内存地址
  - IORESOURCE_IO：IO端口
  - IORESOURCE_DMA：DMA传输
  - IORESOURCE_IRQ：中断



#### 平台驱动注册

include/linux/platform_device.h

##### platform_driver_register()宏

```
#define platform_driver_register(drv) \
	__platform_driver_register(drv, THIS_MODULE)
extern int __platform_driver_register(struct platform_driver *,
					struct module *);
```



#### 平台驱动获取资源

drivers/base/platform.c

##### platform_get_resource()函数

```
struct resource *platform_get_resource(struct platform_device *dev, unsigned int type, unsigned int num)
```

- dev：平台设备
- type：资源类型
- num：resources数组中资源编号

​	