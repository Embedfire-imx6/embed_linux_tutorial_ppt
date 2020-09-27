## SPI物理总线

#### 信号线

- SCK：时钟线，数据收发同步
- MOSI：数据线，主设备数据发送、从设备数据接收
- MISO：数据线，从设备数据发送，主设备数据接收

- NSS、CS：片选信号线

支持一主多从，全双工通信，最大速率可达上百MHz

![image-20200912081954858](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200912081954858.png)

#### spi时序

![image-20200912083029061](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200912083029061.png)

- 起始信号：NSS 信号线由高变低
- 停止信号：NSS 信号由低变高
- 数据传输：在 SCK的每个时钟周期 MOSI和 MISO同时传输一位数据，高/低位传输没有硬性规定
  - 传输单位： 8 位或 16 位
  - 单位数量：不受限制

#### spi通信模式

总线空闲时 SCK 的时钟状态以及数据采样时刻

- 时钟极性 CPOL：指 SPI 通讯设备处于空闲状态时，SCK信号线的电平信号
  - CPOL=0时， SCK在空闲状态时为低电平
  - CPOL=1时， SCK在空闲状态时为高电平

- 时钟相位 CPHA：数据的采样的时刻
  - 当 CPHA=0 时，数据在 SCK 时钟线的“奇数边沿”被采样
  - 当 CPHA=1时，数据在 SCK 时钟线的“偶数边沿”被采样

##### 案例

![image-20200912084313769](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200912084313769.png)

- SCK信号线在空闲状态为低电平时，CPOL=0；空闲状态为高电平时，CPOL=1
-  CPHA=0，数据在 SCK 时钟线的“奇数边沿”被采样
- 当 CPOL=0 的时候，时钟的奇数边沿是上升沿
- 当CPOL=1 的时候，时钟的奇数边沿是下降沿

##### 四大模式

![image-20200912084116532](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200912084116532.png)

##### 常见spi设备

- EEPROM

- FLASH

- 实时时钟

- AD转换器

  ...

#### 