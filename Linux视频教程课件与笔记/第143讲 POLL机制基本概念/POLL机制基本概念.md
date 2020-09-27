## POLL机制基本概念

- poll()函数
- file_operations->poll

#### 应用层poll()函数

异步阻塞型IO

- 同步阻塞：阻塞在一个文件的读写操作上(read\write)，自己设备驱动唤醒自己

- 异步阻塞：阻塞在多个文件的轮询操作上(poll)，可被多个设备驱动唤醒

文件I/O事件 

- 可读、可写、异常...

##### poll函数

\#include <poll.h>

监视多个文件描述符的指定事件，事件发生时(驱动唤醒)，把发生的具体事件通知给用户程序

```
int poll(struct pollfd *fds,nfds_t nfds,int timeout)
```

参数：

- fds ：一个struct pollfd类型的数组

  ```
  struct pollfd {
  int fd; /* 文件描述符 */
  short events; /* 请求的事件类型 */
  short revents; /* 返回的事件类型 */
  };
  ```

  - fd：要监视的文件描述符

  - events 是要监视的事件

    - POLLIN：系统内核通知应用层指定数据已经备好，读数据不会被阻塞
    - POLLPRI ：有紧急的数据需要读取
    - POLLOUT ：系统内核通知应用层IO缓冲区已准备好，写数据不会被阻塞

    - POLLERR ：指定的文件描述符发生错误
    - POLLNVAL：无效的请求
    - ...

  - revents是返回事件，内核设置具体的返回事件

- nfds：pollfd数组的元素个数，要监控的文件描述符数量
- timeout：超时时间(ms)

返回值：

- 成功：发生事件的文件数量，超时返回0
- 失败：-1

