## linux设备驱动模型

#### 为什么需要设备驱动模型

- 早期内核（2.4之前）没有统一的设备驱动模型，但照样可以用
- 2.4~2.6期间使用devfs，挂载在/dev目录。
  - 需要在内核驱动中创建设备文件(devfs_register)，命名死板
- 2.6以后使用sysfs，挂载在/sys目录
  - 将设备分类、分层次统一进行管理
  - 配合udev/mdev守护进程动态创建设备文件，命令规则自由制定

#### sysfs概述

linux系统通过sysfs体现出设备驱动模型

- sysfs是一个虚拟文件系统（类似proc文件系统）
- 目录对应的inode节点会记录基本驱动对象(kobject)，从而将系统中的设备组成层次结构
- 用户可以读写目录下的不同文件来配置驱动对象(kobject)的不同属性

#### 设备驱动模型基本元素

- kobject：sysfs中的一个目录，常用来表示基本驱动对象，不允许发送消息到用户空间
- kset：sysfs中的一个目录，常用来管理kobject，允许发送消息到用户空间

- kobj_type：目录下属性文件的操作接口

#### 驱动模型一

![image-20200810194908453](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200810194908453.png)

kset可批量管理kobject

kobject无法批量管理kobject

#### 驱动模型二

![image-20200810195127363](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200810195127363.png)

- 上层kobject节点无法遍历查找下层kobject

#### kobject

sysfs中每一个目录都对应一个kobject

include/linux/kobject.h

```
struct kobject {
	//用来表示该kobject的名称
	const char		*name;
	//链表节点
	struct list_head	entry;
	//该kobject的上层节点，构建kobject之间的层次关系
	struct kobject		*parent;
	//该kobject所属的kset对象，用于批量管理kobject对象
	struct kset		*kset;
	//该Kobject的sysfs文件系统相关的操作和属性
	struct kobj_type	*ktype;
	//该kobject在sysfs文件系统中对应目录项
	struct kernfs_node	*sd; /* sysfs directory entry */
	//该kobject的引用次数
	struct kref		kref;
#ifdef CONFIG_DEBUG_KOBJECT_RELEASE
	struct delayed_work	release;
#endif
	//记录内核对象的初始化状态
	unsigned int state_initialized:1;
	//表示该kobject所代表的内核对象有没有在sysfs建立目录
	unsigned int state_in_sysfs:1;
	unsigned int state_add_uevent_sent:1;
	unsigned int state_remove_uevent_sent:1;
	unsigned int uevent_suppress:1;
};
```

#### kset

```
struct kset {
	//用来将起中的object对象构建成链表
	struct list_head list;
	//自旋锁
	spinlock_t list_lock;
	//当前kset内核对象的kobject变量
	struct kobject kobj;
	//定义了一组函数指针，当kset中的某些kobject对象发生状态变化需要通知用户空间时，调用其中的函数来完成
	const struct kset_uevent_ops *uevent_ops;
}
```

#### kobj_type

```
struct kobj_type {
	//销毁kobject对象时调用
	void (*release)(struct kobject *kobj);
	//kobject对象属性文件统一操作接口
	const struct sysfs_ops *sysfs_ops;
	//kobject默认属性文件的名字、"文件具体操作接口"
	struct attribute **default_attrs;                                                         
	const struct kobj_ns_type_operations *(*child_ns_type)(struct kobject *kobj);
	const void *(*namespace)(struct kobject *kobj);
	void (*get_ownership)(struct kobject *kobj, kuid_t *uid, kgid_t *gid);
};
```

