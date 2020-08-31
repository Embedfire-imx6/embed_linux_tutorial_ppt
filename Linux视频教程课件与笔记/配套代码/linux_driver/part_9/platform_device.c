#include <linux/init.h>
#include <linux/module.h>
#include <linux/mod_devicetable.h>
#include <linux/platform_device.h>


#define CCM_CCGR1 																			  0x20C406C		//时钟控制寄存器
#define IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04 				0x20E006C	  //GPIO1_04复用功能选择寄存器
#define IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04 				 0x20E02F8		//PAD属性设置寄存器
#define GPIO1_GDIR 																			   0x0209C004	//GPIO方向设置寄存器（输入或输出）
#define GPIO1_DR 																				  0x0209C000   //GPIO输出状态寄存器
#define REGISTER_LENGTH																 4							//寄存器长度

/*定义平台设备的硬件资源列表*/
static struct resource rled_resource[] = {
	
	[0] = {
		.start 	= GPIO1_DR,
		.end 	= (GPIO1_DR + REGISTER_LENGTH - 1),
		.flags 	= IORESOURCE_MEM,
	},	
	[1] = {
		.start	= GPIO1_GDIR,
		.end	= (GPIO1_GDIR + REGISTER_LENGTH - 1),
		.flags	= IORESOURCE_MEM,
	},
	[2] = {
		.start	= IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04,
		.end	= (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04 + REGISTER_LENGTH - 1),
		.flags	= IORESOURCE_MEM,
	},
	[3] = {
		.start	= CCM_CCGR1,
		.end	= (CCM_CCGR1 + REGISTER_LENGTH - 1),
		.flags	= IORESOURCE_MEM,
	},
	[4] = {
		.start	= IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04,
		.end	= (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04 + REGISTER_LENGTH - 1),
		.flags	= IORESOURCE_MEM,
	},
};

/*释放paltform设备模块时执行*/
static void	rled_release(struct device *dev)
{
	printk(KERN_ALERT "led device released!\r\n");	
}

/*定义平台设备*/
static struct platform_device rled_pdev = {
	.name = "imx6ull-rled",
	.id = -1,
	.dev.release  = rled_release,
	.num_resources = ARRAY_SIZE(rled_resource),
	.resource = rled_resource,
};

/*模块入口函数，注册平台设备*/
static __init int leddevice_init(void)
{
	printk(KERN_ALERT "leddevice_init\r\n");
	platform_device_register(&rled_pdev);
	return 0;
}

/*模块退出函数，注销平台设备*/
static __exit void leddevice_exit(void)
{
	platform_device_unregister(&rled_pdev);
}

module_init(leddevice_init);
module_exit(leddevice_exit);


MODULE_LICENSE("GPL");
MODULE_AUTHOR("embedfire ");
MODULE_DESCRIPTION("led_module");
MODULE_ALIAS("led_module");