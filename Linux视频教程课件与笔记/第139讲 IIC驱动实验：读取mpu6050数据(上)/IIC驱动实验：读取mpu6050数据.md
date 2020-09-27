## IIC驱动实验：读取mpu6050数据

#### MPU6050

空间运动传感器芯片

- 3轴加速度
- 3轴角速度

#### 硬件原理图

![image-20200903171355402](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200903171355402.png)

#### 设备树节点

##### iomuxc子节点

```
pinctrl_i2c1: i2c1grp {
        		fsl,pins = <
        			MX6UL_PAD_UART4_TX_DATA__I2C1_SCL 0x4001b8b0
        			MX6UL_PAD_UART4_RX_DATA__I2C1_SDA 0x4001b8b0
        		>;
        	}; 
```

##### i2c1子节点

```

&i2c1{
	clock-frequency = <100000>;
	pinctrl-names = "default";
	pinctrl-0 = <&pinctrl_i2c1>;
	status = "okay";
	
	i2c_mpu6050@68 {
	        	compatible = "fire,i2c_mpu6050";
	        	reg = <0x68>;
	        	status = "okay";
	 };
};
```

