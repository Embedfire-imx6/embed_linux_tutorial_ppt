## 设备树实现RGB灯驱动

[TOC]

#### 设备树添加节点信息

- RGB灯的相关寄存器

```
/*
*CCM_CCGR1                         0x020C406C
*IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04  0x020E006C
*IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04  0x020E02F8
*GPIO1_GD                          0x0209C000
*GPIO1_GDIR                        0x0209C004
*/


/*
*CCM_CCGR3                         0x020C4074
*IOMUXC_SW_MUX_CTL_PAD_CSI_HSYNC   0x020E01E0
*IOMUXC_SW_PAD_CTL_PAD_CSI_HSYNC   0x020E046C
*GPIO4_GD                          0x020A8000
*GPIO4_GDIR                        0x020A8004
*/


/*
*CCM_CCGR3                         0x020C4074
*IOMUXC_SW_MUX_CTL_PAD_CSI_VSYNC   0x020E01DC
*IOMUXC_SW_PAD_CTL_PAD_CSI_VSYNC   0x020E0468
*GPIO4_GD                          0x020A8000
*GPIO4_GDIR                        0x020A8004
*/
	/*添加led节点*/
	rgb_led{
		#address-cells = <1>;
		#size-cells = <1>;
		compatible = "fire,rgb_led";

		/*红灯节点*/
		ranges;
		rgb_led_red@0x020C406C{
			reg = <0x020C406C 0x00000004
			       0x020E006C 0x00000004
			       0x020E02F8 0x00000004
				   0x0209C000 0x00000004
			       0x0209C004 0x00000004>;
			status = "okay";
		};

		/*绿灯节点*/
		rgb_led_green@0x020C4074{
			reg = <0x020C4074 0x00000004
			       0x020E01E0 0x00000004
			       0x020E046C 0x00000004
				   0x020A8000 0x00000004
			       0x020A8004 0x00000004>;
			status = "okay";
		};

		/*蓝灯节点*/
		rgb_led_blue@0x020C4074{
			reg = <0x020C4074 0x00000004
			       0x020E01DC 0x00000004
			       0x020E0468 0x00000004
				   0x020A8000 0x00000004
			       0x020A8004 0x00000004>;
			status = "okay";
		};
	};
```



#### reg属性内存映射

##### of_iomap()函数

将reg属性值的物理地址转化为虚拟地址

```
void __iomem *of_iomap(struct device_node *np,
int index)
```

参数：

- np：device_node表示的节点
- index：通常情况下reg属性包含多段，index 用于指定映射那一段，标号从0开始。