;PROG1005
.386P
;存储段描述符结构类型定义
Desc      	STRUC
LimitL      	DW 	0 	;段界限(BIT0-15)
BaseL       	DW    	0	;段基地址(BIT0-15)
BaseM  	DB      	0	;段基地址(BIT16-23)
Attrs   	DB     	0 	;段属性
LimitH  	DB      	0 	;段界限(BIT16-19)(含段属性的高4位)
BaseH  	DB 	0 	;段基地址(BIT24-31)
Desc   	ENDS
;伪描述符结构类型定义(用于装入全局或中断描述符表寄存器)
PDesc  	STRUC
Limit  	DW     	0 	;16位界限
Base    	DD  	0 	;32位基地址
PDesc   	ENDS
;门描述符结构类型定义
Gate    	STRUC
OffsetL 	DW      	0	;32位偏移的低16位
Selector	DW      	0	;选择符
DCount  	DB      	0 	;双字计数
GType    	DB     	0 	;类型
OffsetH  	DW  	0 	;32位偏移的高16位
Gate    	ENDS
;存储段描述符类型值说明
ATDW    	EQU     	92H 	;存在的可读写数据段属性值
ATDWA    	EQU     	93H 	;存在的已访问可读写数据段类型值
ATCER 	EQU   	9aH	;存在的可执行可读代码段属性值
DSEG   	SEGMENT USE16   	;16位数据段
GDT    	LABEL  	BYTE    	;全局描述符表
DUMMY    	Desc   	<>    	;空描述符
Code     	Desc <0FFFFH,,,ATCER,,>	;代码段描述符
DataV   	Desc <0FFFFH,,,ATDW,,> 	;数据段描述符（屏幕缓冲区）
DataP    	Desc <0FFFFH,,,ATDWA,,> 	;数据段描述符
Code32  	Desc <0FFFFH,,,ATCER,40H,>	;代码段描述符
GDTLen  	 =       $ GDT        	;全局描述符表长度
VGDTR    PDesc   <GDTLen 1,>         	;伪描述符
; IDT
ALIGN 32
IDT            LABEL    BYTE
IDT_00_1F Gate 32	DUP  (<OFFSET SpuriousHandler,Code32_Sel,0,8EH,0>)
IDT_20    Gate 1 	DUP  (<OFFSET IRQ0Handler,Code32_Sel,0,8EH,0>)
IDT_21    Gate 1	DUP  (<OFFSET IRQ1Handler,Code32_Sel,0,8EH,0>)
IDT_22_7F Gate 94	DUP  (<OFFSET SpuriousHandler,Code32_Sel,0,8EH,0>)
IDT_80    Gate 1	DUP  (<OFFSET UserIntHandler,Code32_Sel,0,8EH,0>)
IDTLen          	=       	$-IDT         	;中断描述符表长度
VIDTR           	PDesc   	<IDTLen 1,>   	;伪描述符
_SavedSP        	DW      	0
_SavedSS        	DW      	0
_SavedIDTR      	DD      	0             	; 用于保存 IDTR
               	DD      	0
                
DSEG          	ENDS                  	;数据段定义结束
PSEG            	SEGMENT PARA STACK    	;保护模式下使用的数据段
                	DB      	512 DUP (0)
TopOfStack      	LABEL  	BYTE
inkey           	DB      	0
_tmp            	DB      	0                
_SavedIMREG_M	DB      	0             	; 中断屏蔽寄存器值 (主片)
_SavedIMREG_S   DB      	0             	; 中断屏蔽寄存器值 (从片)
PSEG           	ENDS
SSEG            	SEGMENT PARA STACK    	;16位堆栈段
                	DB      	512 DUP (0)
SSEG            	ENDS                  	;堆栈段定义结束
Code_Sel        	=       	Code GDT      	;16位代码段选择符
DataV_Sel      	=       	DataV GDT     	;屏幕缓冲区数据段选择符
DataP_Sel       	=       	DataP GDT     	;PSEG数据段选择符
Code32_Sel      	=       	Code32 GDT    	;32位代码段段选择符
;打开A20地址线
EnableA20     	MACRO
        PUSH    	AX
        IN      	AL,92H
        OR      	AL,00000010B
        OUT     	92H,AL
        POP     	AX
        ENDM
;关闭A20地址线
DisableA20      	MACRO
        PUSH    	AX
        IN      	AL,92H
        AND     	AL,11111101B
        OUT     	92H,AL
        POP     	AX
        ENDM
;16位偏移的段间直接转移指令的宏定义(在16位代码段中使用)
JUMP16  MACRO	Selector,OFFSET
         DB     	0EAH     		;操作码
         DW     	OFFSET   		;16位偏移量
         DW     	SELECTOR 	;段值或段选择符
         ENDM
CSEG    SEGMENT USE16         	;16位代码段
         ASSUME	CS:CSEG,DS:DSEG
START   PROC
         MOV   	AX,DSEG
         MOV  	DS,AX
         MOV  	_SavedSP,SS
         MOV 	_SavedSS,SP
         ;准备要加载到GDTR的伪描述符
         MOV   	BX,16
         MUL  	BX
         ADD   	AX,OFFSET GDT           	;计算并设置基地址
         ADC   	DX,0                    	;界限已在定义时设置好
         MOV  	WORD PTR VGDTR.Base,AX
         MOV  	WORD PTR VGDTR.Base+2,DX
         ;准备要加载到IDTR的伪描述符
         MOV   	AX,SEG IDT
         MOV   	BX,16
         MUL  	BX
         ADD   	AX,OFFSET IDT           	;计算并设置基地址
         ADC  	DX,0                    	;界限已在定义时设置好
         MOV   	WORD PTR VIDTR.Base,AX
         MOV   	WORD PTR VIDTR.Base+2,DX
         ;设置代码段描述符
         MOV  	AX,CS
        MUL     	BX
        MOV    	WORD PTR Code.BaseL,AX
        MOV   	BYTE PTR Code.BaseM,DL
        MOV 	BYTE PTR Code.BaseH,DH
        ;设置代码段描述符（32位代码段）
        MOV 	AX,SEG SpuriousHandler
        MUL   	BX
        MOV   	WORD PTR Code32.BaseL,AX
        MOV  	BYTE PTR Code32.BaseM,DL
        MOV  	BYTE PTR Code32.BaseH,DH
        ;设置数据段描述符（屏幕显示缓冲区）
        MOV 	AX,8000H
        MOV  	DX,000BH
        MOV  	WORD PTR DataV.BaseL,AX
        MOV  	BYTE PTR DataV.BaseM,DL
        MOV  	BYTE PTR DataV.BaseH,DH
        ;设置数据段描述符（保护模式下使用的数据段）
        MOV  	AX,PSEG
        MUL	BX           	;计算并设置数据段基址
        MOV 	WORD PTR DataP.BaseL,AX
        MOV 	BYTE PTR DataP.BaseM,DL
        MOV 	BYTE PTR DataP.BaseH,DH
        ; 保存 IDTR
        SIDT	QWORD PTR _SavedIDTR
        ;加载GDTR
        LGDT	QWORD PTR VGDTR
        CLI                    	;关中断
        EnableA20              	;打开地址线A20
        LIDT    	QWORD PTR VIDTR
        ;切换到保护方式
        MOV   	EAX,CR0
        OR      	EAX,1
        MOV    	CR0,EAX
        ;清指令预取队列,并真正进入保护模式
        JUMP16  Code_Sel,<OFFSET Virtual>
ALIGN 32
Virtual:        			;现在开始在保护模式下运行
        MOV 	AX,DataV_Sel
        MOV   	GS,AX          	;GS指向屏幕显示缓冲区
        MOV     AX,DataP_Sel
        MOV     DS,AX          	;DS指向PSEG
        MOV     SS,AX          	;SS指向PSEG
        MOV     SP,OFFSET TopOfStack
      	; 保存中断屏蔽寄存器(IMREG)值
        IN     	AL,21H
        MOV   	_SavedIMREG_M,AL
        IN      	AL,0A1H
        MOV   	_SavedIMREG_S,AL
        CALL  	Init8259A
        INT  	080H
        STI
WaitLoop:
        MOV  	AL,inkey
        MOV   	_tmp,AL   
        CMP  	_tmp,1
        JNZ    	WaitLoop
        CLI
        CALL 	SetRealmode8259A
        ;切换回实模式
        MOV   	EAX,CR0
        AND  	AL,11111110B
        MOV   	CR0,EAX
        ;清指令预取队列,进入实模式
        JUMP16  <SEG Real>,<OFFSET Real>
Init8259A:
        MOV   	AL,011H
        OUT     	020H,AL    	; 主8259,ICW1.
        CALL   	IO_delay
        OUT   	0A0H,AL   	; 从8259,ICW1.
        CALL  	IO_delay
        MOV  	AL,020H    	; IRQ0 对应中断向量 0x20
        OUT   	021H,AL    	; 主8259,ICW2.
        CALL 	IO_delay
        MOV   	AL,028H    	; IRQ8 对应中断向量 0x28
        OUT  	0A1H,AL    	; 从8259,ICW2.
        CALL	IO_delay
        MOV  	AL,004H   		; IR2 对应从8259
        OUT   	021H,AL    	; 主8259,ICW3.
        CALL   	IO_delay
        MOV    	AL,002H    	; 对应主8259的 IR2
        OUT    	0A1H,AL    	; 从8259,ICW3.
        CALL  	IO_delay
        MOV   	AL,001H
        OUT   	021H,AL    	; 主8259,ICW4.
        CALL  	IO_delay
        OUT   	0A1H,AL    	; 从8259,ICW4.
        CALL  	IO_delay
        MOV   	AL,11111100B   	; 仅仅开启定时器、键盘中断
        OUT    	021H,AL        	; 主8259,OCW1.
        CALL  	IO_delay
        MOV 	AL,11111111B   	; 屏蔽从8259所有中断
        OUT    	0A1H,AL        	; 从8259,OCW1.
        CALL   	IO_delay
        RET
SetRealmode8259A:
        MOV   	AL,011H
        OUT  	020H,AL    	; 主8259,ICW1.
        CALL 	IO_delay
        OUT   	0A0H,AL    	; 从8259,ICW1.
        CALL   	IO_delay
        MOV  	AL,08H     	; IRQ0 对应中断向量 0x20
        OUT  	021H,AL    	; 主8259,ICW2.
        CALL  	IO_delay
        MOV   	AL,70H     	; IRQ8 对应中断向量0x28
        OUT   	0A1H,AL    	; 从8259,ICW2.
        CALL  	IO_delay
        MOV    	AL,004H    	; IR2 对应从8259
        OUT   	021H,AL    	; 主8259,ICW3.
        CALL  	IO_delay
        MOV  	AL,002H    	; 对应主8259的IR2
        OUT    	0A1H,AL    	; 从8259,ICW3.
        CALL  	IO_delay
        MOV  	AL,001H
        OUT   	021H,AL    	; 主8259,ICW4.
        CALL  	IO_delay
        OUT  	0A1H,AL    	; 从8259,ICW4.
        CALL   	IO_delay
        MOV    	AL,_SavedIMREG_M    	; 恢复中断屏蔽寄存器(IMREG)的值
        OUT    	021H,AL      	; 
        CALL  	IO_delay
        MOV   	AL,_SavedIMREG_S    	; 恢复中断屏蔽寄存器(IMREG)的值
        OUT   	0A1H,AL      	; 
        CALL  	IO_delay
        RET
IO_delay:
        NOP
        NOP
        NOP
        NOP
        RET
Real:         	;现在又回到实模式
        DisableA20
        MOV    	AX,DSEG
        MOV  	DS,AX
        MOV   	SS,_SavedSP
        MOV   	SP,_SavedSS
        LIDT  	QWORD PTR _SavedIDTR
        STI
        MOV   	AX,4C00H
        INT     	21H
START   ENDP
CSEG    ENDS                   		;代码段定义结束
CSEG32  SEGMENT USE32
        ASSUME CS:CSEG32,DS:PSEG
IRQ0Handler:
        INC    	BYTE PTR GS:[((80 * 0 + 70) * 2)]	; 第0行,第70列
        MOV   	AL,20H
        OUT    	20H,AL        	 	; 发送EOI到主8259
        IRETD
IRQ1Handler:
        IN     	AL,60H
        MOV  	inkey,AL
        INC   	BYTE PTR GS:[((80 * 1 + 70) * 2)]	; 第1行,第70列
        MOV  	AL,20H
        OUT    	20H,AL                       	; 发送EOI到主8259
        IRETD
UserIntHandler:
        MOV   	AH,0CH                     	; 0000黑底 1100红字
        MOV   	AL,'I'
        MOV    	GS:[((80 * 2 + 70) * 2)],AX       	; 第2行,第70列
        IRETD
SpuriousHandler:
        IRETD
CSEG32  ENDS
        END     START