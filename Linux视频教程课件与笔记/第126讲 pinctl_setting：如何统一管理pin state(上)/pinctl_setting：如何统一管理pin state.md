## pinctl_setting：如何统一管理pin state

#### pinctl_map

- 保存了所有pin state所需要的pin group信息

#### pinctl_setting

- 把pin group信息按pin state分类保存

#### 目的

- pinctl_map->pinctl_setting



#### for_each_maps()宏

drivers/pinctrl/core.h

```
#define for_each_maps(_maps_node_, _i_, _map_) \
	list_for_each_entry(_maps_node_, &pinctrl_maps, node) \
		for (_i_ = 0, _map_ = &_maps_node_->maps[_i_]; \
			_i_ < _maps_node_->num_maps; \
			_i_++, _map_ = &_maps_node_->maps[_i_])
```



#### add_setting()函数

drivers/pinctrl/core.c

```
static int add_setting(struct pinctrl *p, struct pinctrl_dev *pctldev,
		       const struct pinctrl_map *map)
{	
	struct pinctrl_state *state;
	struct pinctrl_setting *setting;
	
	state = find_state(p, map->name);
	if (!state)
		state = create_state(p, map->name);
	...
	setting = kzalloc(sizeof(*setting), GFP_KERNEL);
	if (!setting)
		return -ENOMEM;

	setting->type = map->type;

	if (pctldev)
		setting->pctldev = pctldev;
	else
		setting->pctldev =
			get_pinctrl_dev_from_devname(map->ctrl_dev_name);
	
    setting->dev_name = map->dev_name;
    
    switch (map->type) {
	case PIN_MAP_TYPE_MUX_GROUP:
		ret = pinmux_map_to_setting(map, setting);
		break;
	case PIN_MAP_TYPE_CONFIGS_PIN:
	case PIN_MAP_TYPE_CONFIGS_GROUP:
		ret = pinconf_map_to_setting(map, setting);
		break;
	default:
		ret = -EINVAL;
		break;
	}
	...
	list_add_tail(&setting->node, &state->settings);
	
	return 0;
}
```



#### find_state()函数

drivers/pinctrl/core.c

```
static struct pinctrl_state *find_state(struct pinctrl *p,
					const char *name)
{
	struct pinctrl_state *state;

	list_for_each_entry(state, &p->states, node)
		if (!strcmp(state->name, name))
			return state;

	return NULL;
}
```



#### create_state()函数

drivers/pinctrl/core.c

```
static struct pinctrl_state *create_state(struct pinctrl *p,const char *name)
{
	struct pinctrl_state *state;

	state = kzalloc(sizeof(*state), GFP_KERNEL);
	if (!state)
		return ERR_PTR(-ENOMEM);

	state->name = name;
	INIT_LIST_HEAD(&state->settings);

	list_add_tail(&state->node, &p->states);

	return state;
}
```



#### pinmux_map_to_setting()函数

drivers/pinctrl/pinmux.c

```
int pinmux_map_to_setting(const struct pinctrl_map *map,struct pinctrl_setting *setting)
{
	struct pinctrl_dev *pctldev = setting->pctldev;
	//imx_pmx_ops
	const struct pinmux_ops *pmxops = pctldev->desc->pmxops;
	char const * const *groups;
	unsigned num_groups;
	int ret;
	const char *group;
	...
	ret = pinmux_func_name_to_selector(pctldev, map->data.mux.function);
	...
	/*function的索引*/
	setting->data.mux.func = ret;
	
	ret = pmxops->get_function_groups(pctldev, setting->data.mux.func,&groups, &num_groups);
	
	if (map->data.mux.group) {
		//group节点名
		group = map->data.mux.group;
		ret = match_string(groups, num_groups, group);
		...
		}
	} else {
		group = groups[0];
	}
	
	ret = pinctrl_get_group_selector(pctldev, group);
	...
	setting->data.mux.group = ret;
	...
}
	
```



#### pinmux_func_name_to_selector()函数

drivers/pinctrl/pinmux.c

```
static int pinmux_func_name_to_selector(struct pinctrl_dev *pctldev,
					const char *function)
{
	const struct pinmux_ops *ops = pctldev->desc->pmxops;
	//imx_pmx_ops
	unsigned nfuncs = ops->get_functions_count(pctldev);
	unsigned selector = 0;

	while (selector < nfuncs) {
		const char *fname = ops->get_function_name(pctldev, selector);

		if (!strcmp(function, fname))
			return selector;

		selector++;
	}

	return -EINVAL;
}
```



#### pinmux_generic_get_function_count()函数

drivers/pinctrl/pinmux.c

```
int pinmux_generic_get_function_count(struct pinctrl_dev *pctldev)
{
	return pctldev->num_functions;
}
```



#### pinmux_generic_get_function_name()函数

drivers/pinctrl/pinmux.c

```
const char * pinmux_generic_get_function_name(struct pinctrl_dev *pctldev,
				 unsigned int selector)
{
	struct function_desc *function;

	function = radix_tree_lookup(&pctldev->pin_function_tree,
				     selector);
	if (!function)
		return NULL;

	return function->name;
}
```



#### pinmux_generic_get_function_groups()函数

drivers/pinctrl/pinmux.c

```
int pinmux_generic_get_function_groups(struct pinctrl_dev *pctldev,
				       unsigned int selector,
				       const char * const **groups,
				       unsigned * const num_groups)
{
	struct function_desc *function;

	function = radix_tree_lookup(&pctldev->pin_function_tree,selector);
	if (!function) {
		dev_err(pctldev->dev, "%s could not find function%i\n",__func__, selector);
		return -EINVAL;
	}
	*groups = function->group_names;
	*num_groups = function->num_group_names;

	return 0;
}
```



#### pinctrl_get_group_selector()函数

drivers/pinctrl/core.c

```
int pinctrl_get_group_selector(struct pinctrl_dev *pctldev,const char *pin_group)
{
	const struct pinctrl_ops *pctlops = pctldev->desc->pctlops;
	unsigned ngroups = pctlops->get_groups_count(pctldev);
	unsigned group_selector = 0;

	while (group_selector < ngroups) {
		const char *gname = pctlops->get_group_name(pctldev,
							    group_selector);
		if (gname && !strcmp(gname, pin_group)) {
			dev_dbg(pctldev->dev,
				"found group selector %u for %s\n",
				group_selector,
				pin_group);
			return group_selector;
		}

		group_selector++;
	}

	dev_err(pctldev->dev, "does not have pin group %s\n",
		pin_group);

	return -EINVAL;
}
```



#### pinctrl_generic_get_group_count()函数

```
int pinctrl_generic_get_group_count(struct pinctrl_dev *pctldev)
{
	return pctldev->num_groups;
}
```



#### pinctrl_generic_get_group_name()函数

```
const char *pinctrl_generic_get_group_name(struct pinctrl_dev *pctldev,
					   unsigned int selector)
{
	struct group_desc *group;

	group = radix_tree_lookup(&pctldev->pin_group_tree,
				  selector);
	if (!group)
		return NULL;

	return group->name;
}
```





#### pinconf_map_to_setting()函数

```
int pinconf_map_to_setting(const struct pinctrl_map *map,
			  struct pinctrl_setting *setting)
{
	struct pinctrl_dev *pctldev = setting->pctldev;
	int pin;

	switch (setting->type) {
	case PIN_MAP_TYPE_CONFIGS_PIN:
		pin = pin_get_from_name(pctldev,
					map->data.configs.group_or_pin);
		if (pin < 0) {
			dev_err(pctldev->dev, "could not map pin config for \"%s\"",
				map->data.configs.group_or_pin);
			return pin;
		}
		setting->data.configs.group_or_pin = pin;
		break;
		...
	}
	setting->data.configs.num_configs = map->data.configs.num_configs;
	setting->data.configs.configs = map->data.configs.configs;
	...
}
    
```



