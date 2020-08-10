## led字符设备驱动实验

驱动模块= 内核模块(.ko)+ 驱动接口(file_operations)

- 在内核模块入口函数里获取gpio相关寄存器并初始化
- 构造file_operations接口，并注册到内核

- 创建设备文件，绑定自定义file_operations接口
- 应用程序echo通过写设备文件控制硬件led

#### 驱动模块初始化

##### 地址映射

GPIO寄存器物理地址和虚拟地址映射

ebf-buster-linux/arch/arm/include/asm/io.h

```
void __iomem *ioremap(resource_size_t res_cookie, size_t size)
```

参数：

- res_cookie：物理地址

- size：映射长度

返回值：

- void * 类型的指针，指向被映射的虚拟地址
- __iomem 主要是用于编译器的检查地址在内核空间的有效性

##### 虚拟地址读写

```
readl()/ writel()	//过时

void iowrite32(u32 b, void __iomem *addr)   //写入一个双字（32bit）

unsigned int ioread32(void __iomem *addr)   //读取一个双字（32bit）
```

检查cpu大小端，调整字节序，以提高驱动的可移植性

#### 自定义led的file_operations接口

````
static struct file_operations led_fops = {
	.owner = THIS_MODULE,
	.open = led_open,
	.read = led_read,
	.write = led_write,
	.release = led_release,
};
````

- owner：设置驱动接口关联的内核模块，防止驱动程序运行时内核模块被卸载
- release：文件引用数为0时调用

#### 拷贝数据

include/linux/uaccess.h

```
copy_from_user(void *to, const void __user *from, unsigned long n)
```

参数：

- *to：将数据拷贝到内核的地址

- *from  需要拷贝数据的用户空间地址

- n   拷贝数据的长度（字节）

返回值：

失败：没有被拷贝的字节数

成功：0

#### register_chrdev函数

ebf-buster-linux/include/linux/fs.h

```
static inline int register_chrdev(unsigned int major, const char *name,
				  const struct file_operations *fops)
{
	return __register_chrdev(major, 0, 256, name, fops);
}
```

#### __register_chrdev函数

kernel/ebf-buster-linux/fs/char_dev.c

```
int __register_chrdev(unsigned int major, unsigned int baseminor,unsigned int count, const char *name,const struct file_operations *fops)
{
	struct char_device_struct *cd;
	struct cdev *cdev;
	int err = -ENOMEM;

	cd = __register_chrdev_region(major, baseminor, count, name);
...
	cdev = cdev_alloc();
...
	cdev->owner = fops->owner;
	cdev->ops = fops;
...
	err = cdev_add(cdev, MKDEV(cd->major, baseminor), count);
...
}
```

- 次设备号为0，次设备号数量为256

