## 获取DTS属性信息

- 查属性所在的节点
- 查节点的属性值

#### 节点表示

![1597740638102](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1597740638102.png)

/include/linux/of.h

```
struct device_node {
    const char *name;  //节点名
    const char *type;  //设备类型
    phandle phandle;
    const char *full_name; //完整名字
    struct fwnode_handle fwnode;
   
    struct  property *properties; //属性
    struct  property *deadprops; 
    struct  device_node *parent; //父节点
    struct  device_node *child;  //子节点
    struct  device_node *sibling;
#if defined(CONFIG_OF_KOBJ)
    struct  kobject kobj;
#endif
    unsigned long _flags;
    void    *data;
#if defined(CONFIG_SPARC)
    const char *path_component_name;
    unsigned int unique_id;
    struct of_irq_controller *irq_trans;
#endif
};
```

#### 查节点

- 路径/类型/名字/compatible

 incldue/linux/of.h

##### of_find_node_by_path()函数

根据路径找到节点

```
struct device_node *of_find_node_by_path(struct device_node *from,const char *path);
```

参数：

- from：开始查找的节点，NULL表示从根节点开始查找
- path：查找的节点名

返回值：

成功：device_node表示的节点

失败：NULL

##### of_find_node_by_type()函数

根据“device_type“属性来查找节点

```
struct device_node *of_find_node_by_type(struct device_node *from, const char *type);
```

不建议使用

##### of_find_node_by_name()函数

根据"name"属性来查找节点

```
struct device_node *of_find_node_by_name(struct device_node *from,const char *name);
```

不建议使用

##### of_find_compatible_node()函数

```
struct device_node *of_find_compatible_node(struct device_node *from,const char *type, const char *compat);
```

参数：

- from：开始查找的节点，NULL表示从根节点开始查找
- type：指定 device_type 属性值
- compat：指定 compatible 属性值

返回值：

成功：device_node表示的节点

失败：NULL

#### 查节点的属性值

 incldue/linux/of.h

```
struct property {
    char    *name;  	//属性名
    int     length;     //属性长度
    void    *value; 	//属性值
    struct property *next; //下一个属性
#if defined(CONFIG_OF_DYNAMIC) || defined(CONFIG_SPARC)
    unsigned long _flags;
#endif
#if defined(CONFIG_OF_PROMTREE)
    unsigned int unique_id;
#endif
#if defined(CONFIG_OF_KOBJ)
    struct bin_attribute attr;
#endif
};
```

##### of_find_property()函数

- 节点+属性名

查找节点中的属性

```
struct property *of_find_property(const struct device_node *np,const char *name,int *lenp);
```

参数：

- np：device_node表示的节点
- name：查找的属性名字
- lenp：属性值的字节数

返回值：

成功：property表示的属性

失败：NULL

###### 案例：

```
test_property {
test_name = “hello”;
};
```

name：“hello”

lenp = 6

##### of_property_read_u32()函数

读取一个32位无符号整数

```
static inline int of_property_read_u32(const struct device_node *np,const char *propname,
u32 *out_value);
```

参数：

- np：device_node表示的节点
- propname：查找的属性名字
- out_value：属性值的整数值

返回值：

成功：0

失败：负值

##### of_property_read_u32_array()函数

读取32位无符号整数数组

```
int of_property_read_u32_array(const struct device_node *np,const char *propname,u32 *out_values,size_t sz)
```

- np：device_node表示的节点
- name：查找的属性名字
- out_value：读取到的数组值
- sz ：要读取的数组元素数量

##### of_property_read_string()函数

读字符串

```
int of_property_read_string(struct device_node *np,const char *propname,const char **out_string)
```

参数：

- np：device_node表示的节点
- proname：查找的属性名字
- out_string：读取到的字符串值

返回值：

成功：0

失败：负值