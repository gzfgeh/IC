#ifndef _DBG_H
#define _DBG_H

#ifdef _DEBUG

#define BOARD_UART_TX_ADDR  (volatile unsigned int *)(0x400e061c)
#define BOARD_UART_STA_ADDR  (volatile unsigned int *)(0x400e0614)
#define _UART_WRITE(a)	(*BOARD_UART_TX_ADDR = (a))

void TraceString(const char* cstring);
void TraceChar(char chardata);
void TraceHex(unsigned char hexdata);
void TraceInt(unsigned int intdata);

#else

#define TraceString(a)
#define TraceChar(a)
#define TraceHex(a)
#define TraceInt(a)

#endif

#endif