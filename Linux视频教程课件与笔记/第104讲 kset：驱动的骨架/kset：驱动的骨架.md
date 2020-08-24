## kset：驱动的骨架

kobject的容器，体现设备驱动的层次关系

![image-20200814220758436](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200814220758436.png)

##### kset_create_and_add()函数

lib/kobject.c

```
struct kset *kset_create_and_add(const char *name,
const struct kset_uevent_ops *uevent_ops,struct kobject *parent_kobj)
{
	struct kset *kset;
	int error;

	kset = kset_create(name, uevent_ops, parent_kobj);
	if (!kset)
		return NULL;

	error = kset_register(kset);
	if (error) {
		kfree(kset);
		return NULL;
	}
	return kset;
}
```

##### kset_create()函数

lib/kobject.c

```
static struct kset *kset_create(const char *name,const struct kset_uevent_ops *uevent_ops,struct kobject *parent_kobj)
{
	struct kset *kset;
	int retval;

	kset = kzalloc(sizeof(*kset), GFP_KERNEL);
	if (!kset)
		return NULL;
	retval = kobject_set_name(&kset->kobj, "%s", name);
	if (retval) {
		kfree(kset);
		return NULL;
	}
	/*注册消息发送接口*/
	kset->uevent_ops = uevent_ops;
	kset->kobj.parent = parent_kobj;

	kset->kobj.ktype = &kset_ktype;
	kset->kobj.kset = NULL;

	return kset;
}
```

##### kset_init()函数

lib/kobject.c

```
void kset_init(struct kset *k)
{
	kobject_init_internal(&k->kobj);
	INIT_LIST_HEAD(&k->list);
	spin_lock_init(&k->list_lock);
}
```

##### kset_register()函数

lib/kobject.c

```
int kset_register(struct kset *k)
{
	int err;

	if (!k)
		return -EINVAL;

	kset_init(k);
	
	err = kobject_add_internal(&k->kobj);
	if (err)
		return err;

	/*发送驱动模型消息到应用层*/
	kobject_uevent(&k->kobj, KOBJ_ADD);
	return 0;
}
```

