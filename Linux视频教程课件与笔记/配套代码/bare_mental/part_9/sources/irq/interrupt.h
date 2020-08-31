#ifndef _INTERRUPT_H_
#define _INTERRUPT_H_

#include  "common.h" 
                   
/*定义函数指针*/
typedef void (*system_irq_handler_t) (unsigned int giccIar, void *param);

/* 中断函数结构体*/
typedef struct _sys_irq_handle
{
    system_irq_handler_t irqHandler; /* 中断服务函数 */
    void *userParam;                 /* 中断服务函数参数 */
} sys_irq_handle_t;

void system_register_irqhandler(IRQn_Type irq, system_irq_handler_t handler, void *userParam) ;
void irq_init();

#endif
