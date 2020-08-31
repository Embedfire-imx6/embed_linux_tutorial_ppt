#ifndef __BUTTON_H
#define __BUTTON_H

#include  "common.h"

void button_init(void);
int get_button_status(void);
void GPIO5_1_IRQHandler(void);
extern uint8_t button_status;
#endif