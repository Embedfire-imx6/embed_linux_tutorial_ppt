## class：设备的大管家

- 硬件设备分类管理
- 与udev协作，自动创建设备文件

![image-20200815193421507](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200815193421507.png)

#### 创建一个class

include/linux/device.h

##### class_create宏

````
#define class_create(owner, name)		\
({										\
	static struct lock_class_key __key;	\
	__class_create(owner, name, &__key);\
})
````

- owner：一般设置为THIS_MODULE
- name：kobject对象的名字

```
struct class *__class_create(struct module *owner, const char *name,
			     struct lock_class_key *key)
```

- struct class里面"继承"了kobject对象

#### 在class下添加kobject对象

include/linux/device.h

##### device_create()函数

```
struct device *device_create(struct class *class, struct device *parent,
			     dev_t devt, void *drvdata, const char *fmt, ...)
```

- class：新构建的class

- parent：新kobject对象的上一层节点，一般为NULL
- dev_t：属性文件记录该设备号
- drvdata：私有数据，一般为NULL
- fmt：变参参数，一般用来设置kobject对象的名字