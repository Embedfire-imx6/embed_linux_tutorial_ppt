# include  "led.h"

  /*led初始化函数*/
void rgb_led_init(void)
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

}
