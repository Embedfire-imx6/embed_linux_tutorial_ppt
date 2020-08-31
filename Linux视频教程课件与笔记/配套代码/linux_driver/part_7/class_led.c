#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

#include <linux/fs.h>
#include <linux/uaccess.h>
#include <asm/io.h>
#include <linux/device.h>

#define DEV_MAJOR		0		/* 动态申请主设备号 */
#define DEV_NAME		"red_led" 	/*led设备名字 */

/* GPIO虚拟地址指针 */
static void __iomem *IMX6U_CCM_CCGR1;
static void __iomem *SW_MUX_GPIO1_IO04;
static void __iomem *SW_PAD_GPIO1_IO04;
static void __iomem *GPIO1_DR;
static void __iomem *GPIO1_GDIR;

static int led_open(struct inode *inode, struct file *filp)
{
	return 0;
}

static ssize_t led_read(struct file *filp, char __user *buf, size_t cnt, loff_t *offt)
{
	return -EFAULT;
}

static ssize_t led_write(struct file *filp, const char __user *buf, size_t cnt, loff_t *offt)
{

	unsigned char databuf[10];

	if(cnt >10)
		cnt =10;
		
    /*从用户空间拷贝数据到内核空间*/
    if(copy_from_user(databuf, buf, cnt)){
		return -EIO;
	}
    	
	if(!memcmp(databuf,"on",2)) {	
		iowrite32(0 << 4, GPIO1_DR);	
	} else if(!memcmp(databuf,"off",3)) {
		iowrite32(1 << 4, GPIO1_DR);
	}
	/*写成功后，返回写入的字数*/
	return cnt;
}

static int led_release(struct inode *inode, struct file *filp)
{
	return 0;
}

/* 自定义led的file_operations 接口*/
static struct file_operations led_fops = {
	.owner = THIS_MODULE,
	.open = led_open,
	.read = led_read,
	.write = led_write,
	.release = 	led_release,
};

int major = 0;
struct class *class_led;
static int __init led_init(void)
{
	
	/* GPIO相关寄存器映射 */
  	IMX6U_CCM_CCGR1 = ioremap(0x20c406c, 4);
	SW_MUX_GPIO1_IO04 = ioremap(0x20e006c, 4);
  	SW_PAD_GPIO1_IO04 = ioremap(0x20e02f8, 4);
	GPIO1_GDIR = ioremap(0x0209c004, 4);
	GPIO1_DR = ioremap(0x0209c000, 4);


	/* 使能GPIO1时钟 */
	iowrite32(0xffffffff, IMX6U_CCM_CCGR1);

	/* 设置GPIO1_IO04复用为普通GPIO*/
	iowrite32(5, SW_MUX_GPIO1_IO04);
	
    /*设置GPIO属性*/
	iowrite32(0x10B0, SW_PAD_GPIO1_IO04);

	/* 设置GPIO1_IO04为输出功能 */
	iowrite32(1 << 4, GPIO1_GDIR);

	/* LED输出高电平 */
	iowrite32(1<< 4, GPIO1_DR);

	/* 注册字符设备驱动 */
	major = register_chrdev(DEV_MAJOR, DEV_NAME, &led_fops);
    printk(KERN_ALERT "led major:%d\n",major);

	/*创建/sys/class/xxx目录项*/
	class_led = class_create(THIS_MODULE, "xxx");

	/*创建/sys/class/xxx/my_led目录项，并生成dev属性文件*/
	device_create(class_led, NULL, MKDEV(major, 0), NULL,"my_led");

	return 0;
}

static void __exit led_exit(void)
{
	/* 取消映射 */
	iounmap(IMX6U_CCM_CCGR1);
	iounmap(SW_MUX_GPIO1_IO04);
	iounmap(SW_PAD_GPIO1_IO04);
	iounmap(GPIO1_DR);
	iounmap(GPIO1_GDIR);

	/* 注销字符设备驱动 */
	unregister_chrdev(major, DEV_NAME);

	/*销毁/sys/class/xxx/my_led目录项*/
	device_destroy(class_led, MKDEV(major, 0));

	/*销毁/sys/class/xxx目录项*/
	class_destroy(class_led);
}


module_init(led_init);
module_exit(led_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("embedfire ");
MODULE_DESCRIPTION("led_module");
MODULE_ALIAS("led_module");