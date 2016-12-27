;PROG1002
.386P
;存储段描述符结构类型定义
Desc      	STRUC
LimitL     	DW     	0 					;段界限(BIT0 15)
BaseL     	DW    	0 					;段基地址(BIT0 15)
BaseM    	DB     	0 					;段基地址(BIT16 23)
Attributes   	DB     	0 					;段属性
LimitH    	DB     	0 					;段界限(BIT16 19)(含段属性的高4位) 
BaseH    	DB     	0 					;段基地址(BIT24 31)
Desc      	ENDS
;伪描述符结构类型定义(用于装入全局或中断描述符表寄存器)
PDesc     	STRUC
Limit      	DW      	0 					;16位界限
Base      	DD      	0 					;32位基地址
PDesc      	ENDS
;存储段描述符类型值说明
ATDR     	EQU    	90H 					;存在的只读数据段类型值
ATDW     	EQU    	92H 					;存在的可读写数据段属性值
ATDWA   	EQU    	93H 					;存在的已访问可读写数据段类型值
ATCE    	EQU    	98H 					;存在的只执行代码段属性值
ATCER   	EQU   	9AH 					;存在的可执行可读代码段属性值
ATCCO    	EQU    	9CH 					;存在的只执行一致代码段属性值
ATCCOR  	EQU    	9EH 					;存在的可执行可读一致代码段属性值
DSEG     	SEGMENT	USE16            	;16位数据段
GDT     	LABEL  	BYTE              	;全局描述符表
DUMMY  	Desc   	<>               	;空描述符
Code      	Desc   	<0FFFFH,,,ATCE,,> 	;代码段描述符
DataD    	Desc    	<0FFFFH,0,,ATDW,,>	;源数据段描述符
DataE     	Desc    	<0FFFFH,,,ATDW,,> 	;目标数据段描述符
GDTLen   	=       	$-GDT            	;全局描述符表长度
VGDTR  	PDesc   	<GDTLen 1,>      	;伪描述符
Code_Sel  	=       	Code GDT         	;代码段选择符
DataD_Sel 	=       	DataD GDT         	;源数据段选择符
DataE_Sel  	=       	DataE GDT         	;目标数据段选择符
BufLen    	=       	64                	;缓冲区字节长度
Buffer     	DB      	BufLen DUP(55H)   	;缓冲区
DSEG     	ENDS                      		;数据段定义结束
ESEG    	SEGMENT	USE16             	;16位数据段
Buffer2           DB     	BufLen DUP(0)     		;缓冲区
ESEG            ENDS                      		;数据段定义结束
SSEG            SEGMENT PARA STACK        	;16位堆栈段
                 DW     	256 DUP (0)
SSEG            ENDS                  			;堆栈段定义结束
;打开A20地址线
EnableA20        MACRO
                 PUSH   	AX
                 IN     	AL,92H
                 OR     	AL,00000010B
                 OUT    	92H,AL
                 POP    	AX
                 ENDM
;关闭A20地址线
DisableA20       MACRO
                 PUSH   	AX
                 IN      	AL,92H
                 AND    	AL,11111101B
                 OUT    	92H,AL
                 POP    	AX
                 ENDM
;字符显示宏指令的定义
EchoCh          MACRO  	ascii
                 MOV    	AH,2
                 MOV    	DL,ascii
                 INT     	21H
                 ENDM
;16位偏移的段间直接转移指令的宏定义(在16位代码段中使用)
JUMP16          MACRO 	Selector,OFFSET
                 DB      	OEAH   				;操作码
                 DW     	OFFSET 				;16位偏移量
                 DW     	SELECTOR 				;段值或段选择符
                 ENDM
CSEG            SEGMENT	USE16     				;16位代码段
                 ASSUME 	CS:CSEG,DS:DSEG
START           PROC
                 MOV    	AX,DSEG
                 MOV    	DS,AX
                ;准备要加载到GDTR的伪描述符
                MOV    	BX,16
                MUL    	BX
                ADD    	AX,OFFSET GDT      	;计算并设置基地址
                ADC    	DX,0               		;界限已在定义时设置好
                MOV    	WORD PTR VGDTR.Base,AX
                MOV    	WORD PTR VGDTR.Base+2,DX
                ;设置代码段描述符
                MOV    	AX,CS
                MUL    	BX
                MOV    	WORD PTR Code.BaseL,AX
                MOV    	BYTE PTR Code.BaseM,DL 
                MOV    	BYTE PTR Code.BaseH,DH
                ;设置源数据段描述符
                MOV    	AX,DS
                MUL    	BX
                MOV    	WORD PTR DataD.BaseL,AX
                MOV    	BYTE PTR DataD.BaseM,DL
                MOV    	BYTE PTR DataD.BaseH,DH
                ;设置目标数据段描述符
                MOV    	AX,ESEG
                MUL    	BX
                MOV    	WORD PTR DataE.BaseL,AX
                MOV    	BYTE PTR DataE.BaseM,DL
                MOV    	BYTE PTR DataE.BaseH,DH
                ;加载GDTR
                LGDT   	QWORD PTR VGDTR
                CLI                          		;关中断
                EnableA20                    		;打开地址线A20
                ;切换到保护方式
                MOV    	EAX,CR0
                OR     	EAX,1
                MOV    	CR0,EAX
                ;清指令预取队列,并真正进入保护方式
                JUMP16 	Code_Sel,<OFFSET Virtual>
Virtual:        
                ;现在开始在保护方式下运行
                MOV    	AX,DataD_Sel
                MOV    	DS,AX               	;加载源数据段描述符
                MOV    	AX,DataE_Sel
                MOV    	ES,AX              		;加载目标数据段描述符
                CLD
                LEA    	ESI,Buffer
                LEA    	EDI,Buffer2          	;设置指针初值
                MOV    	ECX,BufLen/4         	;设置传送次数
                REPZ   	movsd                	;传送
                ;切换回实模式
                MOV    	EAX,CR0
                AND    	AL,11111110B
                MOV    	CR0,EAX
                ;清指令预取队列,进入实模式
                JUMP16 	<SEG Real>,<OFFSET Real>
Real:           
                ;现在又回到实模式
                DisableA20
                STI
                MOV    	AX,DSEG
                MOV    	DS,AX
                MOV    	AX,ESEG
                MOV    	ES,AX
                MOV    	DI,OFFSET Buffer2
                CLD
                MOV   	BP,BufLen/16
NextLine:        MOV    	CX,16
NextCh:         MOV    	AL, ES:[DI]
                INC    	DI
                PUSH   	AX
                SHR    	AL,4
                CALL   	ToASCII
                EchoCh 	AL
                POP    	AX
                CALL   	ToASCII
                EchoCh 	AL
                EchoCh 	' '
                LOOP   	NextCh
                EchoCh 	0DH
                EchoCh 	0AH
                DEC    	BP
                JNZ    	NextLine
                MOV    	AX,4C00H
                INT    	21H
START          ENDP
ToASCII         PROC
                AND    	AL,0FH
                CMP    	AL,10
                JAE    	Over10
                ADD    	AL,'0'
                RET
Over10:
                ADD   	AL,'A' 10
                RET
ToASCII         ENDP
CSEG           ENDS                         	;代码段结束
                END    	START