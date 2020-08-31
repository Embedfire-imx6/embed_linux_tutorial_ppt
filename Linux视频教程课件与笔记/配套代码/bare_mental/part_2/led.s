.global _start

_start:

@ 使能GPIO时钟
ldr r0,=0x20c406c
ldr r1,=0xffffffff
str r1,[r0]

@ 设置引脚复用为GPIO
ldr r0,=0x20e006c
ldr  r1,=5
str r1,[r0]


@ 设置引脚属性(上下拉、速率、驱动能力)
ldr r0,=0x20e02f8
ldr  r1,=0x10b0
str r1,[r0]

@ 控制GPIO引脚输出高低电平
ldr r0,=0x0209c004
ldr  r1,=16
str r1,[r0]

ldr r0,=0x0209c000
ldr  r1,=0
str r1,[r0]
