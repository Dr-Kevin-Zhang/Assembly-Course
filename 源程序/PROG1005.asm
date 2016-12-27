;PROG1005
.386P
;�洢���������ṹ���Ͷ���
Desc      	STRUC
LimitL      	DW 	0 	;�ν���(BIT0-15)
BaseL       	DW    	0	;�λ���ַ(BIT0-15)
BaseM  	DB      	0	;�λ���ַ(BIT16-23)
Attrs   	DB     	0 	;������
LimitH  	DB      	0 	;�ν���(BIT16-19)(�������Եĸ�4λ)
BaseH  	DB 	0 	;�λ���ַ(BIT24-31)
Desc   	ENDS
;α�������ṹ���Ͷ���(����װ��ȫ�ֻ��ж���������Ĵ���)
PDesc  	STRUC
Limit  	DW     	0 	;16λ����
Base    	DD  	0 	;32λ����ַ
PDesc   	ENDS
;���������ṹ���Ͷ���
Gate    	STRUC
OffsetL 	DW      	0	;32λƫ�Ƶĵ�16λ
Selector	DW      	0	;ѡ���
DCount  	DB      	0 	;˫�ּ���
GType    	DB     	0 	;����
OffsetH  	DW  	0 	;32λƫ�Ƶĸ�16λ
Gate    	ENDS
;�洢������������ֵ˵��
ATDW    	EQU     	92H 	;���ڵĿɶ�д���ݶ�����ֵ
ATDWA    	EQU     	93H 	;���ڵ��ѷ��ʿɶ�д���ݶ�����ֵ
ATCER 	EQU   	9aH	;���ڵĿ�ִ�пɶ����������ֵ
DSEG   	SEGMENT USE16   	;16λ���ݶ�
GDT    	LABEL  	BYTE    	;ȫ����������
DUMMY    	Desc   	<>    	;��������
Code     	Desc <0FFFFH,,,ATCER,,>	;�����������
DataV   	Desc <0FFFFH,,,ATDW,,> 	;���ݶ�����������Ļ��������
DataP    	Desc <0FFFFH,,,ATDWA,,> 	;���ݶ�������
Code32  	Desc <0FFFFH,,,ATCER,40H,>	;�����������
GDTLen  	 =       $ GDT        	;ȫ������������
VGDTR    PDesc   <GDTLen 1,>         	;α������
; IDT
ALIGN 32
IDT            LABEL    BYTE
IDT_00_1F Gate 32	DUP  (<OFFSET SpuriousHandler,Code32_Sel,0,8EH,0>)
IDT_20    Gate 1 	DUP  (<OFFSET IRQ0Handler,Code32_Sel,0,8EH,0>)
IDT_21    Gate 1	DUP  (<OFFSET IRQ1Handler,Code32_Sel,0,8EH,0>)
IDT_22_7F Gate 94	DUP  (<OFFSET SpuriousHandler,Code32_Sel,0,8EH,0>)
IDT_80    Gate 1	DUP  (<OFFSET UserIntHandler,Code32_Sel,0,8EH,0>)
IDTLen          	=       	$-IDT         	;�ж�����������
VIDTR           	PDesc   	<IDTLen 1,>   	;α������
_SavedSP        	DW      	0
_SavedSS        	DW      	0
_SavedIDTR      	DD      	0             	; ���ڱ��� IDTR
               	DD      	0
                
DSEG          	ENDS                  	;���ݶζ������
PSEG            	SEGMENT PARA STACK    	;����ģʽ��ʹ�õ����ݶ�
                	DB      	512 DUP (0)
TopOfStack      	LABEL  	BYTE
inkey           	DB      	0
_tmp            	DB      	0                
_SavedIMREG_M	DB      	0             	; �ж����μĴ���ֵ (��Ƭ)
_SavedIMREG_S   DB      	0             	; �ж����μĴ���ֵ (��Ƭ)
PSEG           	ENDS
SSEG            	SEGMENT PARA STACK    	;16λ��ջ��
                	DB      	512 DUP (0)
SSEG            	ENDS                  	;��ջ�ζ������
Code_Sel        	=       	Code GDT      	;16λ�����ѡ���
DataV_Sel      	=       	DataV GDT     	;��Ļ���������ݶ�ѡ���
DataP_Sel       	=       	DataP GDT     	;PSEG���ݶ�ѡ���
Code32_Sel      	=       	Code32 GDT    	;32λ����ζ�ѡ���
;��A20��ַ��
EnableA20     	MACRO
        PUSH    	AX
        IN      	AL,92H
        OR      	AL,00000010B
        OUT     	92H,AL
        POP     	AX
        ENDM
;�ر�A20��ַ��
DisableA20      	MACRO
        PUSH    	AX
        IN      	AL,92H
        AND     	AL,11111101B
        OUT     	92H,AL
        POP     	AX
        ENDM
;16λƫ�ƵĶμ�ֱ��ת��ָ��ĺ궨��(��16λ�������ʹ��)
JUMP16  MACRO	Selector,OFFSET
         DB     	0EAH     		;������
         DW     	OFFSET   		;16λƫ����
         DW     	SELECTOR 	;��ֵ���ѡ���
         ENDM
CSEG    SEGMENT USE16         	;16λ�����
         ASSUME	CS:CSEG,DS:DSEG
START   PROC
         MOV   	AX,DSEG
         MOV  	DS,AX
         MOV  	_SavedSP,SS
         MOV 	_SavedSS,SP
         ;׼��Ҫ���ص�GDTR��α������
         MOV   	BX,16
         MUL  	BX
         ADD   	AX,OFFSET GDT           	;���㲢���û���ַ
         ADC   	DX,0                    	;�������ڶ���ʱ���ú�
         MOV  	WORD PTR VGDTR.Base,AX
         MOV  	WORD PTR VGDTR.Base+2,DX
         ;׼��Ҫ���ص�IDTR��α������
         MOV   	AX,SEG IDT
         MOV   	BX,16
         MUL  	BX
         ADD   	AX,OFFSET IDT           	;���㲢���û���ַ
         ADC  	DX,0                    	;�������ڶ���ʱ���ú�
         MOV   	WORD PTR VIDTR.Base,AX
         MOV   	WORD PTR VIDTR.Base+2,DX
         ;���ô����������
         MOV  	AX,CS
        MUL     	BX
        MOV    	WORD PTR Code.BaseL,AX
        MOV   	BYTE PTR Code.BaseM,DL
        MOV 	BYTE PTR Code.BaseH,DH
        ;���ô������������32λ����Σ�
        MOV 	AX,SEG SpuriousHandler
        MUL   	BX
        MOV   	WORD PTR Code32.BaseL,AX
        MOV  	BYTE PTR Code32.BaseM,DL
        MOV  	BYTE PTR Code32.BaseH,DH
        ;�������ݶ�����������Ļ��ʾ��������
        MOV 	AX,8000H
        MOV  	DX,000BH
        MOV  	WORD PTR DataV.BaseL,AX
        MOV  	BYTE PTR DataV.BaseM,DL
        MOV  	BYTE PTR DataV.BaseH,DH
        ;�������ݶ�������������ģʽ��ʹ�õ����ݶΣ�
        MOV  	AX,PSEG
        MUL	BX           	;���㲢�������ݶλ�ַ
        MOV 	WORD PTR DataP.BaseL,AX
        MOV 	BYTE PTR DataP.BaseM,DL
        MOV 	BYTE PTR DataP.BaseH,DH
        ; ���� IDTR
        SIDT	QWORD PTR _SavedIDTR
        ;����GDTR
        LGDT	QWORD PTR VGDTR
        CLI                    	;���ж�
        EnableA20              	;�򿪵�ַ��A20
        LIDT    	QWORD PTR VIDTR
        ;�л���������ʽ
        MOV   	EAX,CR0
        OR      	EAX,1
        MOV    	CR0,EAX
        ;��ָ��Ԥȡ����,���������뱣��ģʽ
        JUMP16  Code_Sel,<OFFSET Virtual>
ALIGN 32
Virtual:        			;���ڿ�ʼ�ڱ���ģʽ������
        MOV 	AX,DataV_Sel
        MOV   	GS,AX          	;GSָ����Ļ��ʾ������
        MOV     AX,DataP_Sel
        MOV     DS,AX          	;DSָ��PSEG
        MOV     SS,AX          	;SSָ��PSEG
        MOV     SP,OFFSET TopOfStack
      	; �����ж����μĴ���(IMREG)ֵ
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
        ;�л���ʵģʽ
        MOV   	EAX,CR0
        AND  	AL,11111110B
        MOV   	CR0,EAX
        ;��ָ��Ԥȡ����,����ʵģʽ
        JUMP16  <SEG Real>,<OFFSET Real>
Init8259A:
        MOV   	AL,011H
        OUT     	020H,AL    	; ��8259,ICW1.
        CALL   	IO_delay
        OUT   	0A0H,AL   	; ��8259,ICW1.
        CALL  	IO_delay
        MOV  	AL,020H    	; IRQ0 ��Ӧ�ж����� 0x20
        OUT   	021H,AL    	; ��8259,ICW2.
        CALL 	IO_delay
        MOV   	AL,028H    	; IRQ8 ��Ӧ�ж����� 0x28
        OUT  	0A1H,AL    	; ��8259,ICW2.
        CALL	IO_delay
        MOV  	AL,004H   		; IR2 ��Ӧ��8259
        OUT   	021H,AL    	; ��8259,ICW3.
        CALL   	IO_delay
        MOV    	AL,002H    	; ��Ӧ��8259�� IR2
        OUT    	0A1H,AL    	; ��8259,ICW3.
        CALL  	IO_delay
        MOV   	AL,001H
        OUT   	021H,AL    	; ��8259,ICW4.
        CALL  	IO_delay
        OUT   	0A1H,AL    	; ��8259,ICW4.
        CALL  	IO_delay
        MOV   	AL,11111100B   	; ����������ʱ���������ж�
        OUT    	021H,AL        	; ��8259,OCW1.
        CALL  	IO_delay
        MOV 	AL,11111111B   	; ���δ�8259�����ж�
        OUT    	0A1H,AL        	; ��8259,OCW1.
        CALL   	IO_delay
        RET
SetRealmode8259A:
        MOV   	AL,011H
        OUT  	020H,AL    	; ��8259,ICW1.
        CALL 	IO_delay
        OUT   	0A0H,AL    	; ��8259,ICW1.
        CALL   	IO_delay
        MOV  	AL,08H     	; IRQ0 ��Ӧ�ж����� 0x20
        OUT  	021H,AL    	; ��8259,ICW2.
        CALL  	IO_delay
        MOV   	AL,70H     	; IRQ8 ��Ӧ�ж�����0x28
        OUT   	0A1H,AL    	; ��8259,ICW2.
        CALL  	IO_delay
        MOV    	AL,004H    	; IR2 ��Ӧ��8259
        OUT   	021H,AL    	; ��8259,ICW3.
        CALL  	IO_delay
        MOV  	AL,002H    	; ��Ӧ��8259��IR2
        OUT    	0A1H,AL    	; ��8259,ICW3.
        CALL  	IO_delay
        MOV  	AL,001H
        OUT   	021H,AL    	; ��8259,ICW4.
        CALL  	IO_delay
        OUT  	0A1H,AL    	; ��8259,ICW4.
        CALL   	IO_delay
        MOV    	AL,_SavedIMREG_M    	; �ָ��ж����μĴ���(IMREG)��ֵ
        OUT    	021H,AL      	; 
        CALL  	IO_delay
        MOV   	AL,_SavedIMREG_S    	; �ָ��ж����μĴ���(IMREG)��ֵ
        OUT   	0A1H,AL      	; 
        CALL  	IO_delay
        RET
IO_delay:
        NOP
        NOP
        NOP
        NOP
        RET
Real:         	;�����ֻص�ʵģʽ
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
CSEG    ENDS                   		;����ζ������
CSEG32  SEGMENT USE32
        ASSUME CS:CSEG32,DS:PSEG
IRQ0Handler:
        INC    	BYTE PTR GS:[((80 * 0 + 70) * 2)]	; ��0��,��70��
        MOV   	AL,20H
        OUT    	20H,AL        	 	; ����EOI����8259
        IRETD
IRQ1Handler:
        IN     	AL,60H
        MOV  	inkey,AL
        INC   	BYTE PTR GS:[((80 * 1 + 70) * 2)]	; ��1��,��70��
        MOV  	AL,20H
        OUT    	20H,AL                       	; ����EOI����8259
        IRETD
UserIntHandler:
        MOV   	AH,0CH                     	; 0000�ڵ� 1100����
        MOV   	AL,'I'
        MOV    	GS:[((80 * 2 + 70) * 2)],AX       	; ��2��,��70��
        IRETD
SpuriousHandler:
        IRETD
CSEG32  ENDS
        END     START