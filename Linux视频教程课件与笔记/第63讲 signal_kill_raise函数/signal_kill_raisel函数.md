## signal_kill_raise函数

#### signal函数

头文件:

```
include<signal.h>
```

函数原型:

```
typedef void (*sighandler_t)(int);

sighandler_t signal(int signum,sighandler_t handler);
```

参数:

- signum： 要设置的信号
- handler：
  - SIG_IGN：忽略
  - SIG_DFL：默认
  - void (*sighandler_t)(int)：自定义

返回值：

成功：上一次设置的handler

失败：SIG_ERR



#### kill函数

头文件:

```
#include <sys/types.h>
#include <signal.h>
```

原型函数:

```
int kill(pid_t pid,int sig);
```

参数:

- pid：进程id
- sig：要发送的信号

返回值:

成功：0

失败：-1



#### raise函数

头文件:

```
#include <signal>
```

原型函数:

```
int raise(int sig);
```

参数:

sig：发送信号

返回值：

成功：0

失败：非0

