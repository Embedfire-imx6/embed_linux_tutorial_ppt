.global _start

_start:

    ldr     pc, =Reset_Handler           /* Reset                  */
    ldr     pc, =Undefined_Handler       /* Undefined instructions */
    ldr     pc, =SVC_Handler             /* Supervisor Call        */
    ldr     pc, =PrefAbort_Handler       /* Prefetch abort         */
    ldr     pc, =DataAbort_Handler       /* Data abort             */
    .word   0                            /* RESERVED               */
    ldr     pc, =IRQ_Handler             /* IRQ interrupt          */
    ldr     pc, =FIQ_Handler             /* FIQ interrupt          */

Reset_Handler:
    @ 禁止 IRQ 中断
    cpsid   i 

    @ 定义IRQ模式的栈地址
    cps     #0x12                
    ldr     sp, =0x9FF00000

#if 0
    mrs r0, cpsr
    bic r0, r0, #0x1f @将 r0 的低 5 位清零，也就是 cpsr 的 M0~M4 
    orr r0, r0, #0x12 @r0 或上 0x12,表示使用 IRQ 模式 
    msr cpsr, r0 @将 r0 的数据写入到 cpsr 中 
    ldr sp, =0x80600000 @IRQ 模式栈首地址为 0X80600000,大小为 2MB 
#endif


	@ 设置栈地址为64M,0X80000000~0XA0000000(512MB)
	cps     #0x13
    ldr sp, =0x84000000

	@ 打开全局中断 
	cpsie i				

	@重定位data段 
	bl copy_data

	@清除bss段 
	bl clean_bss

	@ 跳转main函数
    b main 

IRQ_Handler:

	push {r0-r12, lr}		  @保存r0-r2，lr寄存器 
	mrs r0, spsr				 @读取spsr寄存器 
	push {r0}						@保存spsr寄存器 

	mrc p15, 4, r1, c15, c0, 0   @从CP15的C0寄存器内的值到R1寄存器中						
	add r1, r1, #0X2000				@ GIC基地址加0X2000，也就是GIC的CPU接口端基地址
	ldr r0, [r1, #0XC]				 	@ GIC的CPU接口端基地址加0X0C就是GICC_IAR寄存器，GICC_IAR寄存器保存这当前发生中断的中断号
	push {r0, r1}				 			@保存r0,r1 
	
	bl SystemIrqHandler			@ 运行C语言中断处理函数，带有一个参数，保存在R0寄存器中 

	pop {r0, r1}				
	str r0, [r1, #0X10]					@ 中断执行完成，通知cpu

	pop {r0}						
	msr spsr_cxsf, r0				  @ 恢复spsr

	pop {r0-r12, lr} 			@恢复r0-r2，lr寄存器 
	subs pc, lr, #4				 @将lr-4赋给pc 

 FIQ_Handler:
	ldr r0, =FIQ_Handler	
	bx r0	
 
 Undefined_Handler:
	ldr r0, =Undefined_Handler
	bx r0

SVC_Handler:
	ldr r0, =SVC_Handler
	bx r0

PrefAbort_Handler:
	ldr r0, =PrefAbort_Handler	
	bx r0

DataAbort_Handler:
	ldr r0, =DataAbort_Handler
	bx r0

NotUsed_Handler:
	ldr r0, =NotUsed_Handler
	bx r0

copy_data:
	ldr r1, =data_load_addr  @ data段的加载地址
	ldr r2, =data_start  @data段重定位地址
	ldr r3, =data_end  @data段结束地址

	loop:
	ldrb r4, [r1] @从r1读到r4 
	strb r4, [r2] @r4存放到r2 
	add r1, r1, #1@复制下1个字节
	add r2, r2, #1 
	cmp r2, r3 @ r2 、r3比较 
	bne loop  @ 如果没拷贝完则重复拷贝 

	mov pc, lr

clean_bss:
	ldr r1, =__bss_start  @将链接脚本变量__bss_start变量保存于r1
    ldr r2, =__bss_end  @将链接脚本变量__bss_end变量保存于r2
	mov r3, #0

clean:
	strb r3, [r1]  @将当前地址下的数据清零
	add r1, r1, #1  @将r1内存储的地址+4
	cmp r1, r2  @相等：清零操作结束；否则继续执行clean函数清零bss段
	bne clean

	mov pc, lr