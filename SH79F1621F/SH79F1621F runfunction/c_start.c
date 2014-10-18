#include "exceptions.h"
//------------------------------------------------------------------------------
//         Types
//------------------------------------------------------------------------------
typedef union { IntFunc __fun; void * __ptr; } IntVector;

//------------------------------------------------------------------------------
//         ProtoTypes
//------------------------------------------------------------------------------

extern void __iar_program_start( void );

#pragma language=extended
#pragma segment="CSTACK"

#pragma section = ".intvec"
#pragma location = ".intvec"
const IntVector __vector_table[]= 
{
    { .__ptr = __sfe( "CSTACK" ) },
    __iar_program_start,
	
    NMI_Handler,
    HardFault_Handler,
    MemManage_Handler,
    BusFault_Handler,
    UsageFault_Handler,
    0, 0, 0, 0,             // Reserved
    SVC_Handler,
    DebugMon_Handler,
    0,                      // Reserved
	PendSV_Handler,
    SysTick_Handler,
};

