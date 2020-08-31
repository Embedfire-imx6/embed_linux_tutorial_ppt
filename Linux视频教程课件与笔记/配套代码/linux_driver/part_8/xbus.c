#include <linux/init.h>
#include <linux/module.h>

#include <linux/device.h>

int xbus_match(struct device *dev, struct device_driver *drv)
{

	printk(KERN_ALERT "%s-%s\n", __FILE__, __func__);
	if (!strncmp(dev_name(dev), drv->name, strlen(drv->name))) {
		printk(KERN_ALERT "dev & drv match\n");
		return 1;
	}
	return 0;

}
static struct bus_type xbus = {
	.name = "xbus",
	.match = xbus_match,
};

EXPORT_SYMBOL(xbus);

static __init int xbus_init(void)
{
    int ret;
	printk(KERN_ALERT "xbus init\n");
	ret = bus_register(&xbus);
    if(ret != 0){
         return -1;
    }
	return 0;
}

module_init(xbus_init);

static __exit void xbus_exit(void)
{
	printk(KERN_ALERT "xbus exit\n");
	bus_unregister(&xbus);
}

module_exit(xbus_exit);

MODULE_AUTHOR("embedfire");
MODULE_LICENSE("GPL");
