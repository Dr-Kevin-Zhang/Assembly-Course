;PROG1003
INCLUDE         386SCD.INC
RDataSeg          SEGMENT PARA USE16            	;实模式数据段
                  ;全局描述符表
GDT              LABEL  	BYTE
                 	;空描述符
DUMMY         	Desc   	<>
                 	;规范段描述符
Normal           	Desc   	<0FFFFH,,,ATDW,,>
                 	;视频缓冲区段描述符(DPL=3)
VideoBuf         	Desc   	<0FFFFH,8000H,0BH,ATDW+DPL3,,>
EFFGDT          	LABEL	BYTE
                 	;演示任务的局部描述符表段的描述符
DemoLDTab       	Desc   	<DemoLDTLen 1,DemoLDTSeg,,ATLDT,,>
         	 	;演示任务的任务状态段描述符
DemoTSS         	Desc   	<DemoTSSLen 1,DemoTSSSeg,,AT386TSS,,>
                 	;临时任务的任务状态段描述符
TempTSS          	Desc   	<TempTSSLen 1,TempTSSSeg,,AT386TSS+DPL2,,>
                 	;临时代码段描述符
TempCode        	Desc   	<0FFFFH,TempCodeSeg,,ATCE,,>
                 	;子程序代码段描述符
SubR             	Desc   	<SubRLen 1,SubRSeg,,ATCE,D32,>
GDNum          	=    	($ EFFGDT)/8     	;需处理基地址的描述符个数
GDTLen          	=      	$ GDT          		;全局描述符表长度
VGDTR         	PDesc  	<GDTLen 1,>      	;GDT伪描述符
SPVar           	DW     	?              		;用于保存实模式下的SP
SSVar           	DW     	?             	 	;用于保存实模式下的SS
RDataSeg        	ENDS
Normal_Sel       	=      	Normal GDT
Video_Sel        	=      	VideoBuf GDT
DemoLDT_Sel    	=       	DemoLDTab GDT
DemoTSS_Sel    	=       	DemoTSS GDT
TempTSS_Sel     	=       	TempTSS GDT
TempCode_Sel    	=        	TempCode GDT
SubR_Sel        	=        	SubR GDT
DemoLDTSeg    	SEGMENT PARA USE16     	;局部描述符表数据段(16位)
DemoLDT       	LABEL  	BYTE          	 	;局部描述符表
                	;0级堆栈段描述符(32位段)
DemoStack0     	Desc   	<DemoStack0Len 1,DemoStack0Seg,,ATDW,D32,>
                	;2级堆栈段描述符(32位段)
DemoStack2     	Desc   	<DemoStack2Len 1,DemoStack2Seg,,ATDW+DPL2,D32,>
                	;演示任务代码段描述符(32位段,DPL=2)
DemoCode       	Desc   	<DemoCodeLen 1,DemoCodeSeg,,ATCE+DPL2,D32,>
                 	;演示任务数据段描述符(32位段,DPL=3)
DemoData       	Desc 	<DemoDataLen 1,DemoDataSeg,,ATDW+DPL3,D32,>
                	;把LDT作为普通数据段描述的描述符(DPL=2)
ToDLDT        	Desc  	<DemoLDTLen 1,DemoLDTSeg,,ATDW+DPL2,,>
                	;把TSS作为普通数据段描述的描述符(DPL=2)
ToTTSS         	Desc   	<TempTSSLen 1,TempTSSSeg,,ATDW+DPL2,,>
DemoLDNum     	=      	($ DemoLDT)/(8) ;需处理基地址的LDT描述符数
                	;指向子程序SubRB代码段的调用门(DPL=3)
ToSubR         	Gate   	<SubRB,SubR_Sel,,AT386CGate+DPL3,>
                	;指向临时任务Temp的任务门(DPL=3)
ToTempT        	Gate   	<,TempTSS_Sel,,ATTaskGate+DPL3,>
DemoLDTLen   	=      	$ DemoLDT
DemoLDTSeg    	ENDS                    	;局部描述符表段定义结束
DemoStack0_Sel  	=     	DemoStack0 DemoLDT+TIL
DemoStack2_Sel   	=     	DemoStack2 DemoLDT+TIL+RPL2
DemoCode_Sel    	=      	DemoCode DemoLDT+TIL+RPL2
DemoData_Sel     	=       	DemoData DemoLDT+TIL
ToDLDT_Sel      	=       	ToDLDT DemoLDT+TIL
ToTTSS_Sel       	=       	ToTTSS DemoLDT+TIL
ToSubR_Sel       	=       	ToSubR DemoLDT+TIL+RPL2
ToTempT_Sel      	=       	ToTempT DemoLDT+TIL
DemoTSSSeg      	SEGMENT PARA USE16   	;任务状态段TSS
                 	DD    	0                	;链接字
                 	DD   	DemoStack0Len    	;0级堆栈指针
                 	DW   	DemoStack0_Sel,0 	;0级堆栈选择符
                 	DD    	0                	;1级堆栈指针(实例不使用)
                 	DW    	0,0              	;1级堆栈选择符(实例不使用)
                 	DD    	0                	;2级堆栈指针
                 	DW   	0,0              	;2级堆栈选择符
                 	DD    	0                	;CR3
                 	DW   	DemoBegin,0      	;EIP
                 	DD  	0                	;EFLAGS
                 	DD   	0                	;EAX
                 	DD    	0                	;ECX
                 	DD    	0                	;EDX
                 	DD    	0                	;EBX
                 	DD    	DemoStack2Len    	;ESP
                 	DD    	0                	;EBP
                 	DD   	0                	;ESI
                DD    	(80*4+50)*2      		;EDI
                DW     	Video_Sel,0         	;ES
                DW     	DemoCode_Sel,0      	;CS
                DW     	DemoStack2_Sel,0    	;SS
                DW     	DemoData_Sel,0      	;DS
                DW     	ToDLDT_Sel,0        	;FS
                DW     	ToTTSS_Sel,0        	;GS
                DW     	DemoLDT_Sel,0      	;LDTR
                DW     	0                  	;调试陷阱标志
                DW     	$+2                	;指向I/O许可位图
                DB     	0FFH               	;I/O许可位图结束标志
DemoTSSLen     =     	$
DemoTSSSeg     ENDS                        	;任务状态段TSS结束
DemoStack0Seg   SEGMENT PARA USE32       	;演示任务0级堆栈段(32位段)
DemoStack0Len   =    		1024
                DB     	DemoStack0Len DUP(0)
DemoStack0Seg   ENDS                     	    ;演示任务0级堆栈段结束
DemoStack2Seg   SEGMENT PARA USE32          	;演示任务2级堆栈段(32位段)
DemoStack2Len   =      	512
                DB     	DemoStack2Len DUP(0)
DemoStack2Seg   ENDS                          	;演示任务2级堆栈段结束
DemoDataSeg    SEGMENT PARA USE32          	;演示任务数据段(32位段)
Message         DB     	'EDI=',0
tableH2A        DB     	'0123456789ABCDEF'
DemoDataLen     =      	$
DemoDataSeg     ENDS                          	;演示任务数据段结束
SubRSeg         SEGMENT PARA USE32          	;子程序代码段(32位)
                 ASSUME  CS:SubRSeg
SubRB           PROC  	FAR
                 PUSH  	EBP
                 MOV    	EBP,ESP
                 PUSH  	EDI
                 MOV   	ESI,DWORD PTR [EBP+12]	;从0级栈中取出偏移ESI
                 MOV   	AH,47H                		;设置显示属性
SubR1:          
                LODSB
                OR    	AL,AL
                JZ     	SubR2
                STOSW
                JMP  		short SubR1
SubR2:                
                MOV    	AH,4EH                	;设置显示属性
                MOV    	EDX,DWORD PTR [EBP+16]	;从0级栈中取出显示值
                MOV    	ECX,8
SubR3:          
                ROL   	EDX,4
                MOV   	AL,DL
                AND    	AL,0FH
                MOVZX	EBX,AL
                MOV    	AL,DS:tableH2A[EBX]
                STOSW
                LOOP  	SubR3
                POP    	EDI
                ADD   	EDI,160
                POP    	EBP
                RET   	8
SubRB          ENDP
SubRLen          =     	$
SubRSeg        ENDS                           		;子程序代码段结束
DemoCodeSeg    SEGMENT PARA USE32            	;演示任务的32位代码段
                ASSUME 	CS:DemoCodeSeg,DS:DemoDataSeg
DemoBegin      PROC  	FAR
                ;把要复制的参数个数置入调用门
                MOV   	BYTE PTR FS:ToSubR.DCount,2
                ;向2级堆栈中压入参数
                PUSH  	EDI
                PUSH  	OFFSET Message
                ;通过调用门调用SubRB
                CALL32 	ToSubR_Sel,0
                ;通过任务门切换到临时任务
                JUMP32 	ToTempT_Sel,0
                JMP   	DemoBegin
DemoBegin       ENDP
DemoCodeLen    =      	$
DemoCodeSeg  	ENDS                     		;演示任务的32位代码段结束
TempTSSSeg   	SEGMENT PARA USE16       	;临时任务的任务状态段TSS
TempTask       	TSS   		<>
              	DB     	0FFH             		;I/O许可位图结束标志
TempTSSLen      =      	$
TempTSSSeg     ENDS
TempCodeSeg    SEGMENT PARA USE16       	;临时任务的代码段
                ASSUME 	CS:TempCodeSeg
Virtual           PROC   	FAR
                MOV    	AX,TempTSS_Sel   	;装载TR
                LTR     	AX
                
                MOV   	AX,Video_Sel
                MOV    	ES,AX
                MOV    	AX,Normal_Sel
                MOV    	DS,AX
                MOV    	FS,AX
                MOV    	GS,AX
                MOV    	SS,AX
                XOR     	EDI,EDI
                MOV    	ECX,25*80
                MOV    	AX,0720H
                CLD
                REP     	STOSW
                MOV   	BYTE PTR ES:[0H], '0'
                MOV    	ECX,5
Virtual0:       
                JUMP16	DemoTSS_Sel,0   	;直接切换到演示任务
                INC     	BYTE PTR ES:[0H]
                LOOP  	Virtual0
                CLTS                    	;清任务切换标志
                MOV   	EAX,CR0         	;准备返回实模式
                AND    	AL,11111110B
                MOV   	CR0,EAX
                JUMP16 	<SEG Real>,<OFFSET Real>
Virtual           ENDP
TempCodeSeg     ENDS
RStackSeg        SEGMENT PARA STACK     	;实模式堆栈段
                 DB      	512 DUP (0)
RStackSeg        ENDS                     	;堆栈段结束
RCodeSeg        SEGMENT PARA USE16
                 ASSUME 	CS:RCodeSeg,DS:RDataSeg,ES:RDataSeg
START           PROC
                MOV  	AX,RDataSeg
                MOV    	DS,AX
                MOV    	SSVar,SS
                MOV    	SPVar,SP
                CLD
                CALL  	InitGDT               	;初始化全局描述符表GDT
                CALL   	InitLDT               	;初始化局部描述符表LDT
                LGDT   	QWORD PTR VGDTR   	;装载GDTR切换到保护模式
                CLI
                MOV  	EAX,CR0
                OR      	AL,1
                MOV    	CR0,EAX
                JUMP16 	<TempCode_Sel>,<OFFSET Virtual>
Real:           
                MOV   	AX,RDataSeg           	;又回到实模式
                MOV    	DS,AX
                MOV    	SP,SPVar
                MOV    	SS,SSVar
                STI
                MOV    	AX,4C00H
                INT      	21H
START          ENDP
InitGDT         PROC
                MOV  	CX,GDNum
                MOV    	SI,OFFSET EFFGDT
                MOV    	BX,16
InitG:          
                MOV    	AX,[SI].BaseL
                MUL     	BX
                MOV    	WORD PTR [SI].BaseL,AX
                MOV    	BYTE PTR [SI].BaseM,DL
                MOV    	BYTE PTR [SI].BaseH,DH
                ADD   	SI,8
                LOOP   	InitG
                MOV    	AX,DS
                MUL    	BX
                ADD    	AX,OFFSET GDT
                ADC    	DX,0
                MOV     	WORD PTR VGDTR.Base,AX
                MOV  	WORD PTR VGDTR.Base+2,DX
                RET
InitGDT         ENDP
InitLDT         PROC
                MOV   	AX,DemoLDTSeg
                MOV    	ES,AX
                MOV    	SI,OFFSET DemoLDT
                MOV    	CX,DemoLDNum
                MOV    	BX,16
InitL:
                MOV    	AX,WORD PTR ES:[SI].BaseL
                MUL    	BX
                MOV    	WORD PTR ES:[SI].BaseL,AX
                MOV    	BYTE PTR ES:[SI].BaseM,DL
                MOV    	BYTE PTR ES:[SI].BaseH,DH
                ADD    	SI,8
                LOOP   	InitL
                RET
InitLDT          ENDP
RCodeSeg        ENDS
                END    	start