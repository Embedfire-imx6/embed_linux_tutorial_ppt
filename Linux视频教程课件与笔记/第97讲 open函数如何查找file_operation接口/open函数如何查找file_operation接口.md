## open函数如何查找file_operation接口

![image-20200804134308401](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200804134308401.png)

- get_unused_fd_flags
  - 为本次操作分配一个未使用过的文件描述符

- do_file_open
  - 生成一个空白struct file结构体
  - 从文件系统中查找到文件对应的inode

- do_dentry_open

```
static int do_dentry_open(struct file *f,
			  struct inode *inode,
			  int (*open)(struct inode *, struct file *))
{
	...
	/*把inode的i_fop赋值给struct file的f_op*/
	f->f_op = fops_get(inode->i_fop);
	...
	if (!open)
		open = f->f_op->open;
	if (open) {
		error = open(inode, f);
		if (error)
			goto cleanup_all;
	}
	...
}
```

- def_chr_fops->chrdev_open

  ​	ebf-buster-linux/fs/char_dev.c

```
static int chrdev_open(struct inode *inode, struct file *filp)
{
	const struct file_operations *fops;
	struct cdev *p;
	struct cdev *new = NULL;
	...
	struct kobject *kobj;
	int idx;
	/*从内核哈希表cdev_map中，根据设备号查找自己注册的sturct cdev，获取cdev中的file_operation接口*/
	kobj = kobj_lookup(cdev_map, inode>i_rdev,&idx);
	new = container_of(kobj, struct cdev, kobj);
	...
	inode->i_cdev = p = new;
	...
	fops = fops_get(p->ops);
	...
	/*把cdev中的file_operation接口赋值给struct file的f_op*/
	replace_fops(filp, fops);
	
	/*调用自己实现的file_operation接口中的open函数*/
	if (filp->f_op->open) {
		ret = filp->f_op->open(inode, filp);
		if (ret)
			goto out_cdev_put;
	}
	...
}
```



