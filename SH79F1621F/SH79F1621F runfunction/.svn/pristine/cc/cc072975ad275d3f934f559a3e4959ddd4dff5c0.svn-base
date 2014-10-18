#include "vector_ram.h"
#include <string.h>
#include "dbg.h"

#if defined   ( __CC_ARM   )
    #define WEAK __attribute__ ((weak))
#elif defined ( __ICCARM__ )
    #define WEAK __weak
#elif defined (  __GNUC__  )
    #define WEAK __attribute__ ((weak))
#endif

__no_init unsigned short s_uiOperate[8];
__no_init unsigned short s_gpio_dir;

extern const VECTOR_FUNC vector_func[];
extern unsigned int get_last_success(const void* info,unsigned int sram[VSRAM_SIZE]);

WEAK void check_ready(VECTOR* vector,unsigned int sram[VSRAM_SIZE]){
	read_sram(0,sram,VSRAM_SIZE);
	//if(sram[VOFS_RESPONSE] & (1UL<<31))
	if(sram[VOFS_RESPONSE] & VRES_BIT_READY){
		if(sram[VOFS_RESPONSE] & VRES_BIT_ERROR)
			vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
		else {
			vector->ucFlag |= VEC_F_READY;
			if(vector_func[vector->usOperation].chk_rdy){
				if(vector_func[vector->usOperation].chk_rdy(vector,sram)==FALSE)
					vector->ucFlag |= (VEC_F_FAIL);
			}
			else if(vector->usOperation == VCMD_VERIFY){
				vector->uiImageChecksum = sram[VOFS_CHECKSUM];
			}
		}
	}
	else if(VRES_GET_OPERATION(sram)==vector->usOperation){
		;
	}
//	else
//		vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
	vector->uiLastSuccess = get_last_success(vector->cvpIcInformation,sram);
}

WEAK void ic_ramfunction(VECTOR* vector){
	unsigned int sram[VSRAM_SIZE] = {0};
	if(vector->ucFlag & VEC_F_TRIGGED){
		vector->usOperation = GetOperate();
		check_ready(vector,sram);
	}
	else if((vector->usOperation < 16) && vector_func[vector->usOperation].process){
		SetOperate(vector->usOperation);
		vector_func[vector->usOperation].process(vector,sram);
		vector->ucFlag &=~VEC_F_READY;
		if((vector->ucFlag & VEC_F_TRIGGED)==0){
			write_sram(0,sram,sizeof(sram)/sizeof(sram[0]));
			vector->ucFlag |= VEC_F_TRIGGED;
		}
	}
	else{
		vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
	}
}