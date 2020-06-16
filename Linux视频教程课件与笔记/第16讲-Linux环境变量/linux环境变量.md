# 第十六讲 linux环境变量

##### linux为什么需要环境变量?

##### 全局变量VS环境变量

直接定义

export

##### Shell 配置文件

与 Bash Shell 有关的配置文件主要有

1. **/etc/profile**
2. <u>*~/.bash_profile*</u>
3. <u>*~/.bash_login*</u>
4. <u>*~/.profile*</u>
5. **~/.bashrc**
6. <u>*/etc/bashrc*</u>
7. *<u>/etc/bash.bashrc</u>*
8. **/etc/profile.d/*.sh**

##### Shell 执行顺序

/etc/profiles->~/.profile(~/.bash_profile、~/.bash_login)

##### 修改配置文件

全部用户、全部进程共享:/etc/bash.bashrc

一个用户、全部进程共享:~/.bashrc

##### shell启动方式对变量的影响

子shell进程中执行:/bin/bash和./

当前进程中执行:source和.