## pin state：pinctrl-names的真相

#### iomuxc节点

- 存储全部所需的引脚配置信息
- "虚拟"外设
  - 设置pin state数量和类型
  - 设置状态对应的pin group

pin state->pin group，一对多

pin group->pin，一对多

#### pinctl_map 

存储外设所有state下pin group的配置信息

#### 函数层次分析

pinctrl_enable()->pinctrl_claim_hogs()

- create_pinctrl

  ----------------------------------------------第一部分-------------------------------------

  - pinctrl_dt_to_map()

    - for (state = 0; ; state++)：查找外设所有pin group的状态

      - for (config = 0; config < size; config++)：查找状态的所有引脚组

        ------------------------------第二部分-------------------------------------

        - dt_to_map_one_config

          - 创建一个pinctrl_map，负责初始化引脚组的所有引脚复用

          - 创建多个pinctrl_map，每个pinctrl_map负责配置引脚中的一个引脚属性

  ----------------------------------------------第三部分-------------------------------------

  - add_setting

#### pinctrl_enable()函数

drivers/pinctrl/core.c

```
int pinctrl_enable(struct pinctrl_dev *pctldev)
{
	int error;

	error = pinctrl_claim_hogs(pctldev);
	...
	//将pctldev加入全局链表
	list_add_tail(&pctldev->node, &pinctrldev_list);
	...
	return 0;
}
```

#### pinctrl_claim_hogs()函数

drivers/pinctrl/core.c

```
static int pinctrl_claim_hogs(struct pinctrl_dev *pctldev)
{
	
	pctldev->p = create_pinctrl(pctldev->dev, pctldev);
	
	//第四部分
	pctldev->hog_default =
		pinctrl_lookup_state(pctldev->p, PINCTRL_STATE_DEFAULT);
	if (IS_ERR(pctldev->hog_default)) {
		dev_dbg(pctldev->dev,
			"failed to lookup the default state\n");
	} else {
		//设置为default状态
		if (pinctrl_select_state(pctldev->p,
					 pctldev->hog_default))
			dev_err(pctldev->dev,
				"failed to select default state\n");
	}
	...
	pctldev->hog_sleep =
		pinctrl_lookup_state(pctldev->p,
		
	...
}
```

#### create_pinctrl()函数

drivers/pinctrl/core.c

```
static struct pinctrl *create_pinctrl(struct device *dev,
				      struct pinctrl_dev *pctldev)
{
	struct pinctrl *p;
	const char *devname;
	struct pinctrl_maps *maps_node;
	int i;
	const struct pinctrl_map *map;
	int ret;
	
	p = kzalloc(sizeof(*p), GFP_KERNEL);
	...
	p->dev = dev;
	INIT_LIST_HEAD(&p->states);
	INIT_LIST_HEAD(&p->dt_maps);
	//第一部分
	ret = pinctrl_dt_to_map(p, pctldev);
	
	devname = dev_name(dev);
	...
	for_each_maps(maps_node, i, map) {
		/* Map must be for this device */
		if (strcmp(map->dev_name, devname))
			continue;
			
        if (pctldev &&
            strcmp(dev_name(pctldev->dev), map->ctrl_dev_name))
            continue;
		//第三部分
		ret = add_setting(p, pctldev, map);
		...
	}
	...
	list_add_tail(&p->node, &pinctrl_list);
	...
}
```

#### pinctrl_dt_to_map()函数

drivers/pinctrl/devicetree.c

```
int pinctrl_dt_to_map(struct pinctrl *p, struct pinctrl_dev *pctldev)
{
	/*iomux节点*/
	struct device_node *np = p->dev->of_node;
	int state, ret;
	char *propname;
	struct property *prop;
	const char *statename;
	const __be32 *list;
	int size, config;
	phandle phandle;
	struct device_node *np_config;
	
	...
	for (state = 0; ; state++) {
		propname = kasprintf(GFP_KERNEL, "pinctrl-%d", state);
		prop = of_find_property(np, propname, &size);
		kfree(propname);
		
		if (!prop) {
			if (state == 0) {
				of_node_put(np);
				return -ENODEV;
			}
			break;
		}
		list = prop->value;
		//获取当前state中的group数量
		size /= sizeof(*list);
		
		ret = of_property_read_string_index(np, "pinctrl-names",state, &statename);
		...
		for (config = 0; config < size; config++) {
		//句柄
		phandle = be32_to_cpup(list++);
		//根据句柄查找子节点
		np_config = of_find_node_by_phandle(phandle);

		ret = dt_to_map_one_config(p, pctldev, statename,
						   np_config);
		...
		}
   ...
}
```

#### dt_to_map_one_config()函数

drivers/pinctrl/devicetree.c

```
static int dt_to_map_one_config(struct pinctrl *p,
				struct pinctrl_dev *hog_pctldev,
				const char *statename,
				struct device_node *np_config)
{
	struct pinctrl_dev *pctldev = NULL;
	struct device_node *np_pctldev;
	const struct pinctrl_ops *ops;
	int ret;
	struct pinctrl_map *map;
	unsigned num_maps;
	bool allow_default = false;
	
	np_pctldev = of_node_get(np_config);
	
	for (;;) {
	/*iomuxc节点*/	
	np_pctldev = of_get_next_parent(np_pctldev);

	if (hog_pctldev && (np_pctldev == p->dev->of_node)) {
			pctldev = hog_pctldev;
			break;
		}
	
	pctldev = get_pinctrl_dev_from_of_node(np_pctldev);
	
	if (pctldev)
		break;
	}
	...
	//imx_pctrl_ops
	ops = pctldev->desc->pctlops;
	...
	//imx_dt_node_to_map
	ret = ops->dt_node_to_map(pctldev, np_config, &map, &num_maps);
	...
	return dt_remember_or_free_map(p, statename, pctldev, map, num_maps);
}
```

#### of_node_get()函数

include/linux/of.h

```
static inline struct device_node *of_node_get(struct device_node *node)
{
	return node;
}
```

