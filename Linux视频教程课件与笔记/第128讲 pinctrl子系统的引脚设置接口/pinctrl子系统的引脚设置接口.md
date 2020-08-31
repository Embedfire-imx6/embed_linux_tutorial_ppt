## pinctrl子系统的引脚设置接口

#### pinctrl子系统对外接口

##### 状态查询接口

pinctrl_lookup_state

##### 状态设置接口

pinctrl_select_state

##### 状态类型

```
#define PINCTRL_STATE_DEFAULT "default"
#define PINCTRL_STATE_INIT "init"
#define PINCTRL_STATE_IDLE "idle"
#define PINCTRL_STATE_SLEEP "sleep"
```



#### 函数原型

#### pinctrl_lookup_state()函数

drivers/pinctrl/core.c

```
struct pinctrl_state *pinctrl_lookup_state(struct pinctrl *p,
						 const char *name)
{
	struct pinctrl_state *state;

	state = find_state(p, name);
	if (!state) {
		if (pinctrl_dummy_state) {
			/* create dummy state */
			dev_dbg(p->dev, "using pinctrl dummy state (%s)\n",
				name);
			state = create_state(p, name);
		} else
			state = ERR_PTR(-ENODEV);
	}

	return state;
}
```



#### find_state()函数

drivers/pinctrl/core.c

```
static struct pinctrl_state *find_state(struct pinctrl *p,const char *name)
{
	struct pinctrl_state *state;

	list_for_each_entry(state, &p->states, node)
		if (!strcmp(state->name, name))
			return state;

	return NULL;
}
```



#### pinctrl_select_state()函数

drivers/pinctrl/core.c

```
int pinctrl_select_state(struct pinctrl *p, struct pinctrl_state *state)
{
	if (p->state == state)
		return 0;

	return pinctrl_commit_state(p, state);
}
```



#### pinctrl_commit_state()函数

drivers/pinctrl/core.c

```
static int pinctrl_commit_state(struct pinctrl *p, struct pinctrl_state *state)
{
	struct pinctrl_setting *setting, *setting2;
	struct pinctrl_state *old_state = p->state;
	int ret;
	
	...
	
	list_for_each_entry(setting, &state->settings, node) {
		switch (setting->type) {
		case PIN_MAP_TYPE_MUX_GROUP:
			ret = pinmux_enable_setting(setting);
			break;
		case PIN_MAP_TYPE_CONFIGS_PIN:
		case PIN_MAP_TYPE_CONFIGS_GROUP:
			ret = pinconf_apply_setting(setting);
			break;
		default:
			ret = -EINVAL;
			break;
		}
	
	
```



#### pinmux_enable_setting()函数

```
int pinmux_enable_setting(const struct pinctrl_setting *setting)
{
	struct pinctrl_dev *pctldev = setting->pctldev;
	const struct pinctrl_ops *pctlops = pctldev->desc->pctlops;
	const struct pinmux_ops *ops = pctldev->desc->pmxops;
	int ret = 0;
	const unsigned *pins = NULL;
	unsigned num_pins = 0;
	int i;
	struct pin_desc *desc;
	
	if (pctlops->get_group_pins)
		ret = pctlops->get_group_pins(pctldev, setting->data.mux.group,&pins, &num_pins);

	...
	ret = ops->set_mux(pctldev, setting->data.mux.func,
			   setting->data.mux.group);
	...
}
```



#### pinctrl_generic_get_group_pins()函数

drivers/pinctrl/pinmux.c

```
int pinctrl_generic_get_group_pins(struct pinctrl_dev *pctldev,
				   unsigned int selector,
				   const unsigned int **pins,
				   unsigned int *num_pins)
{
	struct group_desc *group;

	group = radix_tree_lookup(&pctldev->pin_group_tree,
				  selector);
	if (!group) {
		dev_err(pctldev->dev, "%s could not find pingroup%i\n",
			__func__, selector);
		return -EINVAL;
	}

	*pins = group->pins;
	*num_pins = group->num_pins;

	return 0;
}
```

#### imx_pmx_set()函数

drivers/pinctrl/freescale/pinctrl-imx.c

```
static int imx_pmx_set(struct pinctrl_dev *pctldev, unsigned selector,unsigned group)
{
	struct imx_pinctrl *ipctl = pinctrl_dev_get_drvdata(pctldev);
	unsigned int npins;
	const struct imx_pinctrl_soc_info *info = ipctl->info;
	int i, err;
	struct group_desc *grp = NULL;
	struct function_desc *func = NULL;

	/*
	 * Configure the mux mode for each pin in the group for a specific
	 * function.
	 */
	grp = pinctrl_generic_get_group(pctldev, group);
	if (!grp)
		return -EINVAL;

	func = pinmux_generic_get_function(pctldev, selector);
	if (!func)
		return -EINVAL;

	npins = grp->num_pins;

	dev_dbg(ipctl->dev, "enable function %s group %s\n",
		func->name, grp->name);

	for (i = 0; i < npins; i++) {
		struct imx_pin *pin = &((struct imx_pin *)(grp->data))[i];
		if (info->flags & IMX8_USE_SCU)
			err = imx_pmx_set_one_pin_scu(ipctl, pin);
		else
			err = imx_pmx_set_one_pin_mem(ipctl, pin);
		if (err)
			return err;
	}

	return 0;
}
```



#### imx_pmx_set_one_pin_mem()函数

drivers/pinctrl/freescale/pinctrl-memmap.c

```
int imx_pmx_set_one_pin_mem(struct imx_pinctrl *ipctl, struct imx_pin *pin)
{
	const struct imx_pinctrl_soc_info *info = ipctl->info;
	unsigned int pin_id = pin->pin;
	struct imx_pin_reg *pin_reg;
	struct imx_pin_memmap *pin_memmap;
	pin_reg = &ipctl->pin_regs[pin_id];
	pin_memmap = &pin->pin_conf.pin_memmap;
	
	if (info->flags & SHARE_MUX_CONF_REG) {
		u32 reg;
		reg = readl(ipctl->base + pin_reg->mux_reg);
		reg &= ~info->mux_mask;
		reg |= (pin_memmap->mux_mode << info->mux_shift);
		writel(reg, ipctl->base + pin_reg->mux_reg);
		dev_dbg(ipctl->dev, "write: offset 0x%x val 0x%x\n",
			pin_reg->mux_reg, reg);
	} else {
		writel(pin_memmap->mux_mode, ipctl->base + pin_reg->mux_reg);
		dev_dbg(ipctl->dev, "write: offset 0x%x val 0x%x\n",
			pin_reg->mux_reg, pin_memmap->mux_mode);
	}
	...
 }
```







