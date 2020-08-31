## gpio1节点：GPIO子系统初窥

- GPIO1控制器的寄存器基地址

- 类似的还有gpio2~5

#### gpio1节点

**imx6ull.dtsi**

```
gpio1: gpio@209c000 {
				compatible = "fsl,imx6ul-gpio", "fsl,imx35-gpio";
				reg = <0x209c000 0x4000>;
				interrupts = <GIC_SPI 66 IRQ_TYPE_LEVEL_HIGH>,
					     <GIC_SPI 67 IRQ_TYPE_LEVEL_HIGH>;
				clocks = <&clks IMX6UL_CLK_GPIO1>;
				gpio-controller;
				#gpio-cells = <2>;
				interrupt-controller;
				#interrupt-cells = <2>;
				gpio-ranges = <&iomuxc  0 23 10>, <&iomuxc 10 17 6>,
					      <&iomuxc 16 33 16>;
			};
```

- compatible：与GPIO子系统的平台驱动做匹配

- reg：GPIO寄存器的基地址

  ![image-20200709145109364](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709145109364.png)

  ![image-20200709145133580](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709145133580.png)

- interrupts：GPIO中断相关
- clocks：GPIO外设时钟相关
- gpio-controller：表示 gpio1 节点是个 GPIO 控制器
- #gpio-cells：表示要用2个cell描述一个 GPIO引脚
- interrupt-controller：表示 gpio1 节点是个中断控制器

- #interrupt-cells：表示要用2个cell描述一个中断
- gpio-ranges：gpio编号转换成pin编号

**imx6ull-seeed-npi.dts**

新增rgb_led节点，使用gpio子系统

```
rgb_led{
    #address-cells = <1>;
    #size-cells = <1>;
    pinctrl-names = "default";
    compatible = "fire,rgb_led";
    pinctrl-0 = <&pinctrl_rgb_led>;
    rgb_led_red = <&gpio1 4 GPIO_ACTIVE_LOW &gpio1 10 GPIO_ACTIVE_LOW>;
    rgb_led_green = <&gpio4 20 GPIO_ACTIVE_LOW>;
    rgb_led_blue = <&gpio4 19 GPIO_ACTIVE_LOW>;
    status = "okay";
};
```

- rgb_led_red：自定义属性，&gpio1 4表示GPIO1_IO04，GPIO_ACTIVE_LOW表示低电平有效



#### 常用函数

##### of_find_node_by_path()函数

函数原型：

```
inline struct device_node *of_find_node_by_path(const char *path)
```

参数：

- path：设备树节点的绝对路径

返回值：

- 成功：目标节点

- 失败：NULL



##### of_get_named_gpio()函数

函数原型：

```
static inline int of_get_named_gpio(struct device_node *np,const char *propname, int index)
```

参数：

- np：指定的设备树节点
- propname：GPIO属性名
- index：引脚索引值

返回值：

- 成功：GPIO编号
- 失败：负数



##### gpio_request()函数

函数原型：

```
static inline int gpio_request(unsigned gpio, const char *label)
```

参数：

- gpio：要申请的GPIO编号
- label：给 gpio 设置个名字

返回值：

- 成功：0
- 失败：负数



##### gpio_free()函数

函数原型：

```
static inline void gpio_free(unsigned gpio);
```

参数：

- gpio：要释放的GPIO编号

返回值：

无



##### gpio_direction_output()函数

函数原型：

```
static inline int gpio_direction_output(unsigned gpio , int value)；
```

参数：

- gpio：要操作的GPIO编号

- value：设置默认输出值

返回值：

- 成功：0
- 失败：负数



##### gpio_direction_input()函数

函数原型：

```
int gpio_direction_input(unsigned gpio)
```

参数：

- gpio：要操作的GPIO编号

返回值：

- 成功：0
- 失败：负数



##### gpio_get_value()函数

函数原型：

```
#define gpio_get_value __gpio_get_value
int __gpio_get_value(unsigned gpio)
```

参数：

- gpio：要操作的GPIO编号

返回值：

- 成功： GPIO的电平值
- 失败：负数



##### gpio_set_value()函数

函数原型：

```
#define gpio_set_value __gpio_set_value
void __gpio_set_value(unsigned gpio, int ;)
```

参数：

- gpio：要操作的GPIO编号
- value：要设置的输出值

返回值：

无