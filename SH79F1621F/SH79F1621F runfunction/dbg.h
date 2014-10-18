#ifndef _DBG_H
#define _DBG_H


#define _DEBUG


#define BOARD_UART_TX_ADDR  (volatile unsigned int *)(0x400e061c)
#define BOARD_UART_STA_ADDR  (volatile unsigned int *)(0x400e0614)
#define _UART_WRITE(a)	(*BOARD_UART_TX_ADDR = (a))
#define CR()  TraceString("\r\n")

void TraceString(const char* cstring);
void TraceChar(char chardata);
void TraceHex(unsigned char hexdata);
void TraceHex32(unsigned int intdata);

#else

#define TraceString(a)
#define TraceChar(a)
#define TraceHex(a)
#define TraceHex32(a)



#endif