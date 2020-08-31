## pinctrl子系统实验：RGB灯引脚初始化

#### platform设备引脚初始化

注册平台设备或者平台驱动

#### really_probe()函数

drivers/base/dd.c

```
static int really_probe(struct device *dev, struct device_driver *drv)
{
	int ret = -EPROBE_DEFER;
...
re_probe:
	dev->driver = drv;

	ret = pinctrl_bind_pins(dev);
...

	if (dev->bus->probe) {
		ret = dev->bus->probe(dev);
		if (ret)
			goto probe_failed;
	} else if (drv->probe) {
		ret = drv->probe(dev);
		if (ret)
			goto probe_failed;
	}

...
	}

```



#### pinctrl_bind_pins()函数

drivers/base/pinctrl.c

```
int pinctrl_bind_pins(struct device *dev)
{
	int ret;
...
	dev->pins = devm_kzalloc(dev, sizeof(*(dev->pins)), GFP_KERNEL);
	if (!dev->pins)
		return -ENOMEM;
...
	dev->pins->default_state = pinctrl_lookup_state(dev->pins->p,PINCTRL_STATE_DEFAULT);
	if (IS_ERR(dev->pins->default_state)) {
		dev_dbg(dev, "no default pinctrl state\n");
		ret = 0;
		goto cleanup_get;
	}

	dev->pins->init_state = pinctrl_lookup_state(dev->pins->p,PINCTRL_STATE_INIT);
	if (IS_ERR(dev->pins->init_state)) {
		/* Not supplying this state is perfectly legal */
		dev_dbg(dev, "no init pinctrl state\n");

		ret = pinctrl_select_state(dev->pins->p,
					   dev->pins->default_state);
	} else {
		ret = pinctrl_select_state(dev->pins->p, dev->pins->init_state);
	}
	...
}
```



#### RGB灯引脚状态初始化

##### iomuxc节点添加引脚配置信息

```
pinctrl_rgb_led:rgb_led{
                    fsl,pins = <
                            MX6UL_PAD_GPIO1_IO04__GPIO1_IO04    0x000010B1
                            MX6UL_PAD_CSI_HSYNC__GPIO4_IO20     0x000010B1
                            MX6UL_PAD_CSI_VSYNC__GPIO4_IO19     0x000010B1
                    >;
            };
```

##### rgb_led节点添加引脚状态

```
 pinctrl-names = "default";
 pinctrl-0 = <&pinctrl_rgb_led>;
```







