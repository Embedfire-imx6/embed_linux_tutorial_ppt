## Linux PWM驱动实验

##### PWM控制

脉冲宽度调制

##### PWM信号

![image-20200924141256029](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200924141256029.png)

##### 相关寄存器

Chapter 40 Pulse Width Modulation(PWM)

- PWMx_PWMPR：频率
- PWMx_PWMSAR：占空比

#### 硬件原理图

EBF6ULL pro开发板--RGB红灯

#### 设备树节点

pwm1~pwm8

##### pwm3子节点

arch/arm/boot/dts/imx6ull.dtsi

```
pwm3: pwm@2088000 {
				compatible = "fsl,imx6ul-pwm", "fsl,imx27-pwm";
				reg = <0x2088000 0x4000>;
				interrupts = <GIC_SPI 85 IRQ_TYPE_LEVEL_HIGH>;
				clocks = <&clks IMX6UL_CLK_PWM3>,
					 <&clks IMX6UL_CLK_PWM3>;
				clock-names = "ipg", "per";
				#pwm-cells = <2>;
			};
```

##### iomuxc子节点

```
red_led_pwm: ledsgrp {
	        	fsl,pins = <
	        		MX6UL_PAD_GPIO1_IO04__PWM3_OUT 0x1b0b0
	        	>;
			};
```

##### red_led_pwm子节点

arch/arm/boot/dts/imx6ull-seeed-npi.dts

```
red_led_pwm {
	        	compatible = "red_led_pwm";
	        	pinctrl-names = "default";
	        	pinctrl-0 = <&red_led_pwm>;

	        	xxx {
					pwm-names = "red_led_pwm3";
	        		pwms = <&pwm3 0 50000>;
	        	};
 };
```

- pwm-names：给指定一路pwm起别名
- pwms：
  - pwm3：指定使用第3路pwm信号
  - 0：pwm3引脚端口号
  - 50000：设置周期，单位ns

#### pwm_device结构体

include/linux/pwm.h

```
struct pwm_device {
	const char *label;
	unsigned long flags;
	unsigned int hwpwm;
	unsigned int pwm;
	struct pwm_chip *chip;
	void *chip_data;

	struct pwm_args args;
	struct pwm_state state;
};
```

##### pwm_state结构体

include/linux/pwm.h

```
struct pwm_state {
	unsigned int period;
	unsigned int duty_cycle;
	enum pwm_polarity polarity;
	bool enabled;
};
```

- period：pwm的周期
- duty_cycle：pwm占空比

- polarity：是否反相输出
- enable：使能标志位

##### pwm_polarity枚举变量

include/linux/pwm.h

```
enum pwm_polarity {
    PWM_POLARITY_NORMAL,	//正常模式，不反相
    PWM_POLARITY_INVERSED,	//反相输出
};
```



#### 获取pwm_device

##### devm_of_pwm_get()函数

drivers/pwm/core.c

解析pwm设备树节点信息，生成pwm_device对象

```
struct pwm_device *devm_of_pwm_get(struct device *dev, struct device_node *np,const char *con_id)
```

参数：

- dev：使用pwm的设备

- np：pwm设备子节点 
- con_id：设备树节点"pwm-names"匹配名

返回值：

- 成功：pwm_device结构体指针
- 失败：负数



#### 配置pwm频率和占空比

##### pwm_config()函数

include/linux/pwm.h

```
static inline int pwm_config(struct pwm_device *pwm, int duty_ns,
			     int period_ns)
```

参数：

- pwm：pwm_device对象
- duty_ns：高电平持续时间，单位ns
- period_ns：周期时间，单位ns

返回值：

- 成功：0
- 失败：负数



#### 配置pwm极性

```
static inline int pwm_set_polarity(struct pwm_device *pwm,
				   enum pwm_polarity polarity)
```

参数：

- pwm：pwm_device对象
- polarity：

返回值：

- 成功：0
- 失败：负数



#### 使能pwm输出

```
static inline int pwm_enable(struct pwm_device *pwm)
```

参数：

- pwm：pwm_device对象

返回值：

- 成功：0
- 失败：负数



#### 禁止pwm输出

```
static inline void pwm_disable(struct pwm_device *pwm)
```

参数：

- pwm：pwm_device对象

返回值：无