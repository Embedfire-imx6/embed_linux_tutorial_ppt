## LCD显示原理

#### 硬件原理图

![1595577582841](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1595577582841.png)

- R[7:0] ：红色数据线
- G[7:0]：绿色数据线
- B[7:0] ：蓝色数据线
- BL：背光灯控制
- VSYNC：帧同步信号线
- HSYNC：行同步信号线
- PCLK：像素时钟信号线
- DE：数据使能线

#### 基本原理

视频显示可以理解为多帧图片播放，每帧图片按行显示，每行图片数据由多个像素点构成

#### 显示时序 

![1595555229383](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1595555229383.png)

#### 时间参数

- VSW(tVPW 、tvp)：帧信号的脉冲宽度，表示触发一个帧信号
- VBP（tVBP ）：帧信号开始缓冲时间
- VFP(tVFP  )：帧信号结束缓冲时间
- HSW(HSPW、tHPW)：行信号的脉冲宽度，表示触发一个行信号
- HBP(thb、tHBP )：行信号开始缓冲时间
- HFP(thf、tHFP )：行信号结束缓存时间

5.0寸液晶屏数据手册

3.3.3. Timing 

![1595560378796](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1595560378796.png)

![1595560410756](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1595560410756.png)

#### 常见参数

- 分辨率

  每帧图片行数*每行像素点数

- 像素格式

  RGB的有效数据位

  - 888
  - 565

#### 像素时钟

查询 5.0寸液晶屏数据手册

- 经典值：33.3MHz
- 最大值：50MHz

查芯片手册时钟树：

![1595561340251](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1595561340251.png)

查PLL5对外输出时钟：

![1595561255010](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1595561255010.png)

#### 相关寄存器

34.6 eLCDIF Memory Map/Register Definition 

- PLL_VIDEO：设置小数分频器

- MISC2：分频和使能PLL5对外输出时钟
- CSCDR2：LCD时钟源选择和分频

- LCDIF_CTRL:复位、数据宽度

- LCDIF_CTRL1：设置ARGO模式，A通道不用传输

- LCDIF_TRANSFER_COUNT：lcd的行分辨率和列分辨率

- LCDIF_VDCTRL0：设置帧同步信号属性
- LCDIF_VDCTRL1：设置VSYNC总周期
- LCDIF_VDCTRL2：HSYNC总周期、行信号的脉冲宽度

- LCDIF_VDCTRL3 ：行信号开始缓冲时间、帧信号开始缓冲时间
- LCDIF_VDCTRL4 ：使能同步信号
- CUR_BUF：当前帧显存地址
- NEXT_BUF：下一帧显存地址

