#### kobj_type：用户空间的法宝

- 为kobject对象构建多个属性文件
- 为每个属性文件设置具体操作接口
- vfs的inode对象与sysfs的kernfs_node对象的绑定过程

#### 重点

- 关注属性文件具体操作接口的赋值过程
- 关注open()、read()、write函数的底层机制

#### 第一阶段：属性文件操作接口赋值

##### sysfs_create_group()函数

fs/sysfs/group.c

```
int sysfs_create_group(struct kobject *kobj,
		       const struct attribute_group *grp)
{
	return internal_create_group(kobj, 0, grp);
}
```

- attribute_group结构体：

  include/linux/sysfs.h

```
struct attribute_group {
	const char		*name;
	umode_t			(*is_visible)(struct kobject *,
					      struct attribute *, int);
	umode_t			(*is_bin_visible)(struct kobject *,
						  struct bin_attribute *, int);
	struct attribute	**attrs;
	struct bin_attribute	**bin_attrs;
};
```

- struct attribute结构体：

  include/linux/sysfs.h

```
struct attribute {
	const char		*name;
	umode_t			mode;
};
```

- kobj_attribute结构体

```
struct kobj_attribute {
	struct attribute attr;
	ssize_t (*show)(struct kobject *kobj, struct kobj_attribute *attr,
			char *buf);
	ssize_t (*store)(struct kobject *kobj, struct kobj_attribute *attr,
			 const char *buf, size_t count);
};
```



##### internal_create_group()函数

fs/sysfs/group.c

```
tatic int internal_create_group(struct kobject *kobj, int update,
				 const struct attribute_group *grp)
{
	struct kernfs_node *kn;
	kuid_t uid;
	kgid_t gid;
	int error;
	
	...
	if (grp->name)
	...
	else
		kn = kobj->sd;
    ...
    error = create_files(kn, kobj, uid, gid, grp, update);
    ...
}	
```

##### create_files()函数

fs/sysfs/group.c

```
static int create_files(struct kernfs_node *parent, struct kobject *kobj,
			kuid_t uid, kgid_t gid,
			const struct attribute_group *grp, int update)
{
	struct attribute *const *attr;
	struct bin_attribute *const *bin_attr;
	int error = 0, i;

	if (grp->attrs) {
		for (i = 0, attr = grp->attrs; *attr && !error; i++, attr++) {
			umode_t mode = (*attr)->mode;
			...
			error = sysfs_add_file_mode_ns(parent, *attr, false,
						       mode, uid, gid, NULL);
			...
			}
	...
}
```

##### sysfs_add_file_mode_ns()函数

fs/sysfs/file.c

```
int sysfs_add_file_mode_ns(struct kernfs_node *parent,
			   const struct attribute *attr, bool is_bin,
			   umode_t mode, kuid_t uid, kgid_t gid, const void *ns)
{
	struct lock_class_key *key = NULL;
	const struct kernfs_ops *ops;
	struct kernfs_node *kn;
	loff_t size;

	if (!is_bin) {
		struct kobject *kobj = parent->priv;
		/*kobj_sysfs_ops*/
		const struct sysfs_ops *sysfs_ops = kobj->ktype->sysfs_ops;
		...
		if (sysfs_ops->show && sysfs_ops->store) {
			if (mode & SYSFS_PREALLOC)
				ops = &sysfs_prealloc_kfops_rw;
			else
				ops = &sysfs_file_kfops_rw;
		else if
			...
		}
	...
	kn = __kernfs_create_file(parent, attr->name, mode & 0777, uid, gid,
				  size, ops, (void *)attr, ns, key);
    ...
}
```

- kernfs_ops节点的操作函数

```
static const struct kernfs_ops sysfs_file_kfops_rw = {
	.seq_show	= sysfs_kf_seq_show,
	.write		= sysfs_kf_write,
};
```

##### __kernfs_create_file()函数

```
struct kernfs_node *__kernfs_create_file(struct kernfs_node *parent,
					 const char *name,
					 umode_t mode, kuid_t uid, kgid_t gid,
					 loff_t size,
					 const struct kernfs_ops *ops,
					 void *priv, const void *ns,
					 struct lock_class_key *key)
{
	struct kernfs_node *kn;
	unsigned flags;
	int rc;

	flags = KERNFS_FILE;

	kn = kernfs_new_node(parent, name, (mode & S_IALLUGO) | S_IFREG,
			     uid, gid, flags);
	if (!kn)
		return ERR_PTR(-ENOMEM);
	/*操作接口赋值*/
	kn->attr.ops = ops;
	kn->attr.size = size;
	kn->ns = ns;
	/*文件属性赋值*/
	kn->priv = priv;
	
	if (ops->seq_show)
		kn->flags |= KERNFS_HAS_SEQ_SHOW;
	...
}
```

#### 第二阶段：open()\read()\write()的底层机制

##### kernfs_init_inode()函数

```
static void kernfs_init_inode(struct kernfs_node *kn, struct inode *inode)
{
	kernfs_get(kn);
	/*sysfs的kernels_node赋值给vfs的inode*/
	inode->i_private = kn;
	inode->i_mapping->a_ops = &kernfs_aops;
	inode->i_op = &kernfs_iops;
	inode->i_generation = kn->id.generation;

	set_default_inode_attr(inode, kn->mode);
	kernfs_refresh_inode(kn, inode);

	/* 判断sysfs的kernels_node类型 */
	switch (kernfs_type(kn)) {
	case KERNFS_DIR:
		inode->i_op = &kernfs_dir_iops;
		inode->i_fop = &kernfs_dir_fops;
		if (kn->flags & KERNFS_EMPTY_DIR)
			make_empty_dir_inode(inode);
		break;
	case KERNFS_FILE:
		inode->i_size = kn->attr.size;
		/*文件的操作接口*/
		inode->i_fop = &kernfs_file_fops;
		break;
	case KERNFS_LINK:
		inode->i_op = &kernfs_symlink_iops;
		break;
	default:
		BUG();
	}

	unlock_new_inode(inode);
}
```

```
const struct file_operations kernfs_file_fops = {
	.read		= kernfs_fop_read,
	.write		= kernfs_fop_write,
	.llseek		= generic_file_llseek,
	.mmap		= kernfs_fop_mmap,
	.open		= kernfs_fop_open,
	.release	= kernfs_fop_release,
	.poll		= kernfs_fop_poll,
	.fsync		= noop_fsync,
};
```

##### kernfs_fop_open()函数

```
static int kernfs_fop_open(struct inode *inode, struct file *file)
{
	struct kernfs_node *kn = inode->i_private;
	struct kernfs_open_file *of;
	...
	of = kzalloc(sizeof(struct kernfs_open_file), GFP_KERNEL);
	...
	/*sysfs中文件的kernfs_node赋值给of->kn*/
	of->kn = kn;
	/*进程的struct file赋值给of->file/
	of->file = file;
	...
	if (ops->seq_show)
		error = seq_open(file, &kernfs_seq_ops);
	...
	/*struct file的私有指针赋值给of->seq_file */
	of->seq_file = file->private_data;
	/*of赋值给of->seq_file->private*/
	of->seq_file->private = of;
	...
 }
```



```
static const struct seq_operations kernfs_seq_ops = {
	.start = kernfs_seq_start,
	.next = kernfs_seq_next,
	.stop = kernfs_seq_stop,
	.show = kernfs_seq_show,
};
```



seq_open

```
int seq_open(struct file *file, const struct seq_operations *op)
{
	struct seq_file *p;

	WARN_ON(file->private_data);

	p = kmem_cache_zalloc(seq_file_cache, GFP_KERNEL);
	if (!p)
		return -ENOMEM;
	
	file->private_data = p;
	...
	p->op = op;
	...
}
```



##### kernfs_fop_read()函数

```
static ssize_t kernfs_fop_read(struct file *file, char __user *user_buf,
			       size_t count, loff_t *ppos)
{
	struct kernfs_open_file *of = kernfs_of(file);

	if (of->kn->flags & KERNFS_HAS_SEQ_SHOW)
		return seq_read(file, user_buf, count, ppos);
	else
		return kernfs_file_direct_read(of, user_buf, count, ppos);
}

```



##### kernfs_of()函数

```
static struct kernfs_open_file *kernfs_of(struct file *file)
{
	return ((struct seq_file *)file->private_data)->private;
}
```



##### seq_read()函数

```
ssize_t seq_read(struct file *file, char __user *buf, size_t size, loff_t *ppos)
{
	struct seq_file *m = file->private_data;
	...
	err = m->op->show(m, p);
	...
	err = copy_to_user(buf, m->buf, n);
	...
}
```

##### kernfs_seq_show()函数

```
static int kernfs_seq_show(struct seq_file *sf, void *v)
{
	struct kernfs_open_file *of = sf->private;
	...
	return of->kn->attr.ops->seq_show(sf, v);
}
```

##### sysfs_kf_seq_show()函数

```
static int sysfs_kf_seq_show(struct seq_file *sf, void *v)
{
	struct kernfs_open_file *of = sf->private;
	struct kobject *kobj = of->kn->parent->priv;
	const struct sysfs_ops *ops = sysfs_file_ops(of->kn);
	ssize_t count;
	char *buf;

	count = seq_get_buf(sf, &buf);
	if (count < PAGE_SIZE) {
		seq_commit(sf, -1);
		return 0;
	}
	memset(buf, 0, PAGE_SIZE);

	/*
	 * Invoke show().  Control may reach here via seq file lseek even
	 * if @ops->show() isn't implemented.
	 */
	if (ops->show) {
		count = ops->show(kobj, of->kn->priv, buf);
		if (count < 0)
			return count;
	}

	/*
	 * The code works fine with PAGE_SIZE return but it's likely to
	 * indicate truncated result or overflow in normal use cases.
	 */
	if (count >= (ssize_t)PAGE_SIZE) {
		printk("fill_read_buffer: %pS returned bad count\n",
				ops->show);
		/* Try to struggle along */
		count = PAGE_SIZE - 1;
	}
	seq_commit(sf, count);
	return 0;
}
```

##### sysfs_file_ops()函数

```
static const struct sysfs_ops *sysfs_file_ops(struct kernfs_node *kn)
{
	struct kobject *kobj = kn->parent->priv;

	if (kn->flags & KERNFS_LOCKDEP)
		lockdep_assert_held(kn);
	return kobj->ktype ? kobj->ktype->sysfs_ops : NULL;
}
```

##### seq_get_buf()函数

```
static inline size_t seq_get_buf(struct seq_file *m, char **bufp)
{
	BUG_ON(m->count > m->size);
	if (m->count < m->size)
		*bufp = m->buf + m->count;
	else
		*bufp = NULL;

	return m->size - m->count;
}
```

#### kobj_attr_show()函数

```
static ssize_t kobj_attr_show(struct kobject *kobj, struct attribute *attr,char *buf)
{
	struct kobj_attribute *kattr;
	ssize_t ret = -EIO;
	/*根据结构体成员的内存地址获取结构体的地址*/
	kattr = container_of(attr, struct kobj_attribute, attr);
	if (kattr->show)
		ret = kattr->show(kobj, kattr, buf);
	return ret;
}
```



