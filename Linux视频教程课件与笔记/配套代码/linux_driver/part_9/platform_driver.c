#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

#include <linux/fs.h>
#include <linux/uaccess.h>
#include <asm/io.h>

#include <linux/mod_devicetable.h>
#include <linux/platform_device.h>
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
static int led_probe(struct platform_device *pdev)
{

	struct resource *mem_dr;
	struct resource *mem_gdir;
	struct resource *mem_iomuxc_mux;
	struct resource *mem_ccm_ccgrx;
	struct resource *mem_iomux_pad; 

	printk(KERN_ALERT "led_probe\r\n");
	mem_dr = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	mem_gdir = platform_get_resource(pdev, IORESOURCE_MEM, 1);
	mem_iomuxc_mux = platform_get_resource(pdev, IORESOURCE_MEM, 2);
	mem_ccm_ccgrx = platform_get_resource(pdev, IORESOURCE_MEM, 3);
	mem_iomux_pad = platform_get_resource(pdev, IORESOURCE_MEM, 4);

	/* GPIO相关寄存器映射 */
  	IMX6U_CCM_CCGR1 = ioremap(mem_ccm_ccgrx->start,resource_size(mem_ccm_ccgrx));
	SW_MUX_GPIO1_IO04 = ioremap(mem_iomuxc_mux->start,resource_size(mem_iomuxc_mux));
  	SW_PAD_GPIO1_IO04 = ioremap(mem_iomux_pad->start,resource_size(mem_iomux_pad));
	GPIO1_GDIR = ioremap(mem_gdir->start, resource_size(mem_gdir));
	GPIO1_DR = ioremap(mem_dr->start, resource_size(mem_dr));	
		
		
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

static int led_remove(struct platform_device *dev)
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

	return 0;
}

/*与平台设备文件名匹配*/
static struct platform_device_id led_ids[] = {
	{.name = "imx6ull-rled"},
	{}
};

/*定义平台驱动*/
static struct platform_driver led_driver = {
	.driver.name       =   "imx6ull-rled",
	.probe		 = led_probe,
	.remove	  = led_remove,
	.id_table = led_ids,
};

/*模块入口函数，注册平台驱动*/
static int __init leddriver_init(void)
{
	printk(KERN_ALERT "leddriver_init\r\n");
	return platform_driver_register(&led_driver);
}

/*模块退出函数，注销平台驱动*/
static void __exit leddriver_exit(void)
{
	platform_driver_unregister(&led_driver);
}


module_init(leddriver_init );
module_exit(leddriver_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("embedfire ");
MODULE_DESCRIPTION("led_module");
MODULE_ALIAS("led_module");