### GPIO控制原理

#### 了解GPIO

##### 数量

 5 组 GPIO（GPIO1～GPIO5），每组最多32个，共124个

- GPIO1_IO0~GPIO1_IO31

- GPIO2_IO0~GPIO2_IO21

- GPIO3_IO0~GPIO3_IO28

- GPIO4_IO0~GPIO4_IO28

- GPIO5_IO0~GPIO5_IO11

  

数据手册描述

28.2 External Signals  

![image-20200708154130978](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200708154130978.png)

####  时钟

clock controller module(CCM模块)用于配置芯片的各种外设时钟。跟GPIO相关的时钟主要有CCM_CCGR(0~3)寄存器。

数据手册描述

18.4 System Clocks  

![image-20200709165104020](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709165104020.png)



18.6.24 CCM Clock Gating Register 1 (CCM_CCGR1)  

![image-20200709103942709](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709103942709.png)

![image-20200709104035974](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709104035974.png)

两个bit的不同取值，设置GPIO时钟的不同属性：

- 00：所有模式下都关闭外设时钟
- 01：只有在运行模式下打开外设时钟
- 10：保留
- 11：除了停止模式以外，该外设时钟全程使能



数据手册描述

18.6.23 CCM Clock Gating Register 0 (CCM_CCGR0)  

![image-20200709085430441](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709085430441.png)

#### 引脚复用

相关寄存器：IOMUXC_SW_MUX_CTL_PAD_XXX

数据手册：

![image-20200709092153654](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709092153654.png)

注意：数据手册上对GPIO引脚的命令，不是严格按顺序命名的，而是根据Table 28来命名的



32.6.11 SW_MUX_CTL_PAD_GPIO1_IO04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04)  

![image-20200709144736529](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709144736529.png)

- 0101：ALT5 ->普通GPIO模式

  ##### 引脚属性

  相关寄存器：IOMUXC_SW_PAD_CTL_PAD_XXX

  数据手册：

  ![image-20200709093516948](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709093516948.png)

  注意：数据手册上对GPIO引脚的命令，不是严格按顺序命名的，而是根据Table 28来命名的




32.6.157 SW_PAD_CTL_PAD_GPIO1_IO04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04)  

![image-20200709144922421](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709144922421.png)

​			 ![image-20200709144945084](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709144945084.png)				

​				- HYS（bit16）：用来使能迟滞比较器 

​				- PUS（bit15-bit14）：用来设置上下拉电阻大小

​				- PUE（bit13）：当 IO 作为输入的时候，这个位用来设置 IO 使用上下拉还是状态保持器

​				- PKE（bit12）：用来使能或者禁止上下拉/状态保持器功能

​				- ODE（bit11）：IO 作为输出的时候，此位用来禁止或者使能开漏输出。

​				- SPEED（bit7-bit6）：当 IO 用作输出的时候，此位用来设置 IO 速度。

​				- DSE（bit5-bit3）：当 IO 用作输出的时候用来设置 IO 的驱动能力。

​				- SRE（bit0）：设置压摆率



#### 控制GPIO引脚

5组GPIO,每组GPIO有8个相关寄存器

- GPIOx_GDIR：设置引脚方向
- GPIOx_DR：设置输出引脚的电平
- ...

每个寄存器有32位，分别控制每位的gpio



​	数据手册描述：

​	28.5.2 GPIO direction register (GPIOx_GDIR)  

![image-20200709101004415](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709101004415.png)

​	- 0：输入

​	- 1：输出



28.5.1 GPIO data register (GPIOx_DR)  

![image-20200709101241615](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709101241615.png)



2.2 ARM Platform Memory Map  

![image-20200709145109364](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709145109364.png)

![image-20200709145133580](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709145133580.png)

控制GPIO总结

- 使能GPIO时钟

- 设置引脚复用为GPIO
- 设置引脚属性(上下拉、速率、驱动能力)
- 控制GPIO引脚输出高低电平



硬件原理图：

![image-20200709102918018](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709102918018.png)



​	![image-20200709102946541](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709102946541.png)



![image-20200709103157453](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200709103157453.png)

