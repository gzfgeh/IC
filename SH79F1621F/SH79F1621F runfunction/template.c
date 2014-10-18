#include "vector_ram.h"
#include "string.h"
#include "dbg.h"


#define GetArrayLength(Arr)  (sizeof(Arr)/sizeof(Arr[0])) 

typedef struct _st_icinfo{
	unsigned char aucId[8];
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
	unsigned int uiBusWidth;
}IC_INFO,*PIC_INFO;

unsigned int get_last_success(const void* cvpIcInformation,unsigned int sram[VSRAM_SIZE]){
	const IC_INFO* info = (const IC_INFO*)cvpIcInformation;
	return sram[VOFS_LAST_SUCCESS]/info->uiPageSizeInByte;
}

static void PROCESS_DECLARE(command_vec_reset)
{
	//will be called before power off.
	//you should reset all IO to high impedence.
	//Add your resect code here.
     // TraceString("vector_reset\r\n");
#if 1
         unsigned int val = VCMD_RESET_VECTOR;
         write_sram(VOFS_COMMAND,&val,1);
         for(int i = 0;i<10000;i++){
           read_sram(8,&val,1);
           if(val & 0x8000){
             vector_reset();
             return;
           }
         }
#else
         vector_reset(); // stop to be Hi-z
         //If need a high-level before power on, there must be a pull-up resistor on socket adaptor.
         //If need a low-level before power on, comment "vector_rest()" and then send a command to vector to control all GPIO pins to low.
#endif         
         
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
	sram[VOFS_LENGTH] = info->uiChipSizeInPage*info->uiPageSizeInByte/(info->uiBusWidth>>3);
	sram[VOFS_ID] = *(unsigned int*)info->aucId;
}

static void PROCESS_DECLARE(command_unlock)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	sram[VOFS_COMMAND] = VCMD_UNLOCK;
	sram[VOFS_OP_CODE_METHOD] = info->uiUnlockParameter;
	sram[VOFS_START_ADDRESS] = 0;
	sram[VOFS_LENGTH] = info->uiChipSizeInPage*info->uiPageSizeInByte/(info->uiBusWidth>>3);
	sram[VOFS_ID] = *(unsigned int*)info->aucId;
}

static void PROCESS_DECLARE(command_initchip)
{
	sram[VOFS_COMMAND] = VCMD_INIT_CHIP;
        
        
	//sram[VOFS_OP_CODE_METHOD] = ((const IC_INFO*)vector->cvpIcInformation)->usReadIdParameter;
       // const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	//sram[VOFS_COMMAND] = VCMD_READ_ID;
	//sram[VOFS_OP_CODE_METHOD] = info->uiReadIdParameter;
}

static void PROCESS_DECLARE(command_readid)
{
        TraceString("Read ID\r\n");
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	sram[VOFS_COMMAND] = VCMD_READ_ID;
	sram[VOFS_OP_CODE_METHOD] = info->uiReadIdParameter;
}

static void PROCESS_DECLARE(command_erase)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
        
        if (vector->usOperateArea == 0)   //main flash 
        {
          sram[VOFS_COMMAND] = VCMD_ERASE;
          sram[VOFS_OP_CODE_METHOD] = info->uiEraseParameter;
          sram[VOFS_START_ADDRESS] = (vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage)/(info->uiBusWidth>>3);
          sram[VOFS_SECTOR_NUMBER] = vector->uiImageLength/info->uiSectorSizeInByte;
          sram[VOFS_SECTOR_SIZE] = info->uiSectorSizeInByte/(info->uiBusWidth>>3);
          sram[VOFS_ID] = *(unsigned int*)info->aucId;
        }
	else
          sram[VOFS_COMMAND] = 0xc;
        
}

static void PROCESS_DECLARE(command_read)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	write_register(0x3030,(vector->ucFlag & VEC_F_FIFO)?1:0);
        
        if (vector->usOperateArea == 0)   //main flash 
        {
          sram[VOFS_COMMAND] = vector->usOperation;
          sram[VOFS_OP_CODE_METHOD] = info->uiReadParameter;
          sram[VOFS_START_ADDRESS] = (vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage)/(info->uiBusWidth>>3);
          sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
          sram[VOFS_ID] = *(unsigned int*)info->aucId;
        }
        else if (vector->usOperateArea == 2)                            //option byte
        {
          sram[VOFS_COMMAND] = 0xf;      //read option
          sram[VOFS_LENGTH] = 0x8;
          //write_sram(0x3, (unsigned int const*)(unsigned char *)vector->vpParameter, 1);
        }
        else
        {
          sram[VOFS_COMMAND] = 0xa;
          sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
        }
}

static void PROCESS_DECLARE(command_blankcheck)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	write_register(0x3030,(vector->ucFlag & VEC_F_FIFO)?1:0);
        
        if (vector->usOperateArea == 0)   //main flash 
        {
          sram[VOFS_COMMAND] = vector->usOperation;
          sram[VOFS_OP_CODE_METHOD] = info->uiReadParameter;
          sram[VOFS_START_ADDRESS] = (vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage)/(info->uiBusWidth>>3);
          sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
          sram[VOFS_ID] = *(unsigned int*)info->aucId;
        }
        else if (vector->usOperateArea == 2)                            //option byte
        {
          //sram[VOFS_COMMAND] = 0xf;      //read option
          //sram[VOFS_LENGTH] = 0x6;
          //write_sram(0x3, (unsigned int const*)(unsigned char *)vector->vpParameter, 1);
        }
        else
        {
          sram[VOFS_COMMAND] = 0x6;
          sram[1] = 1;
          sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
        }
}

static void PROCESS_DECLARE(command_verify)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	write_register(0x3030,(vector->ucFlag & VEC_F_FIFO)?1:0);
        
        if (vector->usOperateArea == 0)   //main flash 
        {
          sram[VOFS_COMMAND] = vector->usOperation;
          sram[VOFS_OP_CODE_METHOD] = info->uiReadParameter;
          sram[VOFS_START_ADDRESS] = (vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage)/(info->uiBusWidth>>3);
          sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
          sram[VOFS_ID] = *(unsigned int*)info->aucId;
        }
        else if(vector->usOperateArea == 2)    //option byte
        {
          sram[VOFS_COMMAND] = 0x4;      //read option
          sram[VOFS_LENGTH] = 0x4;
          
          const unsigned int data_array[8] = {
               ((unsigned char *)vector->vpParameter)[0],
               ((unsigned char *)vector->vpParameter)[1],
               ((unsigned char *)vector->vpParameter)[2],
               ((unsigned char *)vector->vpParameter)[3],
	       ((unsigned char *)vector->vpParameter)[4],
               ((unsigned char *)vector->vpParameter)[5],
               ((unsigned char *)vector->vpParameter)[6],
               ((unsigned char *)vector->vpParameter)[7]
              };
          
	  TraceHex32(data_array[0]);
          TraceString("\r\n");
          TraceHex32(data_array[1]);
          TraceString("\r\n");
          TraceHex32(data_array[2]);
          TraceString("\r\n");
          TraceHex32(data_array[3]);
          TraceString("\r\n");
	  TraceHex32(data_array[4]);
          TraceString("\r\n");
          TraceHex32(data_array[5]);
          TraceString("\r\n");
          TraceHex32(data_array[6]);
          TraceString("\r\n");
          TraceHex32(data_array[7]);
          TraceString("\r\n");
	  
          write_sram(0x30,data_array,GetArrayLength(data_array));
          //read_sram(0x30,(unsigned int *)data_array,GetArrayLength(data_array));
        }
        else
        {
          sram[VOFS_COMMAND] = 0x8;      //read option
          sram[1] = 1;
          sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
        }
}

static void PROCESS_DECLARE(command_program)
{
        const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	//write_register(0x3030,(vector->uiSdRamLength)?0:1);
        
	write_register(0x3030,(vector->ucFlag & VEC_F_FIFO)?1:0);          //0:sdram 1:fifo

        if (vector->usOperateArea == 0) //main flash
        {
            sram[VOFS_COMMAND] = VCMD_PROGRAM;
            sram[VOFS_OP_CODE_METHOD] = info->uiProgramParameter;
            sram[VOFS_START_ADDRESS] = (vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage)/(info->uiBusWidth>>3);
            sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
            sram[VOFS_PAGE_SIZE] = info->uiPageSizeInByte/(info->uiBusWidth>>3);
            sram[VOFS_OP_CODE_METHOD] = info->uiProgramParameter;
            sram[VOFS_ID] = *(unsigned int*)info->aucId;
        }
        else if (vector->usOperateArea == 2)   //vector->usOperateArea == 1 option flash
        {
          sram[VOFS_COMMAND] = 0xe;      //program option
          const unsigned int data_array[8] = {
               ((unsigned char *)vector->vpParameter)[0],
               ((unsigned char *)vector->vpParameter)[1],
               ((unsigned char *)vector->vpParameter)[2],
               ((unsigned char *)vector->vpParameter)[3],
              };
          
          TraceHex32(data_array[0]);
          TraceString("\n");
          TraceHex32(data_array[1]);
          TraceString("\n");
          TraceHex32(data_array[2]);
          TraceString("\n");
          TraceHex32(data_array[3]);
          TraceString("\n");
          
          write_sram(0x20, data_array, 4);

        }  
        else
        {
          sram[VOFS_COMMAND] = 0xb;
          sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
        }
}

static void PROCESS_DECLARE(command_nre)
{
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	write_sram(16,vector->vpParameter,vector->uiParameter/sizeof(unsigned int));
	sram[VOFS_COMMAND] = vector->usOperation;
	sram[VOFS_OP_CODE_METHOD] = info->uiProgramParameter;
	sram[VOFS_START_ADDRESS] = (vector->uiStartPage*info->uiPageSizeInByte+vector->usOffsetInPage)/(info->uiBusWidth>>3);
	sram[VOFS_LENGTH] = vector->uiImageLength/(info->uiBusWidth>>3);
	sram[VOFS_PAGE_SIZE] = info->uiPageSizeInByte/(info->uiBusWidth>>3);
	sram[VOFS_ID] = *(unsigned int*)info->aucId;
}

static BOOL CHK_RDY_DECLARE(chkrdy_readid)
{       
	const IC_INFO* info = (const IC_INFO*)vector->cvpIcInformation;
	read_sram(16,sram,(min(vector->uiParameter,info->uiIdLength)+3)/sizeof(unsigned int));
	memcpy(vector->vpParameter,sram,vector->uiParameter);
	if(memcmp(vector->vpParameter,info->aucId,info->uiIdLength)){
		return FALSE;
	}
	return TRUE;
}

static BOOL CHK_RDY_DECLARE(chkrdy_verify)
{
        vector->uiImageChecksum = sram[VOFS_CHECKSUM];
        TraceHex32(sram[VOFS_CHECKSUM]);
        TraceString("\n");
        return TRUE;
}

const VECTOR_FUNC vector_func[16] = {
	{command_vec_reset, NULL},		//VCMD_RESET_VECTOR		0{this will be called before power off, pass or error occured}
	{command_bus_reset,NULL},		//VCMD_RESET_BUS		1
	{command_initchip, NULL},		//VCMD_INIT_CHIP		2
	{command_readid, chkrdy_readid},//VCMD_READ_ID			3
	{command_unlock,NULL},			//VCMD_UNLOCK			4
	{command_erase,NULL},			//VCMD_ERASE			5
	{command_blankcheck,NULL},			//VCMD_BLANK_CHECK		6
	{command_program,NULL},			//VCMD_PROGRAM			7
	{command_verify,chkrdy_verify},	//VCMD_VERIFY			8
	{command_read,NULL},			//VCMD_READ				9
	{command_lock,NULL},			//VCMD_LOCK				10
	{command_nre,NULL},				//VCMD_NRE			11
	{NULL,NULL},					//VCMD_NULL			12
	{NULL,NULL},					//VCMD_NULL			13
	{NULL,NULL},					//VCMD_NULL			14
	{NULL,NULL},					//VCMD_NULL			15
};
