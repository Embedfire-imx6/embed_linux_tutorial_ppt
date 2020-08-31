#ifndef _COMMON_H_
#define _COMMON_H_

#include  "MCIMX6Y2.h"
#include  "fsl_iomuxc.h"


#define red_led_on   GPIO1->DR &= ~(1<<4)
#define red_led_off  GPIO1->DR |= (1<<4)

void rgb_led_init(void);
void button_init(void);
int get_button_status(void);
void irq_init();
void delay(uint32_t count);
void system_register_irqhandler() ;


#endif