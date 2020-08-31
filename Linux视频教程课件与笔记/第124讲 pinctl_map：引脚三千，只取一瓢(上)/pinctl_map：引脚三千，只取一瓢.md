## pinctl_map：引脚三千，只取一瓢

#### pinctrl_map数组

- pin group配置信息

  - pinctrl_map[0]：配置pin group的所有引脚复用

  - pinctrl_map[1~n]：配置pin group的每个引脚的属性

#### 函数层次分析

pinctrl_enable()->pinctrl_claim_hogs()

- create_pinctrl

  ----------------------------------------------第一部分-------------------------------------

  - pinctrl_dt_to_map()

    - for (state = 0; ; state++)：查找外设所有pin group的状态

      - for (config = 0; config < size; config++)：查找状态的所有引脚组

        ------------------------------第二部分-------------------------------------

        - dt_to_map_one_config

          - 创建一个pinctrl_map，负责初始化配置pin group的所有引脚复用

          - 创建多个pinctrl_map，每个pinctrl_map负责配置引脚中的一个引脚属性

  ----------------------------------------------第三部分-------------------------------------

  - add_setting

#### imx_dt_node_to_map()函数

drivers/pinctrl/freescale/pinctrl-imx.c

```
static int imx_dt_node_to_map(struct pinctrl_dev *pctldev,
			struct device_node *np,
			struct pinctrl_map **map, unsigned *num_maps)
{
	struct imx_pinctrl *ipctl = pinctrl_dev_get_drvdata(pctldev);
	const struct imx_pinctrl_soc_info *info = ipctl->info;
	const struct group_desc *grp;
	struct pinctrl_map *new_map;
	struct device_node *parent;
	int map_num = 1;
	int i, j;
	
	grp = imx_pinctrl_find_group_by_name(pctldev, np->name);
	
	if (info->flags & IMX8_USE_SCU) {
		map_num += grp->num_pins;
	} else {
		for (i = 0; i < grp->num_pins; i++) {
			struct imx_pin *pin = &((struct imx_pin *)(grp->data))[i];

			if (!(pin->pin_conf.pin_memmap.config & IMX_NO_PAD_CTL))
				map_num++;
		}
	}
	
	new_map = kmalloc_array(map_num, sizeof(struct pinctrl_map),
				GFP_KERNEL);
				
	*map = new_map;
	*num_maps = map_num;
	
	 /*iomuxc节点*/
	 parent = of_get_parent(np);
	 ...
	 new_map[0].type = PIN_MAP_TYPE_MUX_GROUP;
	 new_map[0].data.mux.function = parent->name;
	 new_map[0].data.mux.group = np->name;
	 ..
	 new_map++;
	 
	 for (i = j = 0; i < grp->num_pins; i++) {
		struct imx_pin *pin = &((struct imx_pin *)(grp->data))[i];

		if (info->flags & IMX8_USE_SCU) {
			new_map[j].type = PIN_MAP_TYPE_CONFIGS_PIN;
			new_map[j].data.configs.group_or_pin =
					pin_get_name(pctldev, pin->pin);
			new_map[j].data.configs.configs =
					(unsigned long *)&pin->pin_conf.pin_scu;
			new_map[j].data.configs.num_configs = 2;
			j++;
		} else if (!(pin->pin_conf.pin_memmap.config & IMX_NO_PAD_CTL)) {
			new_map[j].type = PIN_MAP_TYPE_CONFIGS_PIN;
			new_map[j].data.configs.group_or_pin =
					pin_get_name(pctldev, pin->pin);
			new_map[j].data.configs.configs =
					&pin->pin_conf.pin_memmap.config;
			new_map[j].data.configs.num_configs = 1;
			j++;
		}
	}
	...
}
```



#### imx_pinctrl_find_group_by_name()函数

```
static inline const struct group_desc *imx_pinctrl_find_group_by_name(
				struct pinctrl_dev *pctldev,
				const char *name)
{
	const struct group_desc *grp = NULL;
	int i;

	for (i = 0; i < pctldev->num_groups; i++) {
		grp = pinctrl_generic_get_group(pctldev, i);
		if (grp && !strcmp(grp->name, name))
			break;
	}

	return grp;
}
```



#### pinctrl_generic_get_group()函数

drivers/pinctrl/core.c

```
struct group_desc *pinctrl_generic_get_group(struct pinctrl_dev *pctldev,
					     unsigned int selector)
{
	struct group_desc *group;

	group = radix_tree_lookup(&pctldev->pin_group_tree,
				  selector);
	if (!group)
		return NULL;

	return group;
}
```



#### pin_get_name()函数

drivers/pinctrl/core.c

```
const char *pin_get_name(struct pinctrl_dev *pctldev, const unsigned pin)
{
	const struct pin_desc *desc;

	desc = pin_desc_get(pctldev, pin);
	if (!desc) {
		dev_err(pctldev->dev, "failed to get pin(%d) name\n",
			pin);
		return NULL;
	}

	return desc->name;
}
```



#### pin_desc_get函数

drivers/pinctrl/core.h

```
static inline struct pin_desc *pin_desc_get(struct pinctrl_dev *pctldev,
					    unsigned int pin)
{
	return radix_tree_lookup(&pctldev->pin_desc_tree, pin);
}
```



#### dt_remember_or_free_map()函数

drivers/pinctrl/devicetree.c

```
static int dt_remember_or_free_map(struct pinctrl *p, const char *statename,struct pinctrl_dev *pctldev,struct pinctrl_map *map, unsigned num_maps)
{
	int i;
	struct pinctrl_dt_map *dt_map;

	/* Initialize common mapping table entry fields */
	for (i = 0; i < num_maps; i++) {
		map[i].dev_name = dev_name(p->dev);
		map[i].name = statename;
		if (pctldev)
			map[i].ctrl_dev_name = dev_name(pctldev->dev);
	}

	/* Remember the converted mapping table entries */
	dt_map = kzalloc(sizeof(*dt_map), GFP_KERNEL);
	if (!dt_map) {
		dt_free_map(pctldev, map, num_maps);
		return -ENOMEM;
	}

	dt_map->pctldev = pctldev;
	dt_map->map = map;
	dt_map->num_maps = num_maps;
	list_add_tail(&dt_map->node, &p->dt_maps);

	return pinctrl_register_map(map, num_maps, false);
}
```



#### pinctrl_register_map()函数

drivers/pinctrl/core.c

```
int pinctrl_register_map(const struct pinctrl_map *maps, unsigned num_maps,
			 bool dup)
{
	int i, ret;
	struct pinctrl_maps *maps_node;
	
	for (i = 0; i < num_maps; i++) {
	
	switch (maps[i].type) {
		case PIN_MAP_TYPE_DUMMY_STATE:
			break;
		case PIN_MAP_TYPE_MUX_GROUP:
			ret = pinmux_validate_map(&maps[i], i);
			if (ret < 0)
				return ret;
			break;
		case PIN_MAP_TYPE_CONFIGS_PIN:
		case PIN_MAP_TYPE_CONFIGS_GROUP:
			ret = pinconf_validate_map(&maps[i], i);
			if (ret < 0)
				return ret;
			break;
		default:
			pr_err("failed to register map %s (%d): invalid type given\n",
			       maps[i].name, i);
			return -EINVAL;
		}
	}
	
	maps_node = kzalloc(sizeof(*maps_node), GFP_KERNEL);
	maps_node->num_maps = num_maps;
	
	if (dup) {
		maps_node->maps = kmemdup(maps, sizeof(*maps) * num_maps,
					  GFP_KERNEL);
		if (!maps_node->maps) {
			kfree(maps_node);
			return -ENOMEM;
		}
	} else {
		maps_node->maps = maps;
	}
	...
	list_add_tail(&maps_node->node, &pinctrl_maps);
	...
}
```



#### pinmux_validate_map()函数

drivers/pinctrl/pinmux.c

```
int pinmux_validate_map(const struct pinctrl_map *map, int i)
{
	if (!map->data.mux.function) {
		pr_err("failed to register map %s (%d): no function given\n",
		       map->name, i);
		return -EINVAL;
	}

	return 0;
}
```



#### pinconf_validate_map()函数

drivers/pinctrl/pinmux.c

```
int pinconf_validate_map(const struct pinctrl_map *map, int i)
{
	if (!map->data.configs.group_or_pin) {
		pr_err("failed to register map %s (%d): no group/pin given\n",
		       map->name, i);
		return -EINVAL;
	}

	if (!map->data.configs.num_configs ||
			!map->data.configs.configs) {
		pr_err("failed to register map %s (%d): no configs given\n",
		       map->name, i);
		return -EINVAL;
	}

	return 0;
}
```

