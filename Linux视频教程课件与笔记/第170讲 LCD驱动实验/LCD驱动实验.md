## LCD驱动实验

#### 硬件原理图

![1595577582841](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1595577582841.png)

#### 设备树节点

arch/arm/boot/dts/imx6ull-seeed-npi.dts

##### iomuxc子节点

```
pinctrl_lcdif_dat: lcdifdatgrp {
			    fsl,pins = <
			        MX6UL_PAD_LCD_DATA00__LCDIF_DATA00  0x79
			        MX6UL_PAD_LCD_DATA01__LCDIF_DATA01  0x79
			        MX6UL_PAD_LCD_DATA02__LCDIF_DATA02  0x79
			        MX6UL_PAD_LCD_DATA03__LCDIF_DATA03  0x79
			        MX6UL_PAD_LCD_DATA04__LCDIF_DATA04  0x79
			        MX6UL_PAD_LCD_DATA05__LCDIF_DATA05  0x79
			        MX6UL_PAD_LCD_DATA06__LCDIF_DATA06  0x79
			        MX6UL_PAD_LCD_DATA07__LCDIF_DATA07  0x79
			        MX6UL_PAD_LCD_DATA08__LCDIF_DATA08  0x79
			        MX6UL_PAD_LCD_DATA09__LCDIF_DATA09  0x79
			        MX6UL_PAD_LCD_DATA10__LCDIF_DATA10  0x79
			        MX6UL_PAD_LCD_DATA11__LCDIF_DATA11  0x79
			        MX6UL_PAD_LCD_DATA12__LCDIF_DATA12  0x79
			        MX6UL_PAD_LCD_DATA13__LCDIF_DATA13  0x79
			        MX6UL_PAD_LCD_DATA14__LCDIF_DATA14  0x79
			        MX6UL_PAD_LCD_DATA15__LCDIF_DATA15  0x79
			        MX6UL_PAD_LCD_DATA16__LCDIF_DATA16  0x79
			        MX6UL_PAD_LCD_DATA17__LCDIF_DATA17  0x79
			        MX6UL_PAD_LCD_DATA18__LCDIF_DATA18  0x79
			        MX6UL_PAD_LCD_DATA19__LCDIF_DATA19  0x79
			        MX6UL_PAD_LCD_DATA20__LCDIF_DATA20  0x79
			        MX6UL_PAD_LCD_DATA21__LCDIF_DATA21  0x79
			        MX6UL_PAD_LCD_DATA22__LCDIF_DATA22  0x79
			        MX6UL_PAD_LCD_DATA23__LCDIF_DATA23  0x79
			    >;
			};
			
pinctrl_lcdif_ctrl: lcdifctrlgrp {
    			fsl,pins = <
    			    MX6UL_PAD_LCD_CLK__LCDIF_CLK	    0x79
    			    MX6UL_PAD_LCD_ENABLE__LCDIF_ENABLE  0x79
    			    MX6UL_PAD_LCD_HSYNC__LCDIF_HSYNC    0x79
    			    MX6UL_PAD_LCD_VSYNC__LCDIF_VSYNC    0x79
    			>;
			};
			
pinctrl_pwm1: pwm1grp {
				fsl,pins = <
					MX6UL_PAD_GPIO1_IO08__PWM1_OUT 0x110b0
				>;
			};
```

##### backlight子节点

```
backlight {
    compatible = "pwm-backlight";
	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_pwm1>;
    pwms = <&pwm1 0 5000000>;
    brightness-levels = <0 4 8 16 32 64 128 255>;
    default-brightness-level = <6>;
    status = "okay";
};
```

##### lcdif节点

arch/arm/boot/dts/imx6ull.dtsi

```
	lcdif: lcdif@21c8000 {
				compatible = "fsl,imx6ul-lcdif", "fsl,imx28-lcdif";
				reg = <0x21c8000 0x4000>;
				interrupts = <GIC_SPI 5 IRQ_TYPE_LEVEL_HIGH>;
				clocks = <&clks IMX6UL_CLK_LCDIF_PIX>,
					 <&clks IMX6UL_CLK_LCDIF_APB>,
					 <&clks IMX6UL_CLK_DUMMY>;
				clock-names = "pix", "axi", "disp_axi";
				status = "disabled";
			};
```

##### lcd设备节点

Documentation\devicetree\binding

```
&lcdif {
	pinctrl-names = "default";
    pinctrl-0 = <&pinctrl_lcdif_dat &pinctrl_lcdif_ctrl>;
    display = <&display0>;
    status = "okay";
    display0: display {
        bits-per-pixel = <32>;
        bus-width = <24>;
            display-timings {
                native-mode = <&timing1>;
                    timing1: timing1 {
                    mode_name = "TFT50AB";
                    clock-frequency = <27000000>;
                    hactive = <800>;
                    vactive = <480>;
                    hfront-porch = <23>;
                    hback-porch = <46>;
                    hsync-len = <1>;
                    vback-porch = <22>;
                    vfront-porch = <22>;
                    vsync-len = <1>;

                    hsync-active = <0>;
                    vsync-active = <0>;
                    de-active = <1>;
                    pixelclk-active = <0>;
                  };
			};
		};
};
```

- display：lcd属性信息
- bits-per-pixel：一个像素占用24bit
- bus-width：总线宽度
- native-mode：时序信息
-  clock-frequency：lcd像素时钟，单位Hz
- hactive：x轴像素个数
- vactive：y轴像素个数
- hfront-porch、hback-porch、hsync-len、vback-porch、vfront-porch、vsync-len：时序参数
- *-active：时钟极性



#### mmap()函数

\#include <sys/mman.h>

将文件内容映射到内存

```
void *mmap(void *addr, size_t length, int prot, int flags,int fd, off_t offset);
```

参数：

- addr：表示指定映射的內存起始地址，通常设为 NULL表示让系统自动选定地址
- length：表示将文件中多大的内容映射到内存中
- prot：表示映射区域的保护方式
  - PROT_EXEC ：映射区域可被执行
  - PROT_READ ：映射区域可被读取
  - PROT_WRITE ：映射区域可被写入
  - PROT_NONE ：映射区域不能被访问

- Flags：映射区域的不同特性

  - MAP_SHARED：共享映射，多个进程实时看到文件映射内容的变化，映射内容写入到磁盘文件
  - MAP_PRIVATE：匿名映射，其他进程无法看到映射内容变化，映射内容不会写入到磁盘文件

  - ...



#### 位图转换器 SEGGER

图片转化c文件

《emWin应用开发实战指南》--第11章 显示位图

-  ARGB格式

