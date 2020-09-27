## 输入(input)子系统实验

#### 通用输入设备(evdev.c)识别

- /dev/input/event0
- /dev/input/event1
- ...

#### 查看输入设备名和event对应关系

```
cat /proc/bus/input/devices
```



#### BIT_MASK宏

include/asm-generic/bitops/non-atomic.h

```
#define BIT_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
```



#### input_set_capability()函数

drivers/input/input.c

```
void input_set_capability(struct input_dev *dev, unsigned int type, unsigned int code)
{
	switch (type) {
	case EV_KEY:
		__set_bit(code, dev->keybit);
		break;

	case EV_REL:
		__set_bit(code, dev->relbit);
		break;

	case EV_ABS:
		input_alloc_absinfo(dev);
		if (!dev->absinfo)
			return;

		__set_bit(code, dev->absbit);
		break;
	...
}
```

