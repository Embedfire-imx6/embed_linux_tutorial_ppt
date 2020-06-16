# ARM-GCC与交叉编译

#### 三个问题:

#### ARM-GCC是什么?它与GCC有什么关系?

编译工具链和目标程序运行相同的架构平台，就叫本地编译

编译工具链和目标程序运行在不同的架构平台，叫做交叉编译

ARM-GCC是针对arm平台的一款编译器，它是GCC编译工具链的一个分支

#### ARM-GCC进一步分类有哪些?

第二项:linux none

第三项:gnu：glibc   eabi：应用二进制标准接口 	hf：支持硬浮点平台

#### 如何安装ARM-GCC？

apt install gcc

#### ubuntu安装arm-gcc

apt install gcc-arm-linux-gnueabihf

#### Linaro公司



#### 两个案例:

在ARM架构上运行x86_64架构的程序

在ARM架构上运行交叉编译的程序