# include  "common.h"
#include  "led.h"
#include  "button.h"
#include  "interrupt.h"
#include "clock.h"

uint8_t button_status=0;
char g_charA = 'A'; //存储在 .data段
char g_charB = 'A'; //存储在 .data段
int main()
{
    /*系统时钟初始化*/
    system_clock_init();
   /*GIC中断和中断向量表初始化*/
    irq_init();
     /*初始化led灯和按键*/
    rgb_led_init();

    while (1)
    {
        red_led_off;
        delay(0x3FFFF);
        
        red_led_on;
        delay(0x3FFFF);
    }
    return 0;    
}