## imx_pinctrl和pinctrl_dev：引脚名字和编号该存在哪里？

pinctrl子系统预先确定引脚的数量和名字

- 为每个引脚的配置信息分配内存
- 管理每个引脚的使用状态

#### imx6ul_pinctrl_probe()函数

drivers/pinctrl/freescale/pinctrl-imx6ul.c

```
static int imx6ul_pinctrl_probe(struct platform_device *pdev)
{
	const struct imx_pinctrl_soc_info *pinctrl_info;
	const struct of_device_id *match;

	pinctrl_info = of_device_get_match_data(&pdev->dev);
	if (!pinctrl_info)
		return -ENODEV;

	match = of_match_device(imx6ul_pinctrl_of_match, &pdev->dev);

	if (!match)
		return -ENODEV;

	pinctrl_info = (struct imx_pinctrl_soc_info *) match->data;

	return imx_pinctrl_probe(pdev, pinctrl_info);
}
```

```
struct pinctrl_pin_desc {
	unsigned number;
	const char *name;
	void *drv_data;
};

struct imx_pinctrl_soc_info {
	const struct pinctrl_pin_desc *pins;
	unsigned int npins;
	unsigned int flags;
	const char *gpr_compatible;
	...
	}

165~295
```



#### of_device_get_match_data()函数

drivers/of/device.c

```
const void *of_device_get_match_data(const struct device *dev)
{
	const struct of_device_id *match;

	match = of_match_device(dev->driver->of_match_table, dev);
	if (!match)
		return NULL;

	return match->data;
}
```

#### of_match_device()函数

```
const struct of_device_id *of_match_device(const struct of_device_id *matches,
					   const struct device *dev)
{
	if ((!matches) || (!dev->of_node))
		return NULL;
	return of_match_node(matches, dev->of_node);
}
```



#### imx6ul_pinctrl_pads

- 引脚的编号和名字表

##### IMX_PINCTRL_PIN宏

drivers/pinctrl/freescale/pinctrl-imx.h

```
#define IMX_PINCTRL_PIN(pin) PINCTRL_PIN(pin, #pin)
```

##### PINCTRL_PIN宏

include/linux/pinctrl/pinctrl.h

```
#define PINCTRL_PIN(a, b) { .number = a, .name = b }
```

##### 引脚编号与复用寄存器的关系

pin.num = mux/4

#### imx_pinctrl：存储引脚的名字和编号原始表

##### imx_pinctrl_probe()函数

```
int imx_pinctrl_probe(struct platform_device *pdev,
		      const struct imx_pinctrl_soc_info *info)
{
	struct imx_pinctrl *ipctl;
	struct pinctrl_desc *imx_pinctrl_desc;
	...
	ipctl = devm_kzalloc(&pdev->dev, sizeof(*ipctl), GFP_KERNEL);
	...
	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	ipctl->base = devm_ioremap_resource(&pdev->dev, res);
	...
	imx_pinctrl_desc = devm_kzalloc(&pdev->dev, sizeof(*imx_pinctrl_desc),GFP_KERNEL);
	...
	imx_pinctrl_desc->name = dev_name(&pdev->dev);
	imx_pinctrl_desc->pins = info->pins;
	imx_pinctrl_desc->npins = info->npins;
	imx_pinctrl_desc->pctlops = &imx_pctrl_ops;
	imx_pinctrl_desc->pmxops = &imx_pmx_ops;
	imx_pinctrl_desc->confops = &imx_pinconf_ops;
	imx_pinctrl_desc->owner = THIS_MODULE;
	...
	ipctl->info = info;
	ipctl->dev = &pdev->dev;
	platform_set_drvdata(pdev, ipctl);
	...
	ret = devm_pinctrl_register_and_init(&pdev->dev,
					     imx_pinctrl_desc, ipctl,
					     &ipctl->pctl);
	...
	ret = imx_pinctrl_probe_dt(pdev, ipctl);
	...
	return pinctrl_enable(ipctl->pctl);
	...
	return ret;
}
	
```

#### pinctrl_desc：以基数树的方式存储引脚的名字，记录引脚的使用状态

##### devm_pinctrl_register_and_init()函数

drivers/pinctrl/core.c

```
int pinctrl_register_and_init(struct pinctrl_desc *pctldesc,
			      struct device *dev, void *driver_data,
			      struct pinctrl_dev **pctldev)
{
	struct pinctrl_dev *p;

	p = pinctrl_init_controller(pctldesc, dev, driver_data);
	if (IS_ERR(p))
		return PTR_ERR(p);

	*pctldev = p;

	return 0;
}
```

##### pinctrl_init_controller()函数

drivers/pinctrl/core.c

```
static struct pinctrl_dev *
pinctrl_init_controller(struct pinctrl_desc *pctldesc, struct device *dev,
			void *driver_data)
{
	struct pinctrl_dev *pctldev;
	...
	pctldev = kzalloc(sizeof(*pctldev), GFP_KERNEL);
	...
	pctldev->owner = pctldesc->owner;
	pctldev->desc = pctldesc;
	pctldev->driver_data = driver_data;
	/*初始化基数树*/
	INIT_RADIX_TREE(&pctldev->pin_desc_tree, GFP_KERNEL);
	...
	pctldev->dev = dev;
	...
	ret = pinctrl_register_pins(pctldev, pctldesc->pins, pctldesc->npins);
	...
	return pctldev;
	...
}
```

##### pinctrl_register_pins()函数

drivers/pinctrl/core.c

```
static int pinctrl_register_pins(struct pinctrl_dev *pctldev,
				 const struct pinctrl_pin_desc *pins,
				 unsigned num_descs)
{
	unsigned i;
	int ret = 0;

	for (i = 0; i < num_descs; i++) {
		ret = pinctrl_register_one_pin(pctldev, &pins[i]);
		if (ret)
			return ret;
	}

	return 0;
}
```

##### pinctrl_register_one_pin()函数

drivers/pinctrl/core.c

```
static int pinctrl_register_one_pin(struct pinctrl_dev *pctldev,
				    const struct pinctrl_pin_desc *pin)
{
	struct pin_desc *pindesc;

	pindesc = pin_desc_get(pctldev, pin->number);
	if (pindesc) {
		dev_err(pctldev->dev, "pin %d already registered\n",
			pin->number);
		return -EINVAL;
	}

	pindesc = kzalloc(sizeof(*pindesc), GFP_KERNEL);
	...
	pindesc->pctldev = pctldev;
	...
	if (pin->name) {
		pindesc->name = pin->name;
	} else {
		pindesc->name = kasprintf(GFP_KERNEL, "PIN%u", pin->number);
		if (!pindesc->name) {
			kfree(pindesc);
			return -ENOMEM;
		}
		pindesc->dynamic_name = true;
	}
	...
	radix_tree_insert(&pctldev->pin_desc_tree, pin->number, pindesc);
	...
	return 0;
}
```

