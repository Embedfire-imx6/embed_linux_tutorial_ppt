## DTS：硬件资源的说明书2

设备树基本语法

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

#### 常见节点属性

##### compatible属性

值类型：字符串

```
intc: interrupt-controller@a01000 {
    compatible = "arm,cortex-a7-gic";
    #interrupt-cells = <3>;
    interrupt-controller;
    reg = <0xa01000 0x1000>,
          <0xa02000 0x100>;
};
```

- arm：芯片厂商
- cortex-a7-gic：模块对应的驱动名字

##### model属性

值类型：字符串

```
model = "embedfire i.MX6 ULL NPi Board";
```

- 准确描述当前板子型号信息

##### status属性

值类型：字符串

| 状态值     | 描述                                                         |
| ---------- | ------------------------------------------------------------ |
| “okay”     | 设备正常运行                                                 |
| “disabled” | 表明该设备目前尚未运行，但它可能在未来开始运行（例如，某些东西没有插入或关闭）。 |
| “fail”     | 表示设备不可操作。                                           |
| “fail-sss” | 设备不可操作，原因是设备中检测到一个严重的错误，如果没有修复，它就不太可能运行。“sss”的值指示具体的错误起因。 |

##### reg属性

值类型：一系列《地址、长度》对

```
ocrams: sram@900000 {
      compatible = "fsl,lpm-sram";
      reg = <0x900000 0x4000>;
    };
```

- 地址：外设寄存器组的起始地址
- 长度：外设寄存器组的字节长度

##### #address-cells和#size-cells属性

值类型：u32

```
soc {
    #address-cells = <1>;
    #size-cells = <0>;
    compatible = "simple-bus";
    interrupt-parent = <&gpc>;
    ranges;
    ocrams: sram@900000 {
            compatible = "fsl,lpm-sram";
            reg = <0x900000>;
    };
};
```

- #address-cells :设置子节点中reg地址的数量

- #size-cells：设置子节点中reg地址的长度的数量

#### linux系统中查看设备树

```
ls /sys/firmware/devicetree/base
```

或者

```
ls /proc/device-tree
```

- 以目录的形式体现设备树结构

#### 添加子节点

```
test_led{
	#address-cells = <1>;
	#size-cells = <1>;

	rgb_led_red@0x0209C000{
			compatible = "fire,rgb_led_red";
			reg = <0x0209C000 0x00000020>;
			status = "okay";
	};
};
```



