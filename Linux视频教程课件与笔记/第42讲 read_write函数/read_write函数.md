## lseek函数

#### lseek函数

##### 头文件

```
#include <unistd.h>
```

##### 函数原型

```
ssize_t read(int fd,void *buff,size_t count)
```

##### 返回值

成功：

- count：成功读取全部字节
- 0~count:
  - 剩余文件长度小于count
  - 读取期间被异步信号打断

失败：

- -1，读取错误

#### write函数

##### 头文件

同read函数

##### 函数原型

```
ssize_t write(int fd,void *buff,size_t count)
```

##### 返回值

成功：

- count：成功写入全部字节
- 0~count:
  - 写入期间被异步信号打断

失败：

- -1，读取错误

### 复制普通文件小实验

1、打开要复制的文件

2、创建新的文件

3、把源文件内容读到缓冲区，把缓冲区内容写入新文件

4、循坏执行第三步，直到读取的字节数量为0，退出循坏。

5、关闭打开的文件