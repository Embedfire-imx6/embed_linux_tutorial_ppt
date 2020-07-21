## system-V 消息队列

#### system-V ipc特点

- 独立于进程
- 没有文件名和文件描述符
- IPC对象具有key和ID

#### 消息队列用法

- 定义一个唯一key(ftok)
- 构造消息对象(msgget)
- 发送特定类型消息(msgsnd)
- 接受特定类型消息(msgrcv)
- 删除消息队列(msgctl)

#### ftok函数

功能：获取一个key

函数原型：

```
key_t ftok(const char *path,int proj_id)
```

参数：

- path：一个合法路径
- proj_id：一个整数

返回值：

成功：合法键值

失败：-1



#### msgget函数

功能：获取消息队列ID

函数原型：

```
int msgget(key_t key,int msgflg)
```

参数：

- key：消息队列的键值
- msgflg：
  - IPC_CREAT：如果消息队列不存在，则创建
  - mode：访问权限

返回值：

成功：该消息队列的ID

失败：-1



#### msgsnd函数

功能：发送消息到消息队列

函数原型：

```
int msgsnd(int msqid,const void *msgp,size_t msgsz,int msgflg);
```

参数：

- msqid：消息队列ID

- msgp：消息缓存区

  - struct msgbuf

    {

    ​	long mtype;	 //消息标识

    ​	char mtext[1]; //消息内容

    }

- msgsz：消息正文的字节数

- msgflg：

  - IPC_NOWAIT：非阻塞发送
  - 0：阻塞发送

返回值：

成功：0

失败：-1



#### msgrcv函数

功能：从消息队列读取消息

函数原型：

```
ssize_t msgrcv(int msqid,void *msgp,size_t msgsz,long msgtyp,int msgflg)
```

参数：

- msqid：消息队列ID

- msgp：消息缓存区

- msgsz：消息正文的字节数

- msgtyp：要接受消息的标识

- msgflg：

  - IPC_NOWAIT：非阻塞读取
  - MSG_NOERROR：截断消息

  - 0：阻塞读取

返回值：

成功：0

失败：-1



#### msgctl函数

功能：设置或获取消息队列的相关属性

函数原型：

```
int msgctl(int msgqid,int cmd,struct maqid_ds *buf)
```

- msgqid：消息队列的ID
- cmd
  - IPC_STAT：获取消息队列的属性信息
  - IPC_SET：设置消息队列的属性
  - IPC_RMID：删除消息队列

- buf：相关结构体缓冲区