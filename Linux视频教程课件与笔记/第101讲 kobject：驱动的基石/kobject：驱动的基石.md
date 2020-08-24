## kobject：驱动的基石

- 构建一个kobject对象 
- 构建一个sysfs中的目录项(kernfs_node)
- 把他们关联起来

#### 重点

- 关注sysfs目录项与kobject对象的关联过程
- 关注kobject对象默认的属性文件操作接口

#### kobject_create_and_add()函数

lib/kobject.c

```
struct kobject *kobject_create_and_add(const char *name, struct kobject *parent)
{
	struct kobject *kobj;
	int retval;
	/*创建并初始化一个kobject对象*/
	kobj = kobject_create();
	if (!kobj)
		return NULL;
	/*sysfs创建一个目录项并与kobject对象关联*/
	retval = kobject_add(kobj, parent, "%s", name);
	if (retval) {
		pr_warn("%s: kobject_add error: %d\n", __func__, retval);
		kobject_put(kobj);
		kobj = NULL;
	}
	return kobj;
}
```



#### kobject_create()函数

lib/kobject.c

```
struct kobject *kobject_create(void)
{
	struct kobject *kobj;
	/*动态申请内存，存放kobject对象*/
	kobj = kzalloc(sizeof(*kobj), GFP_KERNEL);
	if (!kobj)
		return NULL;
	
	kobject_init(kobj, &dynamic_kobj_ktype);
	return kobj;
}
```



```
static struct kobj_type dynamic_kobj_ktype = {
	.release	= dynamic_kobj_release,
	.sysfs_ops	= &kobj_sysfs_ops,
};
```



```
const struct sysfs_ops kobj_sysfs_ops = {
	.show	= kobj_attr_show,
	.store	= kobj_attr_store,
};
```



##### kobject_init()函数

lib/kobject.c

```
void kobject_init(struct kobject *kobj, struct kobj_type *ktype)
{
...
	kobject_init_internal(kobj);
	/*设置目录属性文件的操作接口*/
	kobj->ktype = ktype;
	return;
...
}
```

##### kobject_init_internal()函数

lib/kobject.c

```
static void kobject_init_internal(struct kobject *kobj)
{
	if (!kobj)
		return;\
	/*将kobject的引用计数设置为1*/
	kref_init(&kobj->kref);
	/*初始化链表节点*/
	INIT_LIST_HEAD(&kobj->entry);
	/*该kobject对象还没和sysfs目录项关联*/
	kobj->state_in_sysfs = 0;
	kobj->state_add_uevent_sent = 0;
	kobj->state_remove_uevent_sent = 0;
	/*kobject对象的初始化标志*/
	kobj->state_initialized = 1;
}
```

#### kobject_add()函数

lib/kobject.c

retval = kobject_add(kobj, parent, "%s", name);

```
int kobject_add(struct kobject *kobj, struct kobject *parent,const char *fmt, ...)
{
	va_list args;
	int retval;
...
	/*获取第一个可变参数，可变参数函数的实现与函数传参的栈结构有关*/
	va_start(args, fmt);
	retval = kobject_add_varg(kobj, parent, fmt, args);
	va_end(args);
...
	return retval;
}
```

##### kobject_add_varg()函数

lib/kobject.c

```
static __printf(3, 0) int kobject_add_varg(struct kobject *kobj,
					   struct kobject *parent,
					   const char *fmt, va_list vargs)
{
	int retval;
	retval = kobject_set_name_vargs(kobj, fmt, vargs);
	if (retval) {
		pr_err("kobject: can not set name properly!\n");
		return retval;
	}
	/*第一次设置kobj的parent指针*/
	kobj->parent = parent;
	return kobject_add_internal(kobj);
}
```

##### kobject_set_name_vargs()函数

lib/kobject.c

```
int kobject_set_name_vargs(struct kobject *kobj, const char *fmt,
				  va_list vargs)
{
	const char *s;
	...
	/*参数格式化打印到s字符串中*/
	s = kvasprintf_const(GFP_KERNEL, fmt, vargs);
	...
	/*设置kobject对象的名称*/
	kobj->name = s;
	...
}
	
```

#### kobject_add_internal()函数

lib/kobject.c

```
static int kobject_add_internal(struct kobject *kobj)
{
	struct kobject *parent;
	...
	parent = kobject_get(kobj->parent);
	
	if (kobj->kset) {
		/*如果parent为空，parent设置为kobj->kset->kobj*/
		if (!parent)
			parent = kobject_get(&kobj->kset->kobj);
		/*把该kobject加入到kset链表的末尾*/
		kobj_kset_join(kobj);
		/*第二次设置kobj的parent指针*/
		kobj->parent = parent;
	}
	...
	error = create_dir(kobj);
	...
	kobj->state_in_sysfs = 1;
	...
}
```

#### create_dir()函数

lib/kobject.c

```
static int create_dir(struct kobject *kobj)
{
	const struct kobj_ns_type_operations *ops;
	int error;

	error = sysfs_create_dir_ns(kobj, kobject_namespace(kobj));
	...
}
```

#### sysfs_create_dir_ns()函数

fs/sysfs/dir.c

```
int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
{
	struct kernfs_node *parent, *kn;
	kuid_t uid;
	kgid_t gid;

	BUG_ON(!kobj);
	
	if (kobj->parent)
		/*获取上一层节点的目录项*/
		parent = kobj->parent->sd;
	else
		/*设置上一层节点的目录项为sysfs根目录*/
		parent = sysfs_root_kn;

	if (!parent)
		return -ENOENT;

	kn = kernfs_create_dir_ns(parent, kobject_name(kobj),
				  S_IRWXU | S_IRUGO | S_IXUGO, uid, gid,
				  kobj, ns);
	...
	/*kobj对象关联sysfs目录项*/
	kobj->sd = kn;
	return 0;
}
```

##### kernfs_create_dir_ns()函数

```
struct kernfs_node *kernfs_create_dir_ns(struct kernfs_node *parent,
					 const char *name, umode_t mode,
					 kuid_t uid, kgid_t gid,
					 void *priv, const void *ns)
{
	struct kernfs_node *kn;
	int rc;

	/* allocate */
	kn = kernfs_new_node(parent, name, mode | S_IFDIR,
			     uid, gid, KERNFS_DIR);
	...
	/*sysfs目录项关联kobject对象*/
	kn->priv = priv;
	...
}
```

##### kernfs_new_node()函数

```
struct kernfs_node *kernfs_new_node(struct kernfs_node *parent,
				    const char *name, umode_t mode,
				    kuid_t uid, kgid_t gid,
				    unsigned flags)
{
	struct kernfs_node *kn;

	kn = __kernfs_new_node(kernfs_root(parent),
			       name, mode, uid, gid, flags);
	if (kn) {
		kernfs_get(parent);
		kn->parent = parent;
	}
	return kn;
}
```

