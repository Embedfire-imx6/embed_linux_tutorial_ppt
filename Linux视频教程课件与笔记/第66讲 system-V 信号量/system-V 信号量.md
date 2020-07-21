## system-V 信号量

#### 本质

计数器

#### 作用

保护共享资源

- 互斥
- 同步

#### 信号量用法

- 定义一个唯一key（ftok）
- 构造一个信号量(semget)
- 初始化信号量(semctl SETVA)
- 对信号量进行P/V操作(semop)
- 删除信号量(semctl RMID)



#### semget函数

功能：获取信号量的ID

函数原型：

```
int semget(key_t key,int nsems,int semflg)
```

参数：

- key：信号量键值
- nsems：信号量数量
-  semflg：
  - IPC_CREATE：信号量不存在则创建
  - mode：信号量的权限

返回值：

成功：信号量ID

失败：-1



#### semctl函数

功能：获取或设置信号量的相关属性

函数原型：

```
int semctl(int semid,int semnum,int cmd,union semun arg)
```

参数：

- semid：信号量ID

- semnum：信号量编号

- cmd：
  - IPC_STAT：获取信号量的属性信息
  - IPC_SET：设置信号量的属性
  - IPC_RMID：删除信号量
  - IPC_SETVAL：设置信号量的值

- arg：

  union semun
  {
  int val;
  struct semid_ds *buf;
  }

返回值：

成功：由cmd类型决定

失败：-1



#### semop函数

函数原型：

```
int semop(int semid,struct sembuf *sops,size_t nsops)
```

参数：

- semid：信号量ID

- sops：信号量操作结构体数组

  struct sembuf

  {

  ​	short sem_num;	//信号量编号

  ​	short sem_op；//信号量P/V操作

  ​	short sem_flg;	//信号量行为，SEM_UNDO

  }
  
  - nsops：信号量数量

返回值：

成功：0

失败：-1