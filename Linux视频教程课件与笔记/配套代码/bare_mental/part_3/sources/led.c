#include  "MCIMX6Y2.h"
#include  "fsl_iomuxc.h"

/*简单延时函数*/
void delay(uint32_t count)
{
    volatile uint32_t i = 0;
    for (i = 0; i < count; ++i)
    {
        __asm("NOP"); /* 调用nop空指令 */
    }
}

int main(void)
{
    /*使能GPIO1时钟*/
      CCM->CCGR1 = 0xffffffff;

     /*设置 红灯 引脚的复用功能以及PAD属性*/
    IOMUXC_SetPinMux(IOMUXC_GPIO1_IO04_GPIO1_IO04,0);     
    IOMUXC_SetPinConfig(IOMUXC_GPIO1_IO04_GPIO1_IO04, 0X10B0); 

    /*设置GPIO1_04为输出模式*/
    GPIO1->GDIR |= (1<<4);  

    /*设置GPIO1_04输出电平为高电平*/
    GPIO1->DR |= (1<<4);  

    while(1)
    {
         GPIO1->DR &= ~(1<<4); //红灯亮
         delay(0xFFFFF);
         GPIO1->DR |= (1<<4); //红灯灭
          delay(0xFFFFF);
    }

    return 0;

}