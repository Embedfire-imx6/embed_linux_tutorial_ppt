#ifndef _UART_H_
#define _UART_H_

#include  "common.h" 

void uart_init(void);
int32_t UART_SetBaudRate(UART_Type *base, uint32_t baudRate_Bps, uint32_t srcClock_Hz);

void UART_WriteBlocking(UART_Type *base, const uint8_t *data, uint8_t length);
void UART_ReadBlocking(UART_Type *base, uint8_t *data, uint8_t length);

#endif