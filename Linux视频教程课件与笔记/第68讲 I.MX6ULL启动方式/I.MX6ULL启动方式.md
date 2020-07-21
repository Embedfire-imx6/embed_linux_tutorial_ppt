##  I.MX6ULL启动方式

#### 启动模式设置步骤

1. 三大模式

   - 熔丝：烧录一次，发布产品

   - 外部：USB、串口等

   - 内部：SD卡、eMMC、NAND

   ##### 设置方法：

   (BOOT_MODE0\BOOT_MODE1 )

2. 内部介质

- SD

- eMMC

- Nand

  ##### 设置方法：

  BT_CFG1[4:7] 

3. 接口编号

   ##### 设置方法：

   BOOT_CFG2[3]

4. 介质属性

- SD/eMMC：位宽(BT_CFG2[5] )
- ...

#### 原理图

![1593759869058](.\pic\1593759869058.png)



#### 芯片手册截图

##### 开机相关全部引脚

8.3.2 GPIO boot overrides

![1593747001529](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1593747001529.png)

![1593747300235](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1593747300235.png)

1. 熔丝/外部/内部

8.2.1 Boot mode pin settings

![1593747870057](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1593747870057.png)

2. 内部介质

8.5 Boot devices (internal boot)

![1593746641018](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1593746641018.png)

3. 接口编号、介质属性

   5.1 Boot Fusemap

   ![1593759656082](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1593759656082.png)



#### 启动设置

![1593759929362](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1593759929362.png)