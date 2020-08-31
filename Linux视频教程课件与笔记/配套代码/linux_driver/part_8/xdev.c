#include <linux/init.h>
#include <linux/module.h>
#include <linux/device.h>

extern struct bus_type xbus;

void xdev_release(struct device *dev)
{
	printk(KERN_ALERT "%s-%s\n", __FILE__, __func__);
}

static struct device xdev = {
	.init_name = "xdev",
	.bus = &xbus,
	.release = xdev_release,
};

static __init int xdev_init(void)
{
    int ret;
	printk(KERN_ALERT "xdev init\n");
	ret = device_register(&xdev);
    if(ret != 0){
         return -1;
    }
       
	return 0;
}

static __exit void xdev_exit(void)
{
	printk(KERN_ALERT "xdev exit\n");
	device_unregister(&xdev);
}

module_init(xdev_init);
module_exit(xdev_exit);

MODULE_AUTHOR("embedfire");
MODULE_LICENSE("GPL");
