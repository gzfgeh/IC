#include "vector_ram.h"

__no_init unsigned short m_slot;

int main(){
//	*((unsigned int*)(0x20100004)) = (unsigned int)main;
	m_slot = VECTOR_PLACEMENT()->ucSlot;
	ic_ramfunction(VECTOR_PLACEMENT());
	return 0;
}

void exit(){
	asm("pop {pc}");
}

