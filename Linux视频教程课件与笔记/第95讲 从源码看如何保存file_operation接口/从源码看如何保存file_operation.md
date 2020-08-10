## 从源码看如何保存file_operation接口

#### 关键数据结构梳理

kernel/ebf-buster-linux/include/linux/cdev.h

字符设备管理对象

```
struct cdev {
	//内核驱动基本对象
    struct kobject kobj;
	//相关内核模块
    struct module *owner;
	//设备驱动接口
    const struct file_operations *ops;
	//链表节点
    struct list_head list;
	//设备号
    dev_t dev;
	//次设备号的数量
    unsigned int count;

} __randomize_layout;
```



ebf-buster-linux/fs/char_dev.c

哈希表probes

```
struct kobj_map {
	struct probe {
		//指向下一个链表节点
		struct probe *next;
		//设备号
		dev_t dev;
		//次设备号的数量
		unsigned long range;
		struct module *owner;
		kobj_probe_t *get;
		int (*lock)(dev_t, void *);
		//空指针，内核常用技巧
		void *data;
	} *probes[255];
	struct mutex *lock;
};
```

#### cdev_init函数分析

ebf-buster-linux/fs/char_dev.c

保存file_operation到cdev中

#### cdev_add函数分析

ebf-buster-linux/fs/char_dev.c

根据哈希函数保存cdev到probes哈希表中，方便内核查找file_operation使用







