.global _start

_start:

@ 设置栈地址为64M,0X80000000~0XA0000000(512MB)
    ldr sp, =0x84000000

@ 跳转main函数
    b main 
    