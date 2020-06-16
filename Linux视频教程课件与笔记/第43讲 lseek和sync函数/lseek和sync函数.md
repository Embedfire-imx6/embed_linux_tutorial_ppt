## lseek和sync函数

#### lseek函数

##### 功能

设置文件读写位置

##### 头文件

```
#include <unistd.h>
```

##### 函数原型

```
off_t lseek(int fd,off_t offset,int whence)
```

- 若whence为SEEK_SET，基准点为文件开头
- 若whence为SEEK_CUR，基准点为当前位置
- 若whence为SEEK_END，基准点为文件末尾

##### 返回值

成功：文件偏移位置值

失败：-1



#### sync函数

##### 页缓存和回写

##### 功能

强制把修改过的页缓存区数据写入磁盘

##### 头文件

```
#include <unistd.h>
```

##### 函数原型

```
void sync(void);
```

##### 返回值

无