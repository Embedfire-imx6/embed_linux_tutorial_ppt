## 彻底掌握POLL机制：动手设计一个POLL实验

#### 实验设计

- App应用程序调用poll函数检测*/dev/rgb_led*设备文件的可写事件

  - 无可写事件，进程一直休眠(poll)
  - 有可写事件，写入字符'0'，点亮rgb红灯

- file_operations->poll：

  - 监视write_data全局变量值
    - 值为0，无事件发生
    - 值为1，返回可写事件

  - 指定唤醒App进程的等待队列头
    - poll_wait

- file_operations->write：判断write_data全局变量值
  - 值为0，点亮rgb红灯
  - 值为1，唤醒poll函数引起休眠的App进程

#### 实验操作

1. 后台执行App应用程序，往设备文件写入字符'0'

   ```
   ./App 0& 
   ```

   设备文件没有可写事件产生，poll函数使当前App进程休眠

2. 借助‘echo’应用程序，往设备文件写入字符'1'

   ```
   sudo sh -c "echo '1'>/dev/rgb_led"
   ```

   唤醒之前休眠的App应用程序

#### 实验现象

- 设备文件产生可写事件
- App应用程序写入字符'0'
- rgb红灯被点亮

