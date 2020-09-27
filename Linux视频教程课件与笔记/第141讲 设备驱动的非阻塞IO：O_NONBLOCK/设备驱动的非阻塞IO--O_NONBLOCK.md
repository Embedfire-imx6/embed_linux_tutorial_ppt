## 设备驱动的非阻塞IO：O_NONBLOCK

#### IO操作

- 数据读取/发送

#### 两个阶段

- 用户空间<=>内核空间
- 内核空间<=>file_operation

#### 阻塞操作

请求的资源没有准备好，进程/线程睡眠等待，直到数据准备完毕

![image-20200904164240430](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200904164240430.png)

#### 非阻塞操作

请求的资源没有准备好，直接返回错误信息

![image-20200904164346909](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20200904164346909.png)

#### O_NONBLOCK

open函数的非阻塞标志