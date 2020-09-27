## LCD驱动框架分析

#### 裸机开发--lcd显示原理

- 相关寄存器
  - 分辨率
  - 显示时序(6个时间参数)
  - 显存地址

#### framebuffer机制

帧缓冲

- 显示图像信息
- /dev/fbx(x=0~n)

#### 分层模型

- ##### 核心层

  drivers/video/fbdev/core/fbmem.c

  linux内核实现

  - 创建graphics设备类，占据主设备号29
  - 为不同的显示设备提供文件通用处理接口

- ##### 硬件设备层

  驱动人员实现

  - 提供显示时序、显存、像素格式等硬件信息
  - 提供显示设备的私有文件操作接口
  - 创建lcd设备文件/dev/fbx(x=0~n)



#### 核心层分析

drivers/video/fbdev/core/fbmem.c

##### 创建graphics设备类，占据主设备号29

```
static int __init
fbmem_init(void)
{
	int ret;

	if (!proc_create_seq("fb", 0, NULL, &proc_fb_seq_ops))
		return -ENOMEM;

	ret = register_chrdev(FB_MAJOR, "fb", &fb_fops);
	if (ret) {
		printk("unable to get major %d for fb devs\n", FB_MAJOR);
		goto err_chrdev;
	}

	fb_class = class_create(THIS_MODULE, "graphics");
	if (IS_ERR(fb_class)) {
		ret = PTR_ERR(fb_class);
		pr_warn("Unable to create fb class; errno = %d\n", ret);
		fb_class = NULL;
		goto err_class;
	}

	fb_console_init();

	return 0;

err_class:
	unregister_chrdev(FB_MAJOR, "fb");
err_chrdev:
	remove_proc_entry("fb", NULL);
	return ret;
}
```

##### FB_MAJOR宏

/usr/include/linux/major.h

```
#define FB_MAJOR		29
```

##### fb_fops文件操作接口

drivers/video/fbdev/core/fbmem.c

```
static const struct file_operations fb_fops = {
	.owner =	THIS_MODULE,
	.read =		fb_read,
	.write =	fb_write,
	.unlocked_ioctl = fb_ioctl,
#ifdef CONFIG_COMPAT
	.compat_ioctl = fb_compat_ioctl,
#endif
	.mmap =		fb_mmap,
	.open =		fb_open,
	.release =	fb_release,
#if defined(HAVE_ARCH_FB_UNMAPPED_AREA) || \
	(defined(CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA) && \
	 !defined(CONFIG_MMU))
	.get_unmapped_area = get_fb_unmapped_area,
#endif
#ifdef CONFIG_FB_DEFERRED_IO
	.fsync =	fb_deferred_io_fsync,
#endif
	.llseek =	default_llseek,
};

```



#### 硬件设备层分析

##### fb_info 结构体

include/linux/fb.h

```
struct fb_info {
	atomic_t count;
	int node;
	int flags;
	
	int fbcon_rotate_hint;
	struct mutex lock;		/* Lock for open/release/ioctl funcs */
	struct mutex mm_lock;		/* Lock for fb_mmap and smem_* fields */
	struct fb_var_screeninfo var;	/* Current var */
	struct fb_fix_screeninfo fix;	/* Current fix */
	struct fb_monspecs monspecs;	/* Current Monitor specs */
	struct work_struct queue;	/* Framebuffer event queue */
	struct fb_pixmap pixmap;	/* Image hardware mapper */
	struct fb_pixmap sprite;	/* Cursor hardware mapper */
	struct fb_cmap cmap;		/* Current cmap */
	struct list_head modelist;      /* mode list */
	struct fb_videomode *mode;	/* current mode */

#ifdef CONFIG_FB_BACKLIGHT
	/* assigned backlight device */
	/* set before framebuffer registration, 
	   remove after unregister */
	struct backlight_device *bl_dev;

	/* Backlight level curve */
	struct mutex bl_curve_mutex;	
	u8 bl_curve[FB_BACKLIGHT_LEVELS];
#endif
#ifdef CONFIG_FB_DEFERRED_IO
	struct delayed_work deferred_work;
	struct fb_deferred_io *fbdefio;
#endif

	struct fb_ops *fbops;
	struct device *device;		/* This is the parent */
	struct device *dev;		/* This is this fb device */
	int class_flag;                    /* private sysfs flags */
#ifdef CONFIG_FB_TILEBLITTING
	struct fb_tile_ops *tileops;    /* Tile Blitting */
#endif
	union {
		char __iomem *screen_base;	/* Virtual address */
		char *screen_buffer;
	};
	unsigned long screen_size;	/* Amount of ioremapped VRAM or 0 */ 
	void *pseudo_palette;		/* Fake palette of 16 colors */ 
...
};
```

-  var、fix、screen_base、screen_size：提供显示时序、显存、像素格式等硬件信息

- fbops：显示设备的私有文件操作接口



#### register_framebuffer()函数

drivers/video/fbdev/core/fbmem.c

```
register_framebuffer(struct fb_info *fb_info)
{
	int ret;

	mutex_lock(&registration_lock);
	ret = do_register_framebuffer(fb_info);
	mutex_unlock(&registration_lock);

	return ret;
}
```

##### do_register_framebuffer()函数

drivers/video/fbdev/core/fbmem.c

```
static int do_register_framebuffer(struct fb_info *fb_info)
{
	...
	for (i = 0 ; i < FB_MAX; i++)
		if (!registered_fb[i])
			break;
	fb_info->node = i;
	...
	fb_info->dev = device_create(fb_class, fb_info->device,
				     MKDEV(FB_MAJOR, i), NULL, "fb%d", i);
    ...
}
```

##### registered_fb数组

drivers/video/fbdev/core/fbmem.c

```
struct fb_info *registered_fb[FB_MAX]
```

##### FB_MAX宏

include/uapi/linux/fb.h

```
#define FB_MAX			32	/* sufficient for now */
```



##### fb_open()函数

drivers/video/fbdev/core/fbmem.c

```
static int fb_open(struct inode *inode, struct file *file)
{
	int fbidx = iminor(inode);
	struct fb_info *info;
	int res = 0;

	info = get_fb_info(fbidx);
	...
	file->private_data = info;
	if (info->fbops->fb_open) {
		res = info->fbops->fb_open(info,1);
		if (res)
			module_put(info->fbops->owner);
	}
#ifdef CONFIG_FB_DEFERRED_IO
	if (info->fbdefio)
		fb_deferred_io_open(info, inode, file);
#endif
out:
	mutex_unlock(&info->lock);
	if (res)
		put_fb_info(info);
	return res;
}
```

