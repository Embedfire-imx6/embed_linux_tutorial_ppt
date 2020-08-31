## pin function和pin group：iomuxc节点解析始末

#### 设备树iomuxc节点层次

- iomuxc

  - function

    - group

      ```
      fsl,pins = <
      			xxx
      			xxx
      		>;
      ```

      ...

    - group
    - ...

  - function

  - ...

#### 层次关系说明

- iomuxc：pinctrl子系统的设备树节点
- function：芯片具有外设功能，一个功能对应一个或多个IO组配置信息
- group：IO组中每个IO的配置信息
- fsl,pins：imx6ull中，功能和IO组的标识属性



#### imx_pinctrl_probe_dt()函数

drivers/pinctrl/freescale/pinctrl-imx.c

```
static int imx_pinctrl_probe_dt(struct platform_device *pdev,
				struct imx_pinctrl *ipctl)
{
	//iomux节点
	struct device_node *np = pdev->dev.of_node;
	struct device_node *child;
	struct pinctrl_dev *pctl = ipctl->pctl;
	
	flat_funcs = imx_pinctrl_dt_is_flat_functions(np);
	if (flat_funcs) {
		nfuncs = 1;
	} else {
		nfuncs = of_get_child_count(np);
		if (nfuncs == 0) {
			dev_err(&pdev->dev, "no functions defined\n");
			return -EINVAL;
		}
	}
	
	for (i = 0; i < nfuncs; i++) {
		struct function_desc *function;

		function = devm_kzalloc(&pdev->dev, sizeof(*function),
					GFP_KERNEL);
		if (!function)
			return -ENOMEM;

		mutex_lock(&ipctl->mutex);
		radix_tree_insert(&pctl->pin_function_tree, i, function);
		mutex_unlock(&ipctl->mutex);
	}
	
	pctl->num_functions = nfuncs;
	ipctl->group_index = 0;
	
	if (flat_funcs) {
		pctl->num_groups = of_get_child_count(np);
	} else {
		pctl->num_groups = 0;
		for_each_child_of_node(np, child)
			pctl->num_groups += of_get_child_count(child);
	}
	
	if (flat_funcs) {
		imx_pinctrl_parse_functions(np, ipctl, 0);
	} else {
		i = 0;
		for_each_child_of_node(np, child)
			imx_pinctrl_parse_functions(child, ipctl, i++);
	}

	
```



#### imx_pinctrl_dt_is_flat_functions()函数

drivers/pinctrl/freescale/pinctrl-imx.c

```
static bool imx_pinctrl_dt_is_flat_functions(struct device_node *np)
{
	struct device_node *function_np;
	struct device_node *pinctrl_np;

	for_each_child_of_node(np, function_np) {
	
		if (of_property_read_bool(function_np, "fsl,pins"))
			return true;
			
		for_each_child_of_node(function_np, pinctrl_np) {
			if (of_property_read_bool(pinctrl_np, "fsl,pins"))
				return false;
		}
	}

	return true;
}
```



#### imx_pinctrl_parse_functions()函数

drivers/pinctrl/freescale/pinctrl-imx.c

iomuxc节点的device_node结构体指针, ipctl, 0

```
static int imx_pinctrl_parse_functions(struct device_node *np,
				       struct imx_pinctrl *ipctl,
				       u32 index)
{
	struct pinctrl_dev *pctl = ipctl->pctl;
	struct device_node *child;
	struct function_desc *func;
	struct group_desc *grp;
	u32 i = 0;
	
	func = pinmux_generic_get_function(pctl, index);
	...
	func->name = np->name;
	func->num_group_names = of_get_child_count(np);
	...
	func->group_names = devm_kcalloc(ipctl->dev, func->num_group_names,
					 sizeof(char *), GFP_KERNEL);
	if (!func->group_names)
		return -ENOMEM;

	for_each_child_of_node(np, child) {
		func->group_names[i] = child->name;

		grp = devm_kzalloc(ipctl->dev, sizeof(struct group_desc),
				   GFP_KERNEL);
		if (!grp)
			return -ENOMEM;

		mutex_lock(&ipctl->mutex);
		radix_tree_insert(&pctl->pin_group_tree,
				  ipctl->group_index++, grp);
		mutex_unlock(&ipctl->mutex);

		imx_pinctrl_parse_groups(child, grp, ipctl, i++);
	}

	return 0;
}
```



#### pinmux_generic_get_function()函数

drivers/pinctrl/pinmux.c

```
struct function_desc *pinmux_generic_get_function(struct pinctrl_dev *pctldev,
						  unsigned int selector)
{
	struct function_desc *function;

	function = radix_tree_lookup(&pctldev->pin_function_tree,
				     selector);
	if (!function)
		return NULL;

	return function;
}
```



#### imx_pinctrl_parse_groups()函数

```
static int imx_pinctrl_parse_groups(struct device_node *np,
				    struct group_desc *grp,
				    struct imx_pinctrl *ipctl,
				    u32 index)
{
	const struct imx_pinctrl_soc_info *info = ipctl->info;
	int size, pin_size;
	const __be32 *list, **list_p;
	u32 config;
	int i;
	
	if (info->flags & IMX8_USE_SCU)
		pin_size = FSL_IMX8_PIN_SIZE;
	else if (info->flags & SHARE_MUX_CONF_REG)
		pin_size = FSL_PIN_SHARE_SIZE;
	else
		pin_size = FSL_PIN_SIZE;//24
	
	grp->name = np->name;
	
	list = of_get_property(np, "fsl,pins", &size);
	...
	list_p = &list;
	...
	/*该组引脚的配置个数*/
	grp->num_pins = size / pin_size;
	
	grp->data = devm_kcalloc(ipctl->dev,
				 grp->num_pins, sizeof(struct imx_pin),
				 GFP_KERNEL);
	
	grp->pins = devm_kcalloc(ipctl->dev,
				 grp->num_pins, sizeof(unsigned int),
				 GFP_KERNEL);
	...
	for (i = 0; i < grp->num_pins; i++) {
		struct imx_pin *pin = &((struct imx_pin *)(grp->data))[i];

		if (info->flags & IMX8_USE_SCU)
			imx_pinctrl_parse_pin_scu(ipctl, &grp->pins[i],
				pin, list_p, config);
		else
			imx_pinctrl_parse_pin_mem(ipctl, &grp->pins[i],
				pin, list_p, config);
	}

	return 0;
}
```

#### imx_pinctrl_parse_pin_mem()函数

drivers/pinctrl/freescale/pinctrl-memmap.c

```
int imx_pinctrl_parse_pin_mem(struct imx_pinctrl *ipctl,
			  unsigned int *grp_pin_id, struct imx_pin *pin,
			  const __be32 **list_p, u32 generic_config)
{
	struct imx_pin_memmap *pin_memmap = &pin->pin_conf.pin_memmap;
	const struct imx_pinctrl_soc_info *info = ipctl->info;
	u32 mux_reg = be32_to_cpu(*((*list_p)++));
	u32 conf_reg;
	u32 config;
	unsigned int pin_id;
	struct imx_pin_reg *pin_reg;
	
	if (info->flags & SHARE_MUX_CONF_REG) {
		conf_reg = mux_reg;
	} else {
		conf_reg = be32_to_cpu(*((*list_p)++));
		if (!conf_reg)
			conf_reg = -1;
	}

	pin_id = (mux_reg != -1) ? mux_reg / 4 : conf_reg / 4;
	pin_reg = &ipctl->pin_regs[pin_id];
	pin->pin = pin_id;
	*grp_pin_id = pin_id;
	pin_reg->mux_reg = mux_reg;
	pin_reg->conf_reg = conf_reg;
	pin_memmap->input_reg = be32_to_cpu(*((*list_p)++));
	pin_memmap->mux_mode = be32_to_cpu(*((*list_p)++));
	pin_memmap->input_val = be32_to_cpu((*(*list_p)++));
	...
	config = be32_to_cpu(*((*list_p)++));
	...
	if (config & IMX_PAD_SION)
		pin_memmap->mux_mode |= IOMUXC_CONFIG_SION;
	pin_memmap->config = config & ~IMX_PAD_SION;
	...
	return 0;
}
```

