### ARM常用汇编指令

汇编格式：

```
label：instruction @ comment
```

- label：标号 
- instruction：具体汇编指令
- comment：注释内容

常用段名：

- .text：代码段

- .data：初始化的数据段

- .bss：未初始化的数据段

- .rodata：只读数据段

- .section：自定义段

  ```
  .section .vector
  ```

常见伪操作：

- .global：定义全局标号

  ```
  .global _start
  ```

- .align：字节对齐

  ```
  .align 2
  ```

  

寄存器间数据传输:

- mov：寄存器数据(或者是立即数)拷贝到另一个寄存器

  ```
  mov r0，r1
  mov r0, #0x12
  ```

- mrs：读程序状态寄存器

  ```
  mrs r0,cpsr
  ```

- msr：写程序状态寄存器

  ```
  msr cpsr,r0
  ```

- mrc：读cp15协处理器

- mcr：写cp15寄存器



内存与寄存器数据传输:

- ldr：把内存数据(或者是立即数)加载到寄存器

  ```
  ldr r0, =0x80000000
  ldr r1, [r0]
  ```

- str：把寄存器数据写入到内存

  ```
  ldr r0, =0x80000000
  str r1,[r0]
  ```



压栈和出栈

- push：把寄存器列表存入栈中

  ```
  push {r0~r3, r12}
  ```

- pop：从栈中恢复寄存器列表

  ```
  pop  {r0~r3, r12}
  ```



跳转

- b：跳转到目标地址

  ```
  b main
  ```

- bl：跳转到目标地址，并把当前pc指针值保存在lr寄存器中

  ```
  bl main
  ```



算术运算指令

- add：加法运算

  ```
  add r1,r2,r3
  add r1,r2
  ```

- sub：减法运算

  ```
  sub r1,r2,r3
  ```

- mul：乘法运算

  ```
  mul r1,r2,r3
  ```

- udiv：除法运算

  ```
  udiv r1,r2,r3
  ```



逻辑运算

- and：与

  ```
  and r1,r2,r3
  and r1,r2
  ```

- orr：或

  ```
  orr r1,r2,r3
  ```

- bic：位清除

  ```
  bic r1,r2,r3
  ```
