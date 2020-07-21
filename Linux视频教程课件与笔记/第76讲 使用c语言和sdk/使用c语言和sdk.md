## 使用c语言和sdk

#### 引入sdk头文件

目的：解决寄存器地址难查难设置

- devices/MCIMX6Y2/MCIMX6Y2.h

  记录外设寄存器及其相关操作

- devices/MCIMX6Y2/drivers/fsl_iomuxc.h

  记录引脚复用及其相关操作

**注意**：

MCIMX6Y2.h注释以下头文件包含

```
#include "core_ca7.h"  
#include "system_MCIMX6Y2.h"   
```

增加以下宏定义：

```
#define __O  volatile
#define __IO  volatile 
#define __I  volatile const 

#define uint32_t unsigned int
#define uint16_t unsigned short
#define uint8_t unsigned char
```



#### 使用C语言

目的：提高开发效率

#### bin文件组成介绍

段是程序的基本组成元素：

- .text段：代码文本
- .rodata段：只读变量，如const修饰的变量
- .data段：非零的全局变量、静态变量
- .bss：值为 0 的全局变量、静态变量
- .comment：存放注释
- ...

#### 准备C语言环境

- bss段清零
- 栈指针(sp)



#### 裸机程序控制外设

特点：读数据手册、设寄存器值

- 找出外设有哪些相关寄存器
- 找出外设相关寄存器如何设置



#### 链接脚本引入

目的：指定链接地址、起始代码在text段的位置，其他段的位置

官方资料：http://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_mono/ld.html

 ```
SECTIONS{

	. =xxx //链接起始地址
    .段名
    {
        xxx
        *(.段名)
    }
	...
}
 ```

#### Makefile修改

- 兼容.s汇编文件
- 添加编译程序命令
- 添加sd卡烧录命令

