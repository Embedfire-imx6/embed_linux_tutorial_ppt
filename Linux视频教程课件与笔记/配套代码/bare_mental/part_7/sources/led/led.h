#ifndef _LED_H_
#define _LED_H

# include  "common.h"

#define red_led_on   GPIO1->DR &= ~(1<<4)
#define red_led_off  GPIO1->DR |= (1<<4)

void rgb_led_init(void);

#endif
