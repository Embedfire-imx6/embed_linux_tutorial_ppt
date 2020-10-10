## xbus：打造自属的驱动总线

#### 驱动总线

软件与硬件代码分离，提高程序的复用性

- device--关联硬件代码
- driver_devices--关联软件代码
- bus_type--统一管理、设置match匹配规则

设备驱动模型体现分离思想

- bus-xbus-devices-drivers

#### 总线管理

##### buses_init()函数

内核启动执行

/sys/bus

```
int __init buses_init(void)
{
	bus_kset = kset_create_and_add("bus", &bus_uevent_ops, NULL);
	if (!bus_kset)
		return -ENOMEM;

	system_kset = kset_create_and_add("system", NULL, &devices_kset->kobj);
	if (!system_kset)
		return -ENOMEM;

	return 0;
}
```

#### 总线注册

##### bus_register()函数

添加新的总线类型

```
int bus_register(struct bus_type *bus)
```

- 在/sys/bus下建立xbus目录项，并创建属性文件
- 在/sys/bus/xbus下建立devices目录项，并创建属性文件
- 在/sys/bus/xbus下建立drivers目录项，并创建属性文件
- 初始化 priv->klist_devices链表头
- 初始化priv->klist_drivers链表头

#### 设备注册

##### device_register()函数 

添加设备，关联硬件相关代码

```
int device_register(struct device *dev)
```

- 在/sys/bus/xbus/devices下建立yyy目录项
- 加入bus-> priv->devices_kset链表
- 加入bus-> priv->klist_devices链表
- 遍历bus-> priv->klist_drivers，执行bus->match()寻找合适的drv
- dev关联driv，执行drv->probe()

#### 驱动注册

##### driver_register()函数

添加驱动，关联软件相关代码

```
int driver_register(struct device_driver *drv)
```

- 在/sys/bus/xbus/drivers下建立zzz目录项
- 加入bus-> priv->drivers_kset链表
- 加入bus-> priv->klist_drivers链表
- 遍历bus-> priv->klist_klist_devices链表，执行bus->match()寻找合适的dev
- dev关联dev，执行drv->probe()

#### 设备驱动模型框图

![image-20200816074416328](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200816074416328.png)

#### 