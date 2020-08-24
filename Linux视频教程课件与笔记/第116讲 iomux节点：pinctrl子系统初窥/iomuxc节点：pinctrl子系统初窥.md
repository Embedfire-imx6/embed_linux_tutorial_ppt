## iomuxc节点：pinctrl子系统初窥

- 汇总所需引脚的配置信息
- pinctrl子系统预存iomux节点信息

#### iomuxc节点

- **imx6ull.dtsi**

  ```
  iomuxc: iomuxc@20e0000 {
  				compatible = "fsl,imx6ul-iomuxc";
  				reg = <0x20e0000 0x4000>;
  			};
  ```

  - compatible：与pinctrl子系统的平台驱动做匹配
  - reg：引脚配置寄存器的基地址

- **imx6ull-seeed-npi.dts**

  ```
  &iomuxc {
  	pinctrl-names = "default"，"init","sleep";
  	pinctrl-0 = <&pinctrl_hog_1>;
  	pinctrl-1 =<&xxx>;
  	pinctrl-2 =<&yyy>;
  ...
  	pinctrl_uart1: uart1grp {
  		fsl,pins = <
  			MX6UL_PAD_UART1_TX_DATA__UART1_DCE_TX 0x1b0b1
  			MX6UL_PAD_UART1_RX_DATA__UART1_DCE_RX 0x1b0b1
  		>;
  	};
  ...
  }
  ```

#### 节点引脚配置方式

- pinctrl-names：定义引脚状态

- pinctrl-0：定义第0种状态需要使用到的引脚,可引用其他节点标识
- pinctrl-1：定义第1种状态需要使用到的引脚，以此类推
- ...

#### 节点配置信息记录

- **fsl,pins**

  - 结合imx6ull的pinctrl子系统驱动使用
  - 以该属性来标识引脚的配置信息

- **fsl,pins属性值**

  一个宏+一个十六进制数

  ```
  MX6UL_PAD_UART1_TX_DATA__UART1_DCE_TX 0x1b0b1
  ```

- **宏定义原型**

   imx6ull.dtsi ->#include "imx6ull-pinfunc.h"->\#include "imx6ul-pinfunc.h"

  ```
  #define MX6UL_PAD_UART1_TX_DATA__UART1_DCE_TX 0x0084 0x0310 0x0000 0 0
  ```

- **宏值含义**

  ```
  <mux_reg conf_reg input_reg mux_mode input_val>
   0x0084    0x0310    0x0000     0x0      0x0
  ```

  - mux_reg：引脚复用设置寄存器

    ![image-20200821153238037](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200821153238037.png)

  - conf_reg：引脚属性设置寄存器

    ![image-20200821153304942](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200821153304942.png)

  - input_reg：引脚输入设置寄存器
    
  - 引脚需要输入功能时设置
    
  - mux_mode：复用寄存器设置值
    
  - 设置引脚复用
    
  - input_value：输入寄存器设置值
    
    - 设置引脚输入特性

- **十六进制数**

  属性寄存器设置值

  - 特性复杂，独立设置

