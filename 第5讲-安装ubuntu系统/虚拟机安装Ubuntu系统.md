# 虚拟机安装Ubuntu系统

Linux开发环境搭建:

- 只安装Linux

- 安装双系统
- Win10安装Linux子系统
- 虚拟机
  - VMWare
  - VirtualBox
- 服务器+客户端

安装虚拟机（https://www.virtualbox.org）

安装Ubuntu（https://ubuntu.com）

设置网络、共享文件夹

手动挂载:

> sudo mount -t vboxsf  共享目录 挂载目录

自动挂载:打开/etc/fstab，添加

> "共享目录" "挂载目录" vboxsf auto,rw,comment=systemd.automount 0 0

