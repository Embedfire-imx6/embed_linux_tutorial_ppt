# include  "common.h"
#include  "led.h"
#include  "button.h"
#include  "interrupt.h"

uint8_t button_status=0;
char g_charA = 'A'; //存储在 .data段
char g_charB = 'A'; //存储在 .data段
int main()
{
   /*GIC中断和中断向量表初始化*/
    irq_init();
     /*初始化led灯和按键*/
    rgb_led_init();
    /*按键中断初始化*/
    button_init();

    while (1){
        if(button_status > 0){
            /*红灯灭*/
            red_led_off;
        }
        else {
            /*红灯亮*/
            red_led_on;
        }
    }
    return 0;    
}