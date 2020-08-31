#include <linux/init.h>
#include <linux/module.h>

#include <linux/device.h>

extern struct bus_type xbus;

int xdrv_probe(struct device *dev)
{
	printk(KERN_ALERT "%s-%s\n", __FILE__, __func__);
	return 0;
}

int xdrv_remove(struct device *dev)
{
	printk(KERN_ALERT "%s-%s\n", __FILE__, __func__);
	return 0;
}

static struct device_driver xdrv = {
	.name = "xdev",
	.bus = &xbus,
	.probe = xdrv_probe,
	.remove = xdrv_remove,
};

static __init int xdrv_init(void)
{
    int ret;
	printk( KERN_ALERT"xdrv init\n");
	ret = driver_register(&xdrv);
    if(ret != 0){
         return -1;
    }
	return 0;
}

static __exit void xdrv_exit(void)
{
	printk(KERN_ALERT "xdrv exit\n");
	driver_unregister(&xdrv);
}

module_init(xdrv_init);
module_exit(xdrv_exit);

MODULE_AUTHOR("embedfire");
MODULE_LICENSE("GPL");
