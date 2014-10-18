#include "vector_ram.h"
#include "string.h"
#include "dbg.h"

static BOOL try_unprotect(VECTOR* vector,unsigned int sram[VSRAM_SIZE]);

typedef struct _st_icinfo{
	unsigned int auiJedecId;
	unsigned int rfuId;
	unsigned int uiIdLength;
	unsigned int uiPageSizeInByte;
	unsigned int uiSectorSizeInByte;
	unsigned int uiBlockSizeInByte;
	unsigned int uiChipSizeInPage;
	
	unsigned int uiReadIdParameter;
	unsigned int uiEraseParameter;
	unsigned int uiProgramParameter;
	unsigned int uiReadParameter;
	unsigned int uiUnlockParameter;
	unsigned int uiLockParameter;
}IC_INFO,*PIC_INFO;

unsigned int get_last_success(const void* cvpIcInformation,unsigned int sram[VSRAM_SIZE]){
	const IC_INFO* info = (const IC_INFO*)cvpIcInformation;
	return sram[VOFS_LAST_SUCCESS]/info->uiPageSizeInByte;
}

static void PROCESS_DECLARE(command_vec_reset)
{
	//will be call before power off.
	//you should reset all IO to high impedence.
	//Add your resect code here.
	vector_reset();
}

static void PROCESS_DECLARE(command_bus_reset)
{
	//will be call after power on.
	//Add your resect code here.
	vector_run();
}

static void PROCESS_DECLARE(command_lock)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	sram[VOFS_COMMAND] = VCMD_LOCK;
	sram[VOFS_OP_CODE_METHOD] = info->uiLockParameter;
	sram[VOFS_START_ADDRESS] = 0;
	sram[VOFS_LENGTH] = info->uiChipSizeInPage*info->uiPageSizeInByte;
	sram[VOFS_ID] = info->auiJedecId;
}

static void PROCESS_DECLARE(command_unlock)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	sram[VOFS_COMMAND] = VCMD_UNLOCK;
	if((info->auiJedecId&0xFFFFFF) == 0x190201)		//S25FL256S
		sram[VOFS_OP_CODE_METHOD] = 0x01;
	else if((info->auiJedecId&0xFFFFFF) == 0x182001)	//S25FL128S
		sram[VOFS_OP_CODE_METHOD] = 0x01;
	else if((info->auiJedecId&0xFF) == 0xBF)			//SST25VFxxx
		sram[VOFS_OP_CODE_METHOD] = 0x02;
	else if((info->auiJedecId&0xE0FF) == 0x401F)		//AT25DFxxx
		sram[VOFS_OP_CODE_METHOD] = 0x04;
	else											//normal 25
		sram[VOFS_OP_CODE_METHOD] = 0;
	sram[VOFS_OP_CODE_METHOD] |= (info->uiReadParameter&0x100);
	sram[VOFS_START_ADDRESS] = vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage;
	sram[VOFS_SECTOR_NUMBER] = vector->uiImageLength/info->uiSectorSizeInByte;
	sram[VOFS_SECTOR_SIZE] = info->uiSectorSizeInByte;
	sram[VOFS_ID] = info->auiJedecId;
}

static void PROCESS_DECLARE(command_initchip)
{
	//sram[VOFS_COMMAND] = VCMD_INIT_CHIP;
	//sram[VOFS_OP_CODE_METHOD] = ((const IC_INFO*)vector->cvpIcInformation)->usReadIdParameter;
}

static void PROCESS_DECLARE(command_readid)
{
	sram[VOFS_COMMAND] = VCMD_READ_ID;
	sram[VOFS_OP_CODE_METHOD] = ((const IC_INFO*)vector->cvpIcInformation)->uiReadIdParameter;
	TraceChar('I');
}

static void PROCESS_DECLARE(command_erase)
{
	if(try_unprotect((VECTOR*)vector,sram)==FALSE)
		return;
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	sram[VOFS_COMMAND] = vector->usOperation;
	sram[VOFS_OP_CODE_METHOD] = info->uiEraseParameter;
	sram[VOFS_START_ADDRESS] = vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage;
	sram[VOFS_SECTOR_NUMBER] = vector->uiImageLength/info->uiSectorSizeInByte;
	sram[VOFS_SECTOR_SIZE] = info->uiSectorSizeInByte;
	sram[VOFS_ID] = info->auiJedecId;
}

static void PROCESS_DECLARE(command_read)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	write_register(0x3030,(vector->ucFlag & VEC_F_FIFO)?1:0);
	sram[VOFS_COMMAND] = vector->usOperation;
	sram[VOFS_OP_CODE_METHOD] = info->uiReadParameter;
	sram[VOFS_START_ADDRESS] = vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage;
	sram[VOFS_LENGTH] = vector->uiImageLength;
	sram[VOFS_ID] = info->auiJedecId;
	
	TraceString("\r\nR");
	TraceInt(sram[VOFS_COMMAND]);
	TraceChar(',');
	TraceInt(sram[VOFS_START_ADDRESS]);
	TraceChar(',');
	TraceInt(sram[VOFS_LENGTH]);
	TraceChar(',');
	TraceInt(sram[VOFS_ID]);
}

static void PROCESS_DECLARE(command_program)
{
	if(try_unprotect((VECTOR*)vector,sram)==FALSE)
		return;
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	//write_register(0x3030,(vector->uiSdRamLength)?0:1);
	write_register(0x3030,(vector->ucFlag & VEC_F_FIFO)?1:0);
	sram[VOFS_COMMAND] = VCMD_PROGRAM;
	sram[VOFS_OP_CODE_METHOD] = info->uiProgramParameter;
	sram[VOFS_START_ADDRESS] = vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage;
	sram[VOFS_LENGTH] = vector->uiImageLength;
	sram[VOFS_PAGE_SIZE] = info->uiPageSizeInByte;
	sram[VOFS_OP_CODE_METHOD] = info->uiProgramParameter;
	sram[VOFS_ID] = info->auiJedecId;
}

static void PROCESS_DECLARE(command_nre)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	write_sram(16,vector->vpParameter,vector->uiParameter/sizeof(unsigned int));
	sram[VOFS_COMMAND] = vector->usOperation;
	sram[VOFS_OP_CODE_METHOD] = info->uiProgramParameter;
	sram[VOFS_START_ADDRESS] = vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage;
	sram[VOFS_LENGTH] = vector->uiImageLength;
	sram[VOFS_PAGE_SIZE] = info->uiPageSizeInByte;
	sram[VOFS_ID] = info->auiJedecId;
}

static BOOL CHK_RDY_DECLARE(chkrdy_readid)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	read_sram(16,sram,(min(vector->uiParameter,info->uiIdLength)+3)/sizeof(unsigned int));
	memcpy(vector->vpParameter,sram,vector->uiParameter);
	TraceInt(*sram);
	if(memcmp(vector->vpParameter,&info->auiJedecId,info->uiIdLength)){
		return FALSE;
	}
	return TRUE;
}

static BOOL CHK_RDY_DECLARE(chkrdy_verify)
{
	vector->uiImageChecksum = sram[VOFS_CHECKSUM];
	return TRUE;
}

const VECTOR_FUNC vector_func[16] = {
	{command_vec_reset, NULL},		//VCMD_RESET_VECTOR		0{this will be called before power off, pass or error occured}
	{command_bus_reset,NULL},		//VCMD_RESET_BUS		1
	{command_initchip, NULL},		//VCMD_INIT_CHIP		2
	{command_readid, chkrdy_readid},//VCMD_READ_ID			3
	{command_unlock,NULL},			//VCMD_UNLOCK			4
	{command_erase,NULL},			//VCMD_ERASE			5
	{command_read,NULL},			//VCMD_BLANK_CHECK		6
	{command_program,NULL},			//VCMD_PROGRAM			7
	{command_read,chkrdy_verify},	//VCMD_VERIFY			8
	{command_read,NULL},			//VCMD_READ				9
	{command_lock,NULL},			//VCMD_LOCK				10
	{command_nre,NULL},				//VCMD_NRE			11
	{NULL,NULL},					//VCMD_NULL			12
	{NULL,NULL},					//VCMD_NULL			13
	{NULL,NULL},					//VCMD_NULL			14
	{NULL,NULL},					//VCMD_NULL			15
};

static BOOL try_unprotect(VECTOR* vector,unsigned int sram[VSRAM_SIZE])
{
	unsigned int i,status;
	command_unlock(vector,sram);
	write_sram(0,sram,16);
	for(i=0;i<100000;i++){
		read_sram(VOFS_RESPONSE,&status,1);
		if(status & 0x8000){
			if(status & 0x4000){
				//vector_reset();
				vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
				TraceHex(sram[14]);
				return FALSE;
			}
			return TRUE;
		}
	}
	TraceChar('*');
	vector_reset();
	vector->ucFlag |= (VEC_F_READY|VEC_F_FAIL);
	return FALSE;
}
