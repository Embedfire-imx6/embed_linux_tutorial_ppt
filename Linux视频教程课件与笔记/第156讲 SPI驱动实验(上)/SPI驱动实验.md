## SPI驱动实验

#### spi回环通信实验

SPI 3的 MIOS与MOSI引脚使用跳线帽短接

#### 硬件原理图

![image-20200915085654223](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200915085654223.png)

- spi3引脚与uart2存在引脚复用，不能同时使用

##### 映射关系

![image-20200915085935052](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200915085935052.png)

#### 设备树节点

arch/arm/boot/dts/imx6ull-seeed-npi.dts

##### pinctrl子节点

```
	pinctrl_ecspi3:ecspi3grp {
					fsl,pins = <
						MX6UL_PAD_UART2_TX_DATA__ECSPI3_SS0     0x1a090
						MX6UL_PAD_UART2_RX_DATA__ECSPI3_SCLK		0x11090
						MX6UL_PAD_UART2_CTS_B__ECSPI3_MOSI			0x11090
						MX6UL_PAD_UART2_RTS_B__ECSPI3_MISO			0x11090
					>;
	};
```

##### spidev子节点

```
&ecspi3{
	fsl,spi-num-chipselects = <1>;
	cs-gpio = <&gpio1 20 GPIO_ACTIVE_LOW>;
	pinctrl-names = "default";
	pinctrl-0 = <&pinctrl_ecspi3>;
	status = "okay";
	#address-cells = <1>;
	#size-cells = <0>; 

	spidev@0 {
		compatible = "spidev";
		spi-max-frequency = <20000000>;
		reg = <0>;
	};
};
```

##### 设备树插件删除

/boot/uEnv.txt

- spi、uart2

规范方面，我也重写了一个章节当模板，你们相互看一下对方的文档，一致认为风格一致，规范统一，再提交到gitlab吧。质量方面，一定要控制好错别字和病句的频率，围绕驱动核心内容，打造自己的亮点