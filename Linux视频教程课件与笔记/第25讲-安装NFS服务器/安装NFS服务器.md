# 安装NFS服务器

## NFS服务器是什么？

网络文件系统，类unix系统中使用

##  搭建NFS环境

#### Ubuntu安装NFS 服务端

```
sudo apt install nfs-kernel-server -y
```

#### 配置NFS 服务端

(1)、打开/etc/exports文件

```
sudo vim /etc/exports
```

(2)、创建共享文件夹

```
sudo mkdir -p /home/embedfire/workdir
```

(3)、添加配置信息

```
/home/embedfire/workdir *(rw,sync,no_root_squash)
```

- /home/embedfire/workdir：指定分享文件名。
- *:所有网段都可以读写
- rw:读写权限
- sync：资料同步写入到内存与硬盘中
- no_root_squash:root用户具有挂载目录的全部操作操作权限

(4)、更新exports配置

```
sudo exportfs -arv
```

(5)、查看NFS共享情况

```
showmount -e
```

#### 开发板安装NFS客户端

```
sudo apt install nfs-common -y
```

#### 查看NFS服务器共享目录

```
showmount -e +”NFS服务端IP”
```

#### 挂载NFS文件系统

```
sudo mount -t nfs ”NFS服务端IP”:/home/embedfire/workdir /mnt
```

- -t nfs：指定挂载的文件系统格式为nfs
- /home/embedfire/workdir：指定NFS服务器的共享目录
- /mnt：本地挂载目录