#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <linux/string.h>
#include <linux/types.h>
#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/ide.h>
#include <linux/errno.h>
#include <linux/gpio.h>
#include <asm/mach/map.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/of_gpio.h>
#include <asm/io.h>
#include <linux/device.h>

#include <linux/platform_device.h>

/*------------------字符设备内容----------------------*/
#define DEV_NAME "rgb_led"
#define DEV_CNT (1)

int rgb_led_red;
int rgb_led_green;
int rgb_led_blue;

/*定义 led 资源结构体，保存获取得到的节点信息以及转换后的虚拟寄存器地址*/
struct led_resource
{
	struct device_node *device_node; //rgb_led_red的设备树节点
	void __iomem *virtual_CCM_CCGR;
	void __iomem *virtual_IOMUXC_SW_MUX_CTL_PAD;
	void __iomem *virtual_IOMUXC_SW_PAD_CTL_PAD;
	void __iomem *virtual_DR;
	void __iomem *virtual_GDIR;
};

static dev_t led_devno;					 //定义字符设备的设备号
static struct cdev led_chr_dev;			 //定义字符设备结构体chr_dev
struct class *class_led;				 //保存创建的类
struct device *device;					 // 保存创建的设备
struct device_node *rgb_led_device_node; //rgb_led的设备树节点结构体

/*定义 R G B 三个灯的led_resource 结构体，保存获取得到的节点信息*/
struct led_resource led_red;
struct led_resource led_green;
struct led_resource led_blue;

struct mutex lock;

/*字符设备操作函数集，open函数*/
static int led_chr_dev_open(struct inode *inode, struct file *filp)
{
	mutex_lock(&lock);
	printk("\n open form driver \n");
	return 0;
}

/*字符设备操作函数集，write函数*/
static ssize_t led_chr_dev_write(struct file *filp, const char __user *buf, size_t cnt, loff_t *offt)
{

	int ret,error;
	unsigned char receive_data[10]; //用于保存接收到的数据
	unsigned int write_data; //用于保存接收到的数据

	if(cnt>10)
			cnt =10;

	error = copy_from_user(receive_data, buf, cnt);
	if (error < 0)
	{
		return -1;
	}

	ret = kstrtoint(receive_data, 16, &write_data);
	if (ret) {
		return -1;
        }

	/*设置 GPIO1_04 输出电平*/
	if (write_data & 0x04)
	{
		gpio_set_value(rgb_led_red,0);
	}
	else
	{
		gpio_set_value(rgb_led_red,1);
	}

	/*设置 GPIO4_20 输出电平*/
	if (write_data & 0x02)
	{
		gpio_set_value(rgb_led_green,0);
	}
	else
	{
		gpio_set_value(rgb_led_green,1);
	}

	/*设置 GPIO4_19 输出电平*/
	if (write_data & 0x01)
	{
		gpio_set_value(rgb_led_blue,0);
	}
	else
	{
		gpio_set_value(rgb_led_blue,1);
	}

	return cnt;
}

static int led_chrdev_release(struct inode *inode, struct file *filp)
{
	mutex_unlock(&lock);
	printk("KERN_ALERT  \n finished  !!!\n");

	return 0;
}

/*字符设备操作函数集*/
static struct file_operations led_chr_dev_fops =
	{
		.owner = THIS_MODULE,
		.open = led_chr_dev_open,
		.write = led_chr_dev_write,
		.release = led_chrdev_release,
};

/*----------------平台驱动函数集-----------------*/
static int led_probe(struct platform_device *pdv)
{

	int ret = -1; //保存错误状态码

	printk(KERN_ALERT "\t  match successed  \n");

	/*获取rgb_led的设备树节点*/
	rgb_led_device_node = of_find_node_by_path("/rgb_led");
	if (rgb_led_device_node == NULL)
	{
		printk(KERN_ERR "\t  get rgb_led failed!  \n");
		return -1;
	}

	rgb_led_red = of_get_named_gpio(rgb_led_device_node,"rgb_led_red",0);
	if (rgb_led_red < 0)
	{
		printk(KERN_ERR "\t  rgb_led_red failed!  \n");
		return -1;
	}

	rgb_led_green = of_get_named_gpio(rgb_led_device_node,"rgb_led_green",0);
	if (rgb_led_green < 0)
	{
		printk(KERN_ERR "\t  rgb_led_green failed!  \n");
		return -1;
	}

rgb_led_blue = of_get_named_gpio(rgb_led_device_node,"rgb_led_blue",0);
	if (rgb_led_blue < 0)
	{
		printk(KERN_ERR "\t  rgb_led_blue failed!  \n");
		return -1;
	}

gpio_direction_output(rgb_led_red,1);
gpio_direction_output(rgb_led_green,1);
gpio_direction_output(rgb_led_blue,1);

	/*---------------------注册 字符设备部分-----------------*/

	//第一步
	//采用动态分配的方式，获取设备编号，次设备号为0，
	//设备名称为rgb-leds，可通过命令cat  /proc/devices查看
	//DEV_CNT为1，当前只申请一个设备编号
	ret = alloc_chrdev_region(&led_devno, 0, DEV_CNT, DEV_NAME);
	if (ret < 0)
	{
		printk("fail to alloc led_devno\n");
		goto alloc_err;
	}
	//第二步
	//关联字符设备结构体cdev与文件操作结构体file_operations
	led_chr_dev.owner = THIS_MODULE;
	cdev_init(&led_chr_dev, &led_chr_dev_fops);
	//第三步
	//添加设备至cdev_map散列表中
	ret = cdev_add(&led_chr_dev, led_devno, DEV_CNT);
	if (ret < 0)
	{
		printk("fail to add cdev\n");
		goto add_err;
	}

	//第四步
	/*创建类 */
	class_led = class_create(THIS_MODULE, DEV_NAME);

	/*创建设备*/
	device = device_create(class_led, NULL, led_devno, NULL, DEV_NAME);

	return 0;

add_err:
	//添加设备失败时，需要注销设备号
	unregister_chrdev_region(led_devno, DEV_CNT);
	printk("\n error! \n");
alloc_err:

	return -1;
}

static const struct of_device_id rgb_led[] = {
	{.compatible = "fire,rgb_led"},
	{/* sentinel */}};

/*定义平台设备结构体*/
struct platform_driver led_platform_driver = {
	.probe = led_probe,
	.driver = {
		.name = "rgb-leds-platform",
		.owner = THIS_MODULE,
		.of_match_table = rgb_led,
	}};

/*
*驱动初始化函数
*/
static int __init led_platform_driver_init(void)
{
	int DriverState;
	mutex_init(&lock);
	DriverState = platform_driver_register(&led_platform_driver);
	printk(KERN_ALERT "\tDriverState is %d\n", DriverState);
	return 0;
}

/*
*驱动注销函数
*/
static void __exit led_platform_driver_exit(void)
{
	/*删除设备*/
	device_destroy(class_led, led_devno);		  //清除设备
	class_destroy(class_led);					  //清除类
	cdev_del(&led_chr_dev);						  //清除设备号
	unregister_chrdev_region(led_devno, DEV_CNT); //取消注册字符设备

	/*注销字符设备*/
	platform_driver_unregister(&led_platform_driver);

	printk(KERN_ALERT "led_platform_driver exit!\n");
}

module_init(led_platform_driver_init);
module_exit(led_platform_driver_exit);

MODULE_LICENSE("GPL");

/**/
