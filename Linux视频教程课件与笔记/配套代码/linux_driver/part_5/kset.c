#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/kobject.h>
#include <linux/string.h>
#include <linux/sysfs.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <asm/io.h>

/* GPIO虚拟地址指针 */
static void __iomem *IMX6U_CCM_CCGR1;
static void __iomem *SW_MUX_GPIO1_IO04;
static void __iomem *SW_PAD_GPIO1_IO04;
static void __iomem *GPIO1_DR;
static void __iomem *GPIO1_GDIR;

static int foo;

static ssize_t foo_show(struct kobject *kobj, struct kobj_attribute *attr,
			char *buf)
{
	return sprintf(buf, "%d\n", foo);
}

static ssize_t foo_store(struct kobject *kobj, struct kobj_attribute *attr,
			 const char *buf, size_t count)
{
	int ret;

	ret = kstrtoint(buf, 10, &foo);
	if (ret < 0)
		return ret;

	return count;
}

static struct kobj_attribute foo_attribute =
	__ATTR(foo, 0664, foo_show, foo_store);


static ssize_t led_show(struct kobject *kobj, struct kobj_attribute *attr,
		      char *buf)
{
	int var;

	if (strcmp(attr->attr.name, "led") == 0)
			var =123;

	return sprintf(buf, "%d\n", var);
}

static ssize_t led_store(struct kobject *kobj, struct kobj_attribute *attr,
		       const char *buf, size_t count)
{

	if (strcmp(attr->attr.name, "led") == 0){
		if(!memcmp(buf,"on",2)) {	
			iowrite32(0 << 4, GPIO1_DR);	
		} else if(!memcmp(buf,"off",3)) {
			iowrite32(1 << 4, GPIO1_DR);
		}
	}
	return count;
}

static struct kobj_attribute led_attribute =
	__ATTR(led, 0664, led_show, led_store);

static struct attribute *attrs[] = {
	&foo_attribute.attr,
	&led_attribute.attr,
	NULL,	/* need to NULL terminate the list of attributes */
};

static struct attribute_group attr_group = {
	.attrs = attrs,
};

static struct kset *example_kset;
static struct kobject *led_kobj;

static int __init led_init(void)
{
	int retval;

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

	/*创建一个kset对象*/
	example_kset = kset_create_and_add("kset_example", NULL, NULL);
	if (!example_kset)
		return -ENOMEM;

	/* 创建一个kobject对象*/
	led_kobj = kobject_create_and_add("led_kobject", &example_kset->kobj);
	if (!led_kobj)
		return -ENOMEM;

	/* 为kobject设置属性文件*/
	retval = sysfs_create_group(led_kobj, &attr_group);
	if (retval)
		kobject_put(led_kobj);

	return retval;

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
	kobject_put(led_kobj);

	/*取消字符设备的注册*/
	kset_unregister(example_kset);
}

module_init(led_init);
module_exit(led_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("embedfire ");
MODULE_DESCRIPTION("led_module");
MODULE_ALIAS("led_module");