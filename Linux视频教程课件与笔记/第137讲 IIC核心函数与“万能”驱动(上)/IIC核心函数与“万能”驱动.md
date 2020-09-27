## IIC核心函数与“万能”驱动

#### i2c_add_adapter()函数

drivers/i2c/i2c-core-base.c

注册一个i2c适配器

```
int i2c_add_adapter(struct i2c_adapter *adapter)
int i2c_add_numbered_adapter(struct i2c_adapter *adapter)
```

adapter->nr：适配器的编号

参数：

- adapter：i2c物理控制器对应的适配器

返回值：

- 成功：0
- 失败：负数



#### i2c_add_driver()宏

include/linux/i2c.h

注册一个i2c驱动

```
#define i2c_add_driver(driver) \ i2c_register_driver(THIS_MODULE, driver)
```



#### i2c_register_driver()函数

drivers/i2c/i2c-core-base.c

注册一个i2c驱动

````
int i2c_register_driver(struct module *owner,
struct i2c_driver *driver)
````

参数：

- owner： ：一般为 THIS_MODULE
- driver：要注册的 i2c_driver.

返回值：

- 成功：0
- 失败：负数



#### i2c_transfer()函数

drivers/i2c/i2c-core-base.c

收发iic消息

```
int i2c_transfer(struct i2c_adapter *adap, struct i2c_msg *msgs, int num)
```

参数：

- adap ：所使用的 I2C 适配器，i2c_client 会保存其对应的 i2c_adapter
- msgs：I2C 要发送的一个或多个消息
- num ：消息数量，也就是 msgs 的数量

返回值：

- 成功：发送的msgs 的数量
- 失败：负数



#### i2c_msg结构体

include/uapi/linux/i2c.h

描述一个iic消息

```
struct i2c_msg {
	__u16 addr;	/* slave address			*/
	__u16 flags;
#define I2C_M_RD		0x0001	/* read data, from slave to master */
					/* I2C_M_RD is guaranteed to be 0x0001! */
#define I2C_M_TEN		0x0010	/* this is a ten bit chip address */
#define I2C_M_DMA_SAFE		0x0200	/* the buffer of this message is DMA safe */
					/* makes only sense in kernelspace */
					/* userspace buffers are copied anyway */
#define I2C_M_RECV_LEN		0x0400	/* length will be first received byte */
#define I2C_M_NO_RD_ACK		0x0800	/* if I2C_FUNC_PROTOCOL_MANGLING */
#define I2C_M_IGNORE_NAK	0x1000	/* if I2C_FUNC_PROTOCOL_MANGLING */
#define I2C_M_REV_DIR_ADDR	0x2000	/* if I2C_FUNC_PROTOCOL_MANGLING */
#define I2C_M_NOSTART		0x4000	/* if I2C_FUNC_NOSTART */
#define I2C_M_STOP		0x8000	/* if I2C_FUNC_PROTOCOL_MANGLING */
	__u16 len;		/* msg length				*/
	__u8 *buf;		/* pointer to msg data			*/
};

```

- addr：iic设备地址
- flags：消息传输方向和特性。
  - I2C_M_RD：表示读取消息
  - 0：表示发送消息

- len：消息数据的长度
- buf：消息缓冲区



#### i2c_master_send()函数

include/linux/i2c.h

发送一个i2c消息

```
static inline int i2c_master_send(const struct i2c_client *client,
				  const char *buf, int count)
{
	return i2c_transfer_buffer_flags(client, (char *)buf, count, 0);
};
```



#### i2c_master_recv()函数

include/linux/i2c.h

```
static inline int i2c_master_recv(const struct i2c_client *client,
				  char *buf, int count)
{
	return i2c_transfer_buffer_flags(client, buf, count, I2C_M_RD);
};
```



#### i2c_transfer_buffer_flags()函数

drivers/i2c/i2c-core-base.c

发送一个i2c消息

```
int i2c_transfer_buffer_flags(const struct i2c_client *client, char *buf,
			      int count, u16 flags)
{
	int ret;
	struct i2c_msg msg = {
		.addr = client->addr,
		.flags = flags | (client->flags & I2C_M_TEN),
		.len = count,
		.buf = buf,
	};

	ret = i2c_transfer(client->adapter, &msg, 1);

	/*
	 * If everything went ok (i.e. 1 msg transferred), return #bytes
	 * transferred, else error code.
	 */
	return (ret == 1) ? count : ret;
}
```



#### "万能"的i2c驱动--i2c-dev.c分析

drivers/i2c/i2c-dev.c

- 内核集成i2c_dev驱动模块，开机自动加载
- 为每个i2c_adapter生成一个设备文件，通过该设备文件间接使用IIC核心函数收发数据
- 注册i2c总线的通知函数，解决加载顺序问题

#### i2c_dev_init()函数

drivers/i2c/i2c-dev.c

```
static int __init i2c_dev_init(void)
{
	int res;

	printk(KERN_INFO "i2c /dev entries driver\n");
	
	res = register_chrdev_region(MKDEV(I2C_MAJOR, 0), I2C_MINORS, "i2c");
	if (res)
		goto out;

	i2c_dev_class = class_create(THIS_MODULE, "i2c-dev");
	if (IS_ERR(i2c_dev_class)) {
		res = PTR_ERR(i2c_dev_class);
		goto out_unreg_chrdev;
	}
	...
	res = bus_register_notifier(&i2c_bus_type, &i2cdev_notifier);
	if (res)
		goto out_unreg_class;

	/* Bind to already existing adapters right away */
	i2c_for_each_dev(NULL, i2cdev_attach_adapter);

	return 0;

out_unreg_class:
	class_destroy(i2c_dev_class);
out_unreg_chrdev:
	unregister_chrdev_region(MKDEV(I2C_MAJOR, 0), I2C_MINORS);
out:
	printk(KERN_ERR "%s: Driver Initialisation failed\n", __FILE__);
	return res;
}
```

#### i2cdev_notifier定义



```
static struct notifier_block i2cdev_notifier = {
	.notifier_call = i2cdev_notifier_call,
};
```

#### i2cdev_notifier_call()函数



```
static int i2cdev_notifier_call(struct notifier_block *nb, unsigned long action,
			 void *data)
{
	struct device *dev = data;

	switch (action) {
	case BUS_NOTIFY_ADD_DEVICE:
		return i2cdev_attach_adapter(dev, NULL);
	case BUS_NOTIFY_DEL_DEVICE:
		return i2cdev_detach_adapter(dev, NULL);
	}

	return 0;
}
```



#### I2C_MAJOR

include/linux/i2c-dev.h

```
#define I2C_MAJOR	89		/* Device major number		*/
```



#### I2C_MINORS

drivers/i2c/i2c-dev.c

```
#define MINORBITS	20
#define MINORMASK	((1U << MINORBITS) - 1)
#define I2C_MINORS	MINORMASK
```



#### i2c_for_each_dev()函数

drivers/i2c/i2c-core-base.c

```
int i2c_for_each_dev(void *data, int (*fn)(struct device *, void *))
{
	int res;

	mutex_lock(&core_lock);
	res = bus_for_each_dev(&i2c_bus_type, NULL, data, fn);
	mutex_unlock(&core_lock);

	return res;
}
```



#### bus_for_each_dev()函数

drivers/base/bus.c

```
int bus_for_each_dev(struct bus_type *bus, struct device *start,
		     void *data, int (*fn)(struct device *, void *))
{
	struct klist_iter i;
	struct device *dev;
	int error = 0;

	if (!bus || !bus->p)
		return -EINVAL;

	klist_iter_init_node(&bus->p->klist_devices, &i,
			     (start ? &start->p->knode_bus : NULL));
	while (!error && (dev = next_device(&i)))
		error = fn(dev, data);
	klist_iter_exit(&i);
	return error;
}
```



#### i2cdev_attach_adapter()函数

drivers/i2c/i2c-dev.c

```
static int i2cdev_attach_adapter(struct device *dev, void *dummy)
{
	struct i2c_adapter *adap;
	struct i2c_dev *i2c_dev;
	int res;
	if (dev->type != &i2c_adapter_type)
		return 0;
	adap = to_i2c_adapter(dev);

	i2c_dev = get_free_i2c_dev(adap);
	if (IS_ERR(i2c_dev))
		return PTR_ERR(i2c_dev);

	cdev_init(&i2c_dev->cdev, &i2cdev_fops);
	i2c_dev->cdev.owner = THIS_MODULE;
	res = cdev_add(&i2c_dev->cdev, MKDEV(I2C_MAJOR, adap->nr), 1);
	if (res)
		goto error_cdev;

	/* register this i2c device with the driver core */
	i2c_dev->dev = device_create(i2c_dev_class, &adap->dev,
				     MKDEV(I2C_MAJOR, adap->nr), NULL,
				     "i2c-%d", adap->nr);
	if (IS_ERR(i2c_dev->dev)) {
		res = PTR_ERR(i2c_dev->dev);
		goto error;
	}

	pr_debug("i2c-dev: adapter [%s] registered as minor %d\n",
		 adap->name, adap->nr);
	return 0;
error:
	cdev_del(&i2c_dev->cdev);
error_cdev:
	put_i2c_dev(i2c_dev);
	return res;
}
```



#### i2cdev_fops定义

drivers/i2c/i2c-dev.c

```
static const struct file_operations i2cdev_fops = {
	.owner		= THIS_MODULE,
	.llseek		= no_llseek,
	.read		= i2cdev_read,
	.write		= i2cdev_write,
	.unlocked_ioctl	= i2cdev_ioctl,
	.compat_ioctl	= compat_i2cdev_ioctl,
	.open		= i2cdev_open,
	.release	= i2cdev_release,
};
```



#### i2cdev_open()函数

drivers/i2c/i2c-dev.c

```
static int i2cdev_open(struct inode *inode, struct file *file)
{
	unsigned int minor = iminor(inode);
	struct i2c_client *client;
	struct i2c_adapter *adap;

	adap = i2c_get_adapter(minor);
	if (!adap)
		return -ENODEV;

	client = kzalloc(sizeof(*client), GFP_KERNEL);
	if (!client) {
		i2c_put_adapter(adap);
		return -ENOMEM;
	}
	snprintf(client->name, I2C_NAME_SIZE, "i2c-dev %d", adap->nr);

	client->adapter = adap;
	file->private_data = client;

	return 0;
}
```



#### i2cdev_read()函数

drivers/i2c/i2c-dev.c

```
static ssize_t i2cdev_read(struct file *file, char __user *buf, size_t count,
		loff_t *offset)
{
	char *tmp;
	int ret;

	struct i2c_client *client = file->private_data;

	if (count > 8192)
		count = 8192;

	tmp = kmalloc(count, GFP_KERNEL);
	if (tmp == NULL)
		return -ENOMEM;

	pr_debug("i2c-dev: i2c-%d reading %zu bytes.\n",
		iminor(file_inode(file)), count);

	ret = i2c_master_recv(client, tmp, count);
	if (ret >= 0)
		ret = copy_to_user(buf, tmp, count) ? -EFAULT : ret;
	kfree(tmp);
	return ret;
}
```

#### i2cdev_write()函数

drivers/i2c/i2c-dev.c

```
static ssize_t i2cdev_write(struct file *file, const char __user *buf,
		size_t count, loff_t *offset)
{
	int ret;
	char *tmp;
	struct i2c_client *client = file->private_data;

	if (count > 8192)
		count = 8192;

	tmp = memdup_user(buf, count);
	if (IS_ERR(tmp))
		return PTR_ERR(tmp);

	pr_debug("i2c-dev: i2c-%d writing %zu bytes.\n",
		iminor(file_inode(file)), count);

	ret = i2c_master_send(client, tmp, count);
	kfree(tmp);
	return ret;
}
```

