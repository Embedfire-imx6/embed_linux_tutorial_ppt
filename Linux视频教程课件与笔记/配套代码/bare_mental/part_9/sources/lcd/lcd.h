#ifndef _LCD_H_
#define _LCD_H

# include  "common.h"

/*定义 显示屏信息 */
#define APP_IMG_HEIGHT 480    
#define APP_IMG_WIDTH 800
#define APP_HSW 40
#define APP_HFP 210
#define APP_HBP 46
#define APP_VSW 20
#define APP_VFP 22
#define APP_VBP 23

#define false 0
#define true 1
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

void lcdif_pin_config(void);
void CLOCK_InitVideoPll(void);

void lcdif_clock_init(void);
void lcd_property_Init(void);
void APP_FillFrameBuffer(uint32_t frameBuffer[APP_IMG_HEIGHT][APP_IMG_WIDTH]);
void APP_LCDIF_IRQHandler(void);
extern uint32_t s_frameBuffer[2][APP_IMG_HEIGHT][APP_IMG_WIDTH];  
extern uint8_t s_frameDone;
#endif
