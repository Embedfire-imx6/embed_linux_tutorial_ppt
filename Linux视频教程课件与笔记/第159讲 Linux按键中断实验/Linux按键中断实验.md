## Linux按键中断实验

#### 硬件原理图

![image-20200917203137234](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200917203137234.png)

#### 设备树节点

##### iomuxc子节点

```
pinctrl_button: button{
				fsl,pins = <
					MX6UL_PAD_SNVS_TAMPER1__GPIO5_IO01      0x000110A1
				>;
			};
```

##### 自定义按键节点

```
button_interrupt {
    pinctrl-names = "default";
    pinctrl-0 = <&pinctrl_button>;
    button_gpio = <&gpio5 1 GPIO_ACTIVE_LOW>;
    interrupt-parent = <&gpio5>;
    interrupts = <1 IRQ_TYPE_EDGE_RISING>;
};
```



#### irq_of_parse_and_map()函数

drivers/of/irq.c

```
unsigned int irq_of_parse_and_map(struct device_node *dev, int index)
```

参数：

- dev：设备节点
- index：索引号，interrupts属性可能包含多条中断信息

返回值：中断号