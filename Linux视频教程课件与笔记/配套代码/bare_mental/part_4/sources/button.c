# include  "common.h"

/*按键初始化函数*/
void button_init(void)
{
    /*按键初始化*/
    CCM->CCGR1 = 0xffffffff;

    /*设置 绿灯 引脚的复用功能以及PAD属性*/
    IOMUXC_SetPinMux(IOMUXC_SNVS_SNVS_TAMPER1_GPIO5_IO01,0);     
    IOMUXC_SetPinConfig(IOMUXC_SNVS_SNVS_TAMPER1_GPIO5_IO01, 0x10B0); 
    
    /*设置GPIO5_01为输入模式*/
    GPIO5->GDIR &= ~(1<<1);  
}

/*按键状态输出函数*/
int get_button_status(void)
{
    if((GPIO5->DR)&(1<<1))
    {
        delay(0xFF);
         if((GPIO5->DR)&(1<<1))
         {
             return 1;
         }
    }
    return 0;
}
