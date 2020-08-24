## uevent：内核消息的快递包

#### uevent机制

kobject对象可以通过uevent机制往用户空间发送信息

![image-20200815134926084](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200815134926084.png)

- kobject_uevent：内核消息发送接口
  - 广播方式发送
- NETLINK：特殊的网络通信，本地主机使用
  - 传统做法是内核执行*hotplug*程序进行消息通知（效率低、不优雅）

- udev/mdev：用户空间守护进程，监听广播信息
  - 默认开机启动，systemd
  - udevadm monitor：打印uevent事件

####  内核消息发送

##### 消息类型

```
enum kobject_action {
	KOBJ_ADD,
	KOBJ_REMOVE,
	KOBJ_CHANGE,
	KOBJ_MOVE,
	KOBJ_ONLINE,
	KOBJ_OFFLINE,
	KOBJ_BIND,
	KOBJ_UNBIND,
	KOBJ_MAX
};
```

##### kobject_uevent()函数

```
int kobject_uevent(struct kobject *kobj, enum kobject_action action)
{
	return kobject_uevent_env(kobj, action, NULL);
}
```

##### kobject_uevent_env()函数

```
int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
		       char *envp_ext[])
{
	struct kobj_uevent_env *env;
	...
	top_kobj = kobj;
	/*while循坏查找kobj所隶属的最顶层kobject或者kset指针不为空的kobj*/
	while (!top_kobj->kset && top_kobj->parent)
		top_kobj = top_kobj->parent;
	/*判断kobj的kset指针是否为空*/
	if (!top_kobj->kset) {
		pr_debug("kobject: '%s' (%p): %s: attempted to send uevent "
			 "without kset!\n", kobject_name(kobj), kobj,
			 __func__);
		return -EINVAL;
	}
	/*得到kobj指向的kset对象*/
	kset = top_kobj->kset;
	/*获取kset的uevent_ops*/
	uevent_ops = kset->uevent_ops;
	/*若kobject->uevent_suppress为1，表示kobj不适用uevent*/
	if (kobj->uevent_suppress) {
		pr_debug("kobject: '%s' (%p): %s: uevent_suppress "
				 "caused the event to drop!\n",
				 kobject_name(kobj), kobj, __func__);
		return 0;
	}
	/*过滤event事件*/
	if (uevent_ops && uevent_ops->filter)
		if (!uevent_ops->filter(kset, kobj)) {
			pr_debug("kobject: '%s' (%p): %s: filter function "
				 "caused the event to drop!\n",
				 kobject_name(kobj), kobj, __func__);
			return 0;
		}
	...
	/* environment buffer */
	env = kzalloc(sizeof(struct kobj_uevent_env), GFP_KERNEL);
	if (!env)
		return -ENOMEM;

	/* 获取kobj在sysfs中的路径 */
	devpath = kobject_get_path(kobj, GFP_KERNEL);
	if (!devpath) {
		retval = -ENOENT;
		goto exit;
	}

	/* 消息内容 */
	retval = add_uevent_var(env, "ACTION=%s", action_string);
	if (retval)
		goto exit;
	retval = add_uevent_var(env, "DEVPATH=%s", devpath);
	if (retval)
		goto exit;
	retval = add_uevent_var(env, "SUBSYSTEM=%s", subsystem);
	if (retval)
		goto exit;

	...
	
	if (uevent_ops && uevent_ops->uevent) {
		retval = uevent_ops->uevent(kset, kobj, env);
		if (retval) {
			pr_debug("kobject: '%s' (%p): %s: uevent() returned "
				 "%d\n", kobject_name(kobj), kobj,
				 __func__, retval);
			goto exit;
		}
	}
	...
	/*本地socket通信，发送广播信息*/
	retval = kobject_uevent_net_broadcast(kobj, env, action_string,
					      devpath);
	...
 }
```

