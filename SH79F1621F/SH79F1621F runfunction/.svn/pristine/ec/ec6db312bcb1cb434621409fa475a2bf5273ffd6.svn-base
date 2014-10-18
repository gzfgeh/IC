#include "vector_ram.h"
#include "string.h"
#include "dbg.h"

#define VOFS_SPI_JEDEC_ID	5

typedef enum _e_skt_error{
	seNoError = (unsigned char)0,
	seNoSocket = (unsigned char)1,
	seOutOfSktCounter = (unsigned char)2,
	seOutOfUserCounter = (unsigned char)3,
	seInvalid = (unsigned char)4,
	seIcNotInSocket = (unsigned char)5,
	seContactTestFail = (unsigned char)6,
	seInitializeFail = (unsigned char)7,
	seIdCheckError = (unsigned char)8,
	seEraseFail = (unsigned char)9,
	seBlankCheckFail = (unsigned char)10,
	seProgramFail = (unsigned char)11,
	seVerifyFail = (unsigned char)12,
	seCrcFail = (unsigned char)13,
	seNreOperateFail = (unsigned char)14,
	seUnlockFail = (unsigned char)15,
	seLockFail = (unsigned char)16,
	seInitializeTimeout = (unsigned char)17,
	seEraseTimeout = (unsigned char)18,
	seBlankCheckTimeout = (unsigned char)19,
	seProgramTimeout = (unsigned char)20,
	seVerifyTimeout = (unsigned char)21,
	seNreOperateTimeout = (unsigned char)22,
	seUnlockTimeout = (unsigned char)23,
	seLockTimeout = (unsigned char)24,
	seStartSignalIgnore = (unsigned char)25,
	seTerminaled = (unsigned char)26,
	seOvercurrent = (unsigned char)27,
	seTooManyBadBlock = (unsigned char)28,
}SKT_ERROR;

typedef struct _st_icinfo{
	unsigned int uiPageSize;
	unsigned int uiSectorSize;
	unsigned int uiChipSize;
	unsigned int uiJedecId;
	unsigned short usIdLength;
	unsigned short ausPinMask[4];
	unsigned short usPinLength;
	unsigned int uiMaxVoltage;
	unsigned int uiMinVoltage;
	
	unsigned short usReadIdCommand;
	unsigned short usChipEraseCommand;
	unsigned short usSectorEraseCommand;
	unsigned short usProgramCommand;
	unsigned short usReadCommand;
	unsigned short usReadStatusCommand;
	unsigned short usUnlockCommand;
	unsigned short usLockCommand;
	unsigned short usRfu;
}IC_INFO,*PIC_INFO;

static BOOL CHK_RDY_DECLARE(chkrdy_readid)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	if((vector->debugging[0] == seInitializeFail)||(vector->debugging[0] == seIdCheckError)){
		memset(vector->vpParameter,0xFF,info->usIdLength);
		return FALSE;
	}
	else{
		memcpy(vector->vpParameter,&info->uiJedecId,info->usIdLength);
		return TRUE;
	}
}

const VECTOR_FUNC vector_func[16] = {
	{NULL,NULL},		//VCMD_RESET_VECTOR		0{this will be called before power off, pass or error occured}
	{NULL,NULL},		//VCMD_RESET_BUS		1
	{NULL,chkrdy_readid},//VCMD_INIT_CHIP		2
	{NULL,chkrdy_readid},//VCMD_READ_ID			3
	{NULL,NULL},			//VCMD_UNLOCK			4
	{NULL,NULL},			//VCMD_ERASE			5
	{NULL,NULL},			//VCMD_BLANK_CHECK		6
	{NULL,NULL},			//VCMD_PROGRAM			7
	{NULL,NULL},			//VCMD_VERIFY			8
	{NULL,NULL},			//VCMD_READ				9
	{NULL,NULL},			//VCMD_LOCK				10
	{NULL,NULL},				//VCMD_NRE			11
	{NULL,NULL},					//VCMD_NULL			12
	{NULL,NULL},					//VCMD_NULL			13
	{NULL,NULL},					//VCMD_NULL			14
	{NULL,NULL},					//VCMD_NULL			15
};


__no_init unsigned short s_uiOperate[8];
__no_init unsigned short s_gpio_dir;

static void check_ready(VECTOR* vector,unsigned int sram[VSRAM_SIZE]){
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	switch(GetOperate()){
	case VCMD_READ_ID:
		if((vector->debugging[0] == seInitializeFail)||(vector->debugging[0] == seIdCheckError)){
			memset(vector->vpParameter,0xFF,info->usIdLength);
			vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
		}
		else if((vector->debugging[0] != seInitializeTimeout)&&(vector->debug_ticks >= info->usReadIdCommand/2)){
			memcpy(vector->vpParameter,&info->uiJedecId,info->usIdLength);
			vector->ucFlag |= (VEC_F_READY);
		}
		break;
	case VCMD_ERASE:
		if((vector->debugging[0] == seEraseFail)&&(vector->debug_ticks >= vector->debugging[1])){
			vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
		}
		else if((vector->debugging[0] != seEraseTimeout)&&(vector->debug_ticks >= info->usChipEraseCommand/2)){
			vector->ucFlag |= (VEC_F_READY);
		}
		break;
	case VCMD_BLANK_CHECK:
		if((vector->debugging[0] == seBlankCheckFail)&&(vector->debug_ticks >= vector->debugging[1])){
			vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
		}
		else if((vector->debugging[0] != seBlankCheckTimeout)&&(vector->debug_ticks >= info->usReadCommand/2)){
			vector->ucFlag |= (VEC_F_READY);
		}
		else
			vector->uiLastSuccess = vector->uiImageLength/info->uiPageSize*vector->debug_ticks/info->usReadCommand;
		break;
	case VCMD_PROGRAM:
		if((vector->debugging[0] == seProgramFail)&&(vector->debug_ticks >= vector->debugging[1])){
			vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
		}
		else if((vector->debugging[0] != seProgramTimeout)&&(vector->debug_ticks >= info->usProgramCommand/2)){
			vector->ucFlag |= (VEC_F_READY);
		}
		else
			vector->uiLastSuccess = vector->uiImageLength/info->uiPageSize*vector->debug_ticks/info->usProgramCommand;
		break;
	case VCMD_VERIFY:
		if((vector->debugging[0] == seVerifyFail)&&(vector->debug_ticks >= vector->debugging[1])){
			vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
		}
		else if((vector->debugging[0] != seVerifyTimeout)&&(vector->debug_ticks >= info->usReadCommand/2)){
			vector->ucFlag |= (VEC_F_READY);
			if(vector->debugging[0] == seCrcFail)
				vector->uiImageChecksum = ~vector->uiImageChecksum;
		}
		else
			vector->uiLastSuccess = vector->uiImageLength/info->uiPageSize*vector->debug_ticks/info->usReadCommand;
		break;
	}
}

void ic_ramfunction(VECTOR* vector){
	unsigned int sram[VSRAM_SIZE] = {0};
	if(vector->ucFlag & VEC_F_TRIGGED){
		vector->usOperation = GetOperate();
		check_ready(vector,sram);
	}
	else if(vector->usOperation < 16){
		SetOperate(vector->usOperation);
		vector->ucFlag |= VEC_F_TRIGGED;
		vector->ucFlag &=~VEC_F_READY;
	}
	else{
		vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
	}
}