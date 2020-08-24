## DTS：硬件资源的说明书1

#### 背景

硬件设备中种类逐年递增，板级platform平台设备文件越来越多

#### 导火索

![image-20200817201149270](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200817201149270.png)

#### 设备树简介

![image-20200817210649042](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200817210649042.png)



- DTS(device tree source)：设备树源文件，ASCII 格式
- DTC(device tree compiler)：设备树编译工具

- DTB(device tree blob)：二进制设备树

##### 设备树使用

uboot负责加载到内存，内核解析使用

##### 设备树源文件

ebf-buster-linux/arch/arm/boot/dts/imx6ull-seeed-npi.dts

##### 二进制设备树

pc：ebf-buster-linux/arch/arm/boot/dts/imx6ull-seeed-npi.dtb

开发板：/boot/dtbs/4.19.71-imx-r1/imx6ull-seeed-npi.dtb

##### 设备树编译工具

内核编译

```
//进行内核配置
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- npi_v7_defconfig

//编译dts
make ARCH=arm -j4 CROSS_COMPILE=arm-linux-gnueabihf- dtbs
```

手工编译

```
./scripts/dtc/dtc -I dts -O dtb -o xxx.dtb arch/arm/boot/dts/xxx.dts // 编译 dts 为 dtb
./scripts/dtc/dtc -I dtb -O dts -o xxx.dts arch/arm/boot/dts/xxx.dtb // 反编译 dtb 为 dts
```

- -I：指定输入格式
- -O：指定输出格式
- -o：指定输出文件

##### 设备树框架

- 从上到下
  - 头文件
  - 主体
  - 子节点追加内容

- 从外到内
  - 属性
  - 其他子节点
    - 属性
    - 其他子节点
    - ...

###### 头文件：

```
#include <dt-bindings/input/input.h>
#include "imx6ull.dtsi"
```

###### 主体：

```
/ {  
    model = "Seeed i.MX6 ULL NPi Board";
    compatible = "fsl,imx6ull-14x14-evk", "fsl,imx6ull";

    aliases {
            pwm0 = &pwm1;
            pwm1 = &pwm2;
            pwm2 = &pwm3;
            pwm3 = &pwm4;
    };
    chosen {
            stdout-path = &uart1;
    };

    memory {
            reg = <0x80000000 0x20000000>;
    };

    reserved-memory {
            #address-cells = <1>;
            #size-cells = <1>;
            ranges;

            linux,cma {
                    compatible = "shared-dma-pool";
                    reusable;
                    size = <0x14000000>;
                    linux,cma-default;
            };
    };
    ...
};
```

- 多个根节点合并
- 根节点下包含多个子节点

###### 子节点追加内容

```
&cpu0 {
    dc-supply = <&reg_gpio_dvfs>;
    clock-frequency = <800000000>;
};

&clks {
    assigned-clocks = <&clks IMX6UL_CLK_PLL4_AUDIO_DIV>;
    assigned-clock-rates = <786432000>;
};


&fec1 {
    pinctrl-names = "default";
    pinctrl-0 = <&pinctrl_enet1>;
    phy-mode = "rmii";
    phy-handle = <&ethphy0>;
    status = "okay";
};
```

#### 节点命令

##### 基本方法

```
node-name@unit-address{

属性1 = …

属性2 = …

属性3= …

子节点…

}
```

- node-name：指定节点的名称
- “unit-address”用于指定“单元地址”

##### 节点标签

```
cpu0: cpu@0 {
    compatible = "arm,cortex-a7";
    device_type = "cpu";
    reg = <0>;
}
```

- cpu0：为节点名称器一个别名

##### 别名子节点

```
    aliases {
    can0 = &flexcan1;
    can1 = &flexcan2;
    ethernet0 = &fec1;
    ethernet1 = &fec2;
	...
}
```

