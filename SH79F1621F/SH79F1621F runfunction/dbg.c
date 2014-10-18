#include "dbg.h"


#ifdef _DEBUG

void TraceString(const char* cstring){
	while(*cstring)
		TraceChar(*cstring++);
}

void TraceChar(char chardata)
{
   while(((*BOARD_UART_STA_ADDR)&0x200)==0);   
  _UART_WRITE(chardata);
}


void TraceHex(unsigned char hexdata)
{
	char tmp;
	tmp=hexdata>>4;
	tmp&=0x0f;
	if(tmp>9)
		tmp=tmp+55;
	else
		tmp=tmp+0x30;
	while(((*BOARD_UART_STA_ADDR)&0x200)==0);
	_UART_WRITE(tmp);
	//while((*BOARD_UART_STA_ADDR)&0x200==0);
	
	tmp=hexdata&0xf;
	
    TraceChar(tmp + (( tmp < 0x0A)?('0'):('A' - 0xA)));
  //while((*BOARD_UART_STA_ADDR)&0x200==0);
}


void TraceHex32(unsigned int hexdata)
{
	char c;
	for(int i=0;i<8;i++)
	{
		c = ((hexdata >> (32 - 4 - i*4))&0xF);
		TraceChar(c + (( c < 0x0A)?('0'):('A' - 0xA)));
	}
}

#endif
