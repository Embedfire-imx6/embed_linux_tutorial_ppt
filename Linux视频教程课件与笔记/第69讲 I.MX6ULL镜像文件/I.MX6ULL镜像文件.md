##  I.MX6ULL镜像文件

##### boot ROM程序

选择内部启动方式，启动boot ROM程序

- 初始化时钟、外部DDR3
- 从外部存储介质加载代码

#### 五要素

- 空偏移
  
- 芯片厂商设定
  
- Image vector table，简称IVT

  - 关键数据位置

- Boot data，启动数据

  - 镜像加载地址、大小

- Device configuration data，简称DCD

  - 关键外设的寄存器配置信息（时钟、DDR3相关）

- bin文件

  - 真正程序文件

    

```
8.7.1 Image Vector Table and Boot Data
```

![image-20200704091452248](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200704091452248.png)

##### 空偏移

镜像不是从介质头部开始存储的，不同介质分别对应一段偏移地址

```
8.7.1 Image Vector Table and Boot Data
```

![image-20200704092110555](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200704092110555.png)

- Boot Device Type：不同启动介质

- Image Vector Table Offset ：镜像有效数据偏移位置

- Initial Load Region Size：boot rom程序读取程序大小



##### IVT表

记录关键数据的位置

```
8.7.1.1 Image vector table structure
```

![image-20200704093152444](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200704093152444.png)

- header：IVT的长度、大小

- entry：程序运行地址

- dcd：内存中DCD数据地址

- boot data：内存中boot data地址

- self：内存中IVT自己所在地址



##### Boot data

记录"镜像"在内存中的加载地址和大小

```
8.7.1.2 Boot data structure
```

![image-20200704094321719](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200704094321719.png)

- start：镜像在内存中的加载地址，包括空偏移
- length：镜像长度，包括空偏移



##### DCD表

外设寄存器配置信息,初始化关键外设

```
8.7.2 Device Configuration Data (DCD)
```

![image-20200704100124427](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200704100124427.png)

- Header：记录DCD大小、版本

- CMD：寄存器初始化列表

```
Table 8-28. Write data command format
```

![image-20200704100650049](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200704100650049.png)

![image-20200704100705185](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200704100705185.png)

- Tag：DCD命令，一般为写寄存器

- Length：表示命令的大小

- Parameter：设置写寄存器方式(写值/清位/设置位）

- Address：寄存器地址，主要是时钟、DDR3相关外设地址

- Value：具体设置值

