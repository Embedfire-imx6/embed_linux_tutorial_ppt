## 通用中断控制器（GIC）

GIC用于管理单核或多核芯片中的中断资源

- ARM公司开发了4 个版本GIC规范 ，V1~V4
- ARMv7-A内核搭配GIC-400使用

#### GIC结构

GIC官方手册：ARM® Generic Interrupt Controller  

![image-20200715114359298](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200715114359298.png)

- V2最多支持 8 个内核

- 三类信号源：

  - 软件中断：用于多核通信，ID0~ID15
  - 私有中断：内核独有的中断，ID16~ID31
  - 共享中断：所有内核共享的中断，ID32~ID1019

- 分发器：选择把中断信号发送到哪一个cpu接口单元

  ​	**有哪些相关寄存器？**

  - 中断数量：GICD_TYPER

  - 中断清除： GICD_ ICENABLERn
  - 中断使能：GICD_ISACTIVERn
  - 中断优先级设置：GICD_IPRIORITYR

- cpu接口单元：处理信号后，发送信号给CPU

  ​	**有哪些相关寄存器？**

  - 中断优先级数量：GICC_PMR
  - 抢占优先级和子优先级设置： GICC_BPR
  - 保存中断ID：GICC_IAR 
  - 通知cpu中断完成：GICC_EOIR

#### 获取GIC基地址 

##### 方法一：查询芯片数据手册

![image-20200717165437437](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200717165437437.png)

##### 方法二：查询cp15协处理器

共有16个：c0~c15。**每个协处理器本身有多种含义，需逐步配置**

```
//设置并读协处理器
MRC {cond} p15, <opc1>, <Rn>, <CRn>, <CRm>, <opc2>
//设置并写协处理器
MCR {cond} p15, <opc1>, <Rn>, <CRn>, <CRm>, <opc2> 
```

- cond：执行条件，一般省略
- opc1：第一层设置
- Rn：通用寄存器
- CRn：要设置的协处理器
- CRm：第二层设置
- opc2：第三层设置

![image-20200718133127723](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200718133127723.png)

B3.17 Oranization of the CP15 registers in a VMSA implementation

#####  CBAR寄存器

CRn=c15，opc1=4，CRm=c0，opc2=0

- GIC的地址

```
MRC p15, 4, r1, c15, c0, 0 ;获取 GIC 基地址
```



##### SCTLR 寄存器

 CRn=c1，opc1=0，CRm=c0，opc2=0

![image-20200717163614514](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200717163614514.png)

- bit13：中断向量表基地址

- cache\mmu\分支预测...

  ```
  MRC p15, 0, <Rt>, c1, c0, 0 ;读取 SCTLR 寄存器，数据保存到 Rt 中。
  MCR p15, 0, <Rt>, c1, c0, 0 ;将 Rt 中的数据写到 SCTLR(c1)寄存器中。
  ```

  

##### VBAR寄存器

 CRn=c12，opc1=0，CRm=c0，opc2=0

![image-20200717164309866](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200717164309866.png)

- bit5~31：中断向量表偏移地址

```
MRC p15, 0, <Rt>, c12, c0, 0 ;读取 VBAR 寄存器，数据保存到 Rt 中。
MCR p15, 0, <Rt>, c12, c0, 0 ;将 Rt 中的数据写到 VBAR寄存器中。
```

