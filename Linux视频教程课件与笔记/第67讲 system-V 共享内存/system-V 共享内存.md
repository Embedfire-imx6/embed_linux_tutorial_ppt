## system-V 共享内存 

#### 作用

高效率传输大量数据

#### 共享内存用法

- 定义一个唯一key（ftok）
- 构造一个共享内存对象(shmget)
- 共享内存映射(shmat)
- 解除共享内存映射(shmdt)
- 删除共享内存(shmctl RMID)



#### shmget函数

功能：获取共享内存对象的ID

函数原型：

```
int shmget(key_t key,int size,int shmflg)
```

参数：

- key：共享对象键值
- nsems：共享内存大小
-  shmflg：
  - IPC_CREATE：共享内存不存在则创建
  - mode：共享内存的权限

返回值：

成功：共享内存ID

失败：-1



#### shmat函数

功能：映射共享内存

函数原型：

```
int shmat(int shmid,const void *shmaddr,int shmflg)
```

参数：

- shmid：共享内存ID
- shmaddr：映射地址，NULL为自动分配
- shmflg：
  - SHM_RDONLY：只读方式映射
  - 0：可读可写

返回值：

成功：共享内存首地址

失败：-1



#### shmdt函数

功能：解除共享内存映射

函数原型：

```
int shmdt(const void *shmaddr)
```

参数：

shmaddr：映射地址

返回值：

成功：0

失败：-1



#### shmctl函数

功能：获取或设置共享内存的相关属性

函数原型：

```
int shmctl(int shmid,int cmd,struct shmid_ds *buf)
```

参数：

- shmid：共享内存ID

- cmd：
  - IPC_STAT：获取共享内存的属性信息
  - IPC_SET：设置共享内存的属性
  - IPC_RMID：删除共享内存
  
- buf：属性缓冲区


返回值：

成功：由cmd类型决定

失败：-1



