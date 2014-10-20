	JP A1,=ResetVector
	JP A1,=BusReset
	JP A1,=InitialChip
	JP A1,=ReadID
	JP A1,=VerifyOption
	JP A1,=Erase
	JP A1,=BlankCheck
	JP A1,=Program
	JP A1,=Verify
	JP A1,=Read
	JP A1,=ReadInfor
    	JP A1,=ProgramInfo
	JP A1,=SecErase
	JP A1,=VerifyInfo
	JP A1,=ProgramOption
	JP A1,=ReadOption
	;JP A1,=BlankCheckOption
;----------------------VectorEntry------------------------------
;---------VDD-IO3;TDO-IO1;TMS-IO4;TDI-IO5;TCK-IO6-------------
VectorEntry:
	MOV R1,#8			;command response
	LDR R0,[R1]
	AND R0,#0x8000
	JP BF,=VectorEntry
	LDR R0,[R1]
	AND R0,#0xF
	JPR A1,R0
;END
	
OperationPass:
	;MOV BSW1,#0
	MOV R0,#0x8000		;RO = BIT15
	JP A1,=__operation_result
OperationFail:
	;MOV BSW1,#0
	MOV R0,#0xC000		;RO = BIT15|BIT14
	JP A1,=__operation_result
OperationUnsupport:
	MOV R0,#0xE000		;RO = BIT15|BIT14|BIT13
	JP A1,=__operation_result
	
__operation_result:
	MOV R1,#0x8
	OR  R0,[R1]			;R0 = BIT15|?BIT14|?BIT13[command_response]
	LDR [R1],R0
	JP A1,=VectorEntry
;END
	
;----------------------ResetVector------------------------------
ResetVector:
	MOV R0,#0x0
__reset_vector:
	LDR R1,R0
	MOV [R1],#0
	ADD R0,#1
	JP B4,=GetVerType
	JP A1,=__reset_vector
;END

;----------------------ResetVector------------------------------
GetVerType:
	MOV R1,#10		;[10] = VERSION
	MOV [R1],#100		;version 100
	
	MOV R1,#0X8000
        MOV [R1],#0X1	;IO3 4 5 6 enable
        MOV R1,#0x8001
        MOV [R1],#0x0	;IO3 high
	MOV R2,#100
	CALL =DLY_MS
	JP A1,=OperationPass
;END
	
BusReset:
	JP A1,=OperationPass	
Unlock:
    JP A1,=OperationPass 
InitialChip:
    JP A1,=OperationPass    
;-------------------------------------------
;Parameter = R2	
DLY_US:
	PUSH R0
	LDR R0,R2
DLY_US_LP:	
	;DLYUS #1	;delays 1 us
	;DLYUS #1
	NOP #76		;delay 1 us
	SUB R0,#1
	JP Z,=DLY_US_DONE
	JP A1,=DLY_US_LP
DLY_US_DONE:	
	POP R0
	RET
;----------------------------------------------
;Parameter = R2		
DLY_MS:	
	PUSH R0	
	LDR R0,R2
DLY_MS_LP:
	DLYUS #500 ; delays 0.5 ms 
	DLYUS #500 ; delays 0.5 ms 
	SUB R0,#1	
	JP Z,=DLY_MS_DONE
	JP A1,=DLY_MS_LP
DLY_MS_DONE:	
	POP R0
	RET
;--------------------------------------------------------
TMSInput:
	MOV R1,#20
	MOV [R1],#0xA5
TMSLoop:
	MOV R1,#0x8001
	MOV [R1],#0x34 ;output low
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x3C ;output high
	MOV R2,#1
	CALL =DLY_US
	
	MOV R1,#20
	LDR R0,[R1]
	SUB R0,#1
	LDR [R1],R0
	JP Z,=TMSInputEnd
	JP A1,=TMSLoop
TMSInputEnd:
	POP PC
;---------------------------------------
TDIInput:
	MOV R1,#20
	MOV [R1],#0x69
TDILoop:
	MOV R1,#0x8001
	MOV [R1],#0x2C
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x3C
	MOV R2,#1
	CALL =DLY_US
	
	MOV R1,#20
	LDR R0,[R1]
	SUB R0,#1
	LDR [R1],R0
	JP Z,=TDIInputEnd
	JP A1,=TDILoop
TDIInputEnd:
	POP PC
;-----------------------------------------
TCKInput:
	MOV R1,#20
	MOV [R1],#0x5A
TCKLoop:
	MOV R1,#0x8001
	MOV [R1],#0x1C
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x3C
	MOV R2,#1
	CALL =DLY_US
	
	MOV R1,#20
	LDR R0,[R1]
	SUB R0,#1
	LDR [R1],R0
	JP Z,=TCKInputEnd
	JP A1,=TCKLoop
TCKInputEnd:
	POP PC
;---------------------------------------
TMSDLY:
	MOV R1,#20
	MOV [R1],#0x8000
TMSDLYLoop:
	MOV R1,#0x8001
	MOV [R1],#0x34
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x3C	;00111100
	MOV R2,#1
	CALL =DLY_US
	
	MOV R1,#20
	LDR R0,[R1]
	SUB R0,#1
	LDR [R1],R0
	JP Z,=TMSDLYEnd
	JP A1,=TMSDLYLoop
TMSDLYEnd:
	MOV R1,#0x8001
	MOV [R1],#0x14	;IO 3 5 6 high 0011 0100
	POP PC
;-------------------------------------
;---------R0---Parameter
WriteData:
	MOV R1,#27
	MOV [R1],#8
	RSL R0,#16
	RSL R0,#8
GoNextClk:
	RSL R0,#1
	JP B0,=SendHigh
	PUSH R0
	MOV R1,#0x8001
	MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x24	;00110100
	MOV R2,#2
	CALL =DLY_US
	MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
	JP A1,=NextClk
SendHigh:
	PUSH R0
	MOV R1,#0x8001
	MOV [R1],#0x14	;00010100	high clk
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x34	;00110100
	MOV R2,#2
	CALL =DLY_US
	MOV [R1],#0x14	;00010100	high clk
	MOV R2,#1
	CALL =DLY_US
NextClk:
	MOV R1,#27
	LDR R0,[R1]
	SUB R0,#1
	LDR [R1],R0
	JP Z,=ClkEnd
	POP R0
	JP A1,=GoNextClk
ClkEnd:
	POP R0
	JP B0,=HighEnd
	MOV R1,#0x8001
	MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x24	;00110100
	MOV R2,#2
	CALL =DLY_US
	MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
	JP A1,=AllEnd
HighEnd:
	MOV R1,#0x8001
	MOV [R1],#0x14	;00010100	high clk
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x34	;00110100
	MOV R2,#2
	CALL =DLY_US
	MOV [R1],#0x14	;00010100	high clk
	MOV R2,#1
	CALL =DLY_US
AllEnd:
	MOV R1,#0x8001
	MOV [R1],#0x4	;00010100	low clk
	POP PC
;-----------------------------------------
;-------------------------------------------------------
OutPutBSW1:
	MOV BSW0,#0x10              ;shift out
    	MOV R0,#0x4D  ;004d0031
    	RSR R0,#16
    	OR R0,#0x30
    	LDR BSW1,R0
    	POP PC 
InPutBSW1:
	MOV BSW0,#0x20              ;shift in
    	MOV R0,#0x4D
    	RSR R0,#16
    	OR R0,#0x4030               
    	LDR BSW1,R0
    	POP PC 
;----------------------------------------
ClearWatchDog:
	MOV R0,#0x49
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
	POP PC
;-----------------------------------------
;-------------------------------------------------------
;IO1-TDO  IO3-VPP(4V)   IO4-TMS  IO5-TDI  IO6-TCK
ProgramMode:
        MOV R1,#0X8000
        MOV [R1],#0X1	;IO3 4 5 6 enable
        MOV R1,#0x8001
        MOV [R1],#0x4	;IO3 high
	DLYUS #100
	;JP A1,=OperationPass
	MOV [R1],#0x3C	;IO 4 5 6 high
	DLYUS #500
	
        PUSH PC
        JP A1,=TMSInput
        DLYUS #8
        
        PUSH PC
        JP A1,=TDIInput
        DLYUS #8
        
        PUSH PC
        JP A1,=TCKInput
        DLYUS #8
        
        PUSH PC
        JP A1,=TMSDLY
        
        MOV R0,#0x96
        PUSH PC
        JP A1,=WriteData
        
        MOV R1,#0x8001
	MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
	
	MOV [R1],#0x24	;00100100
	MOV R2,#2
	CALL =DLY_US
	MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
    	
    	MOV R1,#0x8001
        MOV [R1],#0x24	;IO3 high IO6
        DLYUS #10
        
        MOV [R1],#0x2C	;IO3 high IO6 IO4
        DLYUS #8
        
        MOV [R1],#0x24	;IO3 high IO6
        DLYUS #10
        MOV [R1],#0x4	;IO3 high
        
        MOV R0,#0x96
        PUSH PC
        JP A1,=WriteData
        MOV R1,#0x8001
        MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
	MOV [R1],#0x24	;00110100
	MOV R2,#2
	CALL =DLY_US
	MOV [R1],#0x4	;00010100	low clk
	MOV R2,#1
	CALL =DLY_US
	
	DLYUS #600
    	PUSH PC
    	JP A1,=ClearWatchDog
    	DLYUS #600
        POP PC
;----------------------------------------------
SetClk:
	MOV R0,#0x46
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xF0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	POP PC
;------------------------------------
SetAddress:
	MOV R0,#0x40
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x41
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	POP PC
;---------------------------------------------------
StartAddress:
	MOV R0,#0x40
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x41
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	POP PC
;-------------------------------------------------------
OptionAddress:
	MOV R0,#0x40
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
    	
    	MOV R0,#0x6
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
    	
    	MOV R0,#0x41
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
    	
    	MOV R0,#0x8
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	POP PC
;---------------------------------------------------
GetData:
	MOV R0,#0x4A
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
    	MOV BSW2,#9            ;length
    	PUSH PC
    	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	DLYUS #11
	MOV R1,#0x10
	LDR [R1],BSR0
	POP PC
;--------------------------------------------
;----------------------------------------------
DLY30MS:
	MOV R1,#22
	MOV [R1],#60
DLYNext:	
	DLYUS #500
	LDR R0,[R1]
	SUB,R0,#1
	LDR [R1],R0
	JP Z,=DLYEnd
	JP A1,=DLYNext
DLYEnd:
	POP PC
;-------------------------------------------------
;R3  first data,  R2  type
CommandList:
	PUSH R2
	MOV R0,#0x42
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	LDR R0,R3
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	POP R2
	LDR R0,R2
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x15
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0xA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x9
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x6
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	POP PC
;-------------------------------------------------------------------
PassWord:
	MOV R3,#0
    	MOV R2,#0xA5
    	PUSH PC
    	JP A1,=CommandList
    	
    	MOV R1,#30
    	MOV [R1],#62
PassWordLoop:
    	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R1,#30
	LDR R0,[R1]
	SUB R0,#1
	LDR [R1],R0
	JP Z,=PassWordNext
	JP A1,=PassWordLoop
PassWordNext:  	
    	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xAA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	POP PC
;-------------------------------------------------------------------
SetPassWordAddr:
	MOV R0,#0x40
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
    	
    	MOV R0,#0xA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
    	
    	MOV R0,#0x41
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
    	
    	MOV R0,#0x8
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
    	POP PC
;--------------------------------------------------------------
;---------------sram 31 read length-------------------------------------
ReadInfor:
	MOV DSET,#0x88C0
    	MOV DSET,#0x6622
    	LDR R0,FFLEN
    	AND R0,#0xFFFF
    	JP Z,=ReadInfoWaitData
    	JP A1,=ReadInfor
ReadInfoWaitData:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
	
	PUSH PC
	JP A1,=StartAddress
    	
    	MOV R0,#0x4A
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV BSW2,#9            ;length
ReadPassWordNext:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	PUSH R0

	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	RSL R0,#0x8
    	MOV R3,#0xFF00
    	AND R0,R3
    	LDR R3,R0
    	POP R0
    	OR R0,R3
    	MOV R1,#0x8010
    	LDR [R1],R0
    	
	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#2
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0
    	JP Z,=ReadPassWordEnd
    	JP A1,=ReadPassWordNext
ReadPassWordEnd:
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;-------------------------------------------------------------
Stop:
	MOV BSW1,#0
	MOV BSW1,#0
	MOV R1,#0X8000
        MOV [R1],#0X0	;IO3 4 5 6 enable
        MOV R1,#0x8001	
        MOV [R1],#0x0	;IO3 high
	MOV R2,#10
	CALL =DLY_MS
	POP PC
;-----------------------------------------------------------
ReadID:
	PUSH PC
	JP A1,=ProgramMode
	PUSH PC
	JP A1,=SetClk
	PUSH PC
	JP A1,=SetAddress
	PUSH PC
	JP A1,=GetData
	PUSH PC
	JP A1,=Stop
	JP A1,=OperationPass
;-----------------------------------------------------------------
ClearPassWord:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
	PUSH PC
	JP A1,=SetPassWordAddr
	
	PUSH PC
	JP A1,=PassWord
	POP PC
;-----------------------------------------------------------------
Erase:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	PUSH PC
    	JP A1,=StartAddress
    	
    	MOV R3,#0
    	MOV R2,#0xAA
    	PUSH PC
    	JP A1,=CommandList
        
        MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
        
        MOV R1,#0x8001
        MOV [R1],#0x14	;IO3 high IO5

	PUSH PC
	JP A1,=DLY30MS
	DLYUS #500
	
	MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
        
        MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
        
        MOV R1,#0x8001
        MOV [R1],#0x3C	;IO3 high IO5
        DLYUS #50
	
	PUSH PC
    	JP A1,=ClearPassWord
    	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;--------------------------------------------------------------------
SecErase:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	
    	MOV R1,#3
    	MOV [R1],#0
    	MOV R1,#4
    	MOV [R1],#4
SecEraseLoop:
    	MOV R0,#0x40
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x41
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	;MOV R0,#0x0
	MOV R1,#3
	LDR R0,[R1]
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
    	
    	MOV R3,#0
    	MOV R2,#0x55
    	PUSH PC
    	JP A1,=CommandList
        
        MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
        
        MOV R1,#0x8001
        MOV [R1],#0x14	;IO3 high IO5

	PUSH PC
	JP A1,=DLY30MS
	DLYUS #500
	
	MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
        
        MOV R0,#0xFF
        PUSH PC
        JP A1,=WriteData
        
        MOV R1,#0x8001
        MOV [R1],#0x3C	;IO3 high IO5
        DLYUS #50
	
	PUSH PC
    	JP A1,=ClearPassWord
    	
	MOV R1,#3
	LDR R0,[R1]
	ADD R0,#1
	LDR [R1],R0
	
	MOV R1,#4
	LDR R0,[R1]
	SUB R0,#1
	LDR [R1],R0
	JP Z,=SecEraseEnd
	JP A1,=SecEraseLoop
SecEraseEnd:
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;-----------------------------------------------------------------------
BlankCheck:
    	MOV DSET,#0x88C0
    	MOV DSET,#0x6622
    	LDR R0,FFLEN
    	AND R0,#0xFFFF
    	JP Z,=BlankCheckWaitData
    	JP A1,=BlankCheck
BlankCheckWaitData:
	MOV R1,#1
	LDR R0,[R1]
	JP B0,=BlankCheckInfor
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	PUSH PC
    	JP A1,=StartAddress
    	
    	MOV R0,#0x44
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
BlankLoop:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
    	XOR R0,#0x0
	JP Z,=BlankNext
    	JP A1,=BlankEnd
BlankNext:
	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#1
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#1
    	LDR [R1],R0
    	JP Z,=BlankOver
    	JP A1,=BlankLoop
BlankOver:
	PUSH PC
	JP A1,=Stop	
    	JP A1,=OperationPass
BlankEnd:
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationFail
;-----------------------------------------------------------------
BlankCheckInfor:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	PUSH PC
    	JP A1,=StartAddress
    	
    	MOV R0,#0x4A
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV BSW2,#9
BlankInfoLoop:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
    	XOR R0,#0x0
	JP Z,=BlankInfoNext
    	JP A1,=BlankInfoEnd
BlankInfoNext:
	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#1
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#1
    	LDR [R1],R0
    	JP Z,=BlankInfoOver
    	JP A1,=BlankInfoLoop
BlankInfoOver:	
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
BlankInfoEnd:
	PUSH PC
	JP A1,=Stop
	JP A1,=OperationFail
;---------------------------------------------------------------
Program:
    	MOV DSET,#0x88C0
    	MOV DSET,#0x6622
    	LDR R0,FFLEN
    	AND R0,#0xFFFF
    	JP Z,=ProgramWaitData
    	JP A1,=Program
ProgramWaitData:
    	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	PUSH PC
    	JP A1,=StartAddress
	
    	MOV R1,#3		;length-2
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0

    	JP DE,=this			;getData
    	MOV R1,#0x8010
    	LDR R0,[R1]
    	MOV R1,#0
    	PUSH R0
    	LDR R3,R0
    	MOV R2,#0x6E
    	PUSH PC
    	JP A1,=CommandList
    	
	POP R0
	RSR R0,#8
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
ProgLoop:
	JP DE,=this			;getData
    	MOV R1,#0x8010
    	LDR R0,[R1]
    	MOV R1,#0
    	PUSH R0
    
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	POP R0
	RSR R0,#8
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#2
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0
    	JP Z,=ProgNext

    	JP A1,=ProgLoop
ProgNext:
    	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xAA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;-------------------------------------------------------------
Verify:
    	MOV DSET,#0x88C0
    	MOV DSET,#0x6622
    	LDR R0,FFLEN
    	AND R0,#0xFFFF
    	JP Z,=VerifyWaitData
    	JP A1,=Verify
VerifyWaitData:
	MOV R1,#1
	LDR R0,[R1]
	JP B0,=VerifyInfo
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	PUSH PC
    	JP A1,=StartAddress
    	
    	MOV R0,#0x44
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV BSW2,#9
VerifyLoop:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	PUSH R0
	
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	RSL R0,#0x8
    	MOV R3,#0xFF00
    	AND R0,R3
    	LDR R3,R0
    	POP R0
    	OR R0,R3
    	MOV R1,#0x8010
    	XOR R0,[R1]
	JP Z,=VerifyNext
    	JP A1,=VerifyEnd
VerifyNext:
    	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#2
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0
    	JP Z,=VerifyOver
    	JP A1,=VerifyLoop
VerifyOver:
    	MOV R1,#10
    	LDR [R1],CRCR
    	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
VerifyEnd:
    	MOV R1,#10
    	LDR [R1],CRCR
    	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationFail
;-------------------------------------------------------------------
Read:
	MOV DSET,#0x88C0
    	MOV DSET,#0x6622
    	LDR R0,FFLEN
    	AND R0,#0xFFFF
    	JP Z,=ReadWaitData
    	JP A1,=Read
ReadWaitData:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	PUSH PC
    	JP A1,=StartAddress

    	MOV R0,#0x44
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV BSW2,#9
ReadLoop:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	PUSH R0

	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	RSL R0,#0x8
    	MOV R3,#0xFF00
    	AND R0,R3
    	LDR R3,R0
    	POP R0
    	OR R0,R3
    	MOV R1,#0x8010
    	LDR [R1],R0

    	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#2
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0
    	JP Z,=ReadEnd
    	JP A1,=ReadLoop
ReadEnd:
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;--------------------------------------------------------------
ProgramInfo:
	MOV DSET,#0x88C0
    	MOV DSET,#0x6622
    	LDR R0,FFLEN
    	AND R0,#0xFFFF
    	JP Z,=ProgramInfoWaitData
    	JP A1,=ProgramInfo
ProgramInfoWaitData:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	PUSH PC
    	JP A1,=StartAddress
    	
    	MOV R1,#3		;length-2
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0

    	JP DE,=this			;getData
    	MOV R1,#0x8010
    	LDR R0,[R1]
    	MOV R1,#0
    	PUSH R0
    	LDR R3,R0
    	MOV R2,#0xA5
    	PUSH PC
    	JP A1,=CommandList
    	
	POP R0
	RSR R0,#8
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
ProgramInfoLoop:
	JP DE,=this			;getData
    	MOV R1,#0x8010
    	LDR R0,[R1]
    	MOV R1,#0
    	PUSH R0
    
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	POP R0
	RSR R0,#8
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0
    	JP Z,=ProgramInfoNext
    	JP A1,=ProgramInfoLoop
ProgramInfoNext:
    	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xAA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;-----------------------------------------------------------------------------------
WritePassWord:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
        PUSH PC
	JP A1,=SetPassWordAddr
    	
    	MOV R1,#0x34
    	LDR R0,[R1]
    	LDR R3,R0
    	;MOV R3,#0xFF		;one
    	MOV R2,#0xA5
    	PUSH PC
    	JP A1,=CommandList
	
	MOV R1,#0x35
    	LDR R0,[R1]
	;MOV R0,#0xFF		;two
        PUSH PC
        JP A1,=WriteData
        MOV R0,#0x00
        PUSH PC
        JP A1,=WriteData
        
        ;MOV R0,#0xFF		;three
        MOV R1,#0x36
    	LDR R0,[R1]
        PUSH PC
        JP A1,=WriteData
        MOV R0,#0x00
        PUSH PC
        JP A1,=WriteData
        
        ;MOV R0,#0xFF		;four
        MOV R1,#0x37
    	LDR R0,[R1]
        PUSH PC
        JP A1,=WriteData
        MOV R0,#0x00
        PUSH PC
        JP A1,=WriteData
        
        MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xAA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;----------------------------------------------------------
ProgramOption:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	
    	PUSH PC
    	JP A1,=OptionAddress

    	MOV R1,#0x20
    	LDR R3,[R1]
    	MOV R2,#0xA5
    	PUSH PC
    	JP A1,=CommandList
    				;two
	MOV R1,#0x21
	LDR R0,[R1]
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5

    	MOV R1,#0x22
    	LDR R0,[R1]

        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R1,#0x23
	LDR R0,[R1]
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
    	
    	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0xAA
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV R0,#0x0
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;---------------------------------------------------------
ReadOption:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	
    	PUSH PC
    	JP A1,=OptionAddress
	
	MOV R0,#0x4A
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV BSW2,#9 
ReadOptionNext:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	PUSH R0

	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	RSL R0,#0x8
    	MOV R3,#0xFF00
    	AND R0,R3
    	LDR R3,R0
    	POP R0
    	OR R0,R3
    	MOV R1,#0x8010
    	LDR [R1],R0
    	
	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#2
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0
    	JP Z,=ReadOptionEnd
    	JP A1,=ReadOptionNext
ReadOptionEnd:
	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
;---------------------------------------------
VerifyOption:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
    	
    	PUSH PC
    	JP A1,=OptionAddress
	
	MOV R1,#0x50
	MOV [R1],#0x30
	
	MOV R0,#0x4A
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV BSW2,#9 
VerifyOptionNext:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
    	MOV R1,#0x50
    	LDR R2,[R1]
    	LDR R1,R2
    	XOR R0,[R1]
    	LDR R3,R0
    	JP Z,=VerifyOptionGo
    	JP A1,=VerifyOptionFail
VerifyOptionGo:
	MOV R1,#0x50
    	LDR R0,[R1]
    	ADD R0,#1
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#1
    	LDR [R1],R0
    	JP Z,=VerifyOptionEnd
    	JP A1,=VerifyOptionNext
VerifyOptionEnd:
	PUSH PC
	JP A1,=Stop
	JP A1,=WritePassWord
    	;JP A1,=OperationPass
VerifyOptionFail:
	PUSH PC
	JP A1,=Stop
	JP A1,=OperationFail
;-------------------------------------------------
VerifyInfo:
	MOV DSET,#0x88C0
    	MOV DSET,#0x6622
    	LDR R0,FFLEN
    	AND R0,#0xFFFF
    	JP Z,=VerifyInfoWaitData
    	JP A1,=VerifyInfo
VerifyInfoWaitData:
	PUSH PC
    	JP A1,=ProgramMode
    	PUSH PC
    	JP A1,=SetClk
	
	PUSH PC
	JP A1,=StartAddress
    	
    	MOV R0,#0x4A
        PUSH PC
        JP A1,=WriteData
	DLYUS #5
	MOV BSW2,#9            ;length
VerifyInfoNext:
	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	PUSH R0

	PUSH PC
	JP A1,=InPutBSW1
	RUN
	JP BSY,=this
	LDR R0,BSR0
	RSL R0,#0x8
    	MOV R3,#0xFF00
    	AND R0,R3
    	LDR R3,R0
    	POP R0
    	OR R0,R3
    	MOV R1,#0x8010
    	XOR R0,[R1]
	JP Z,=VerifyInfoGo
    	JP A1,=VerifyInfoFail
VerifyInfoGo:
	MOV R1,#9
    	LDR R0,[R1]
    	ADD R0,#2
    	LDR [R1],R0
    	MOV R1,#3		;length
    	LDR R0,[R1]
    	SUB R0,#2
    	LDR [R1],R0
    	JP Z,=VerifyInfoEnd
    	JP A1,=VerifyInfoNext
VerifyInfoEnd:
	MOV R1,#10
    	LDR [R1],CRCR
    	PUSH PC
	JP A1,=Stop
    	JP A1,=OperationPass
VerifyInfoFail:
	MOV R1,#10
    	LDR [R1],CRCR
    	PUSH PC
	JP A1,=Stop
	JP A1,=OperationFail
	;JP A1,=OperationPass