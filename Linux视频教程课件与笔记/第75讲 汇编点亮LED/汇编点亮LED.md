## 汇编点亮LED

#### vscode调整

- 终端字体

```
terminal>intergrated:font family

monospace
```

- 加入汇编插件

```
ARM
```

- vscode权限受限

```
修改文件权限
```



#### 编程步骤

- 使能GPIO时钟

- 设置引脚复用为GPIO
- 设置引脚属性(上下拉、速率、驱动能力)
- 控制GPIO引脚输出高低电平



#### 程序编译

1. 下载裸机的gcc编译器

```
sudo apt-get install gcc-arm-none-eabi
```

2. 编译汇编文件为可重定位文件led.o

```
arm-none-eabi-gcc -c led.s -o led.o
```

3. 把重定位文件链接起来，得到可执行程序(elf文件)

```
arm-none-eabi-ld -Ttext 0x80000000 led.o -o led.elf
```

4. 把elf文件去掉冗余的段和elf头，得到纯净的bin文件

```
arm-none-eabi-objcopy -O binary led.elf led.bin
```

5. 给bin文件添加6ull特殊的头部信息(IVT+boot data+DCD),并烧录到sd卡

```
./mkimage.sh XXX.bin
```





