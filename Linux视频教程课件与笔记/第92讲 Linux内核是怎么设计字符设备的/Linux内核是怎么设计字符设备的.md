## Linux内核是怎么设计字符设备的

#### Linux哲学

一切皆文件

#### 如何把字符设备抽象成文件

##### 复习文件描述符本质

open()函数,在文件系统中找到指定文件的操作接口，绑定到进程task_srtuct->files_struct->fd_array[]->file_operations

![image-20200731170952814](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200731170952814.png)

##### 思路

把底层寄存器配置操作放在文件操作接口里面，新建一个文件绑定该文件操作接口，应用程序通过操作指定文件来设置底层寄存器

#### 硬件层原理

##### 基本接口实现

- 查原理图，数据手册，确定底层需要配置的寄存器
  
- 类似裸机开发
  
- 实现一个文件的底层操作接口，这是文件的基本特征

  ```
  struct file_operations 
  ```

  ebf-buster-linux/include/linux/fs.h

  ![1596178828118](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\1596178828118.png)

  - 几乎所有成员都是函数指针，用来实现文件的具体操作

#### 驱动层原理

把file_operations文件操作接口注册到内核，内核通过主次设备号来登记记录它

- 构造驱动基本对象：struct cdev，里面记录具体的file_operations

  ```
  cdev_init()
  ```

- 两个hash表
  - chrdevs：登记设备号
  
    ```
    __register_chrdev_region()
    ```
  
  - cdev_map->probe：保存驱动基本对象struct cdev
  
    ```
    cdev_add()
    ```

#### 文件系统层原理

mknod指令+主从设备号

- 构建一个新的设备文件
- 通过主次设备号在cdev_map中找到cdev->file_operations

- 把cdev->file_operations绑定到新的设备文件中

到这里，应用程序就可以使用open()、write()、read()等函数来控制设备文件了