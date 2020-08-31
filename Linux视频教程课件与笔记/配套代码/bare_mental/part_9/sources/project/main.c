# include  "common.h"
#include  "led.h"
#include  "button.h"
#include  "interrupt.h"
#include "clock.h"
#include "uart.h"
#include  "lcd.h"

uint8_t button_status=0;
char g_charA = 'A'; //存储在 .data段
char g_charB = 'A'; //存储在 .data段

/*提示字符串*/
uint8_t txbuff[] = "Uart polling example\r\nBoard will send back received characters\r\n";

int main()
{

    //用于暂存串口收到的字符
    uint8_t ch; 
    /*lcd显存编号*/
    uint32_t frameBufferIndex = 0;
    /*系统时钟初始化*/
    system_clock_init();
   /*GIC中断和中断向量表初始化*/
    irq_init();
     /*初始化led灯和按键*/
    rgb_led_init();
    /*串口初始化*/
    uart_init();
    /*发送提示字符串*/
    UART_WriteBlocking(UART1, txbuff, sizeof(txbuff) - 1);
    /*初始 lcdif 引脚*/
    lcdif_pin_config(); 
     /*初始化时钟*/        
    lcdif_clock_init();        
    /*初始化 lcd属性和中断*/
    lcd_property_Init();  
    
    red_led_on;
    while (1)
    {
        frameBufferIndex ^= 1U;
        APP_FillFrameBuffer(s_frameBuffer[frameBufferIndex]);

        LCDIF->NEXT_BUF = (uint32_t)s_frameBuffer[frameBufferIndex];
        
        /* Wait for previous frame complete. */
        while (!s_frameDone);
        s_frameDone = false;

        delay(0xFFFF);
    }

    return 0;    
}