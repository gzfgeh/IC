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
  if(tmp>9)
    tmp=tmp+55;
  else
    tmp=tmp+0x30;
   while(((*BOARD_UART_STA_ADDR)&0x200)==0);
  _UART_WRITE(tmp); 
  //while((*BOARD_UART_STA_ADDR)&0x200==0);

}

void TraceInt(unsigned int intdata)
{
  unsigned char tmp,i;
  
  for(i=8;i>0;i--)
  {
    tmp=(char)(intdata>>(4*(i-1)));
    tmp&=0x0f;

    if(tmp>9)
      tmp=tmp+55;
    else
      tmp=tmp+0x30;
    while(((*BOARD_UART_STA_ADDR)&0x200)==0);
    _UART_WRITE(tmp);
  }
}

#endif
