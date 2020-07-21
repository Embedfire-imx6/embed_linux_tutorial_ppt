#include  "button.h"
#include "interrupt.h"

/*按键初始化函数*/
void button_init(void)
{
    /**********************************第一部分***********************************/
    /*时钟初始化*/
    CCM->CCGR1 = 0xffffffff;

    /*设置 key引脚的复用功能以及PAD属性*/
    IOMUXC_SetPinMux(IOMUXC_SNVS_SNVS_TAMPER1_GPIO5_IO01,0);     
    IOMUXC_SetPinConfig(IOMUXC_SNVS_SNVS_TAMPER1_GPIO5_IO01, 0x10B0); 
    
    /*设置GPIO5_01为输入模式*/
    GPIO5->GDIR &= ~(1<<1);  


    /**********************************第二部分**************************************/
    /*使能GPIO5_1中断*/
    GPIO5->IMR |= (1<<1);

    /*禁止GPIO5_1中断双边沿触发*/
     GPIO5->EDGE_SEL  =  0;

     /*设置GPIO5_1上升沿触发*/
     GPIO5->ICR1 |= (2<<2);

    /*添加中断服务函数到  "中断向量表"*/
     system_register_irqhandler(GPIO5_Combined_0_15_IRQn, (system_irq_handler_t)GPIO5_1_IRQHandler, NULL);

     /*开启GIC中断相应中断*/
     GIC_EnableIRQ(GPIO5_Combined_0_15_IRQn);

}

void GPIO5_1_IRQHandler(void)
{
    /*按键引脚中断服务函数*/
    if((GPIO5->DR)&(1<<1)){
         if(button_status > 0){
            button_status = 0;
        }
        else{
            button_status = 1;
        }
    }
    /*清除Gpio5_1中断标志位*/
    GPIO5->ISR |= (1 << 1);  
   
}
