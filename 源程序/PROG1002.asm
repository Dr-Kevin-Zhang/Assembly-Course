;PROG1002
.386P
;�洢���������ṹ���Ͷ���
Desc      	STRUC
LimitL     	DW     	0 					;�ν���(BIT0 15)
BaseL     	DW    	0 					;�λ���ַ(BIT0 15)
BaseM    	DB     	0 					;�λ���ַ(BIT16 23)
Attributes   	DB     	0 					;������
LimitH    	DB     	0 					;�ν���(BIT16 19)(�������Եĸ�4λ) 
BaseH    	DB     	0 					;�λ���ַ(BIT24 31)
Desc      	ENDS
;α�������ṹ���Ͷ���(����װ��ȫ�ֻ��ж���������Ĵ���)
PDesc     	STRUC
Limit      	DW      	0 					;16λ����
Base      	DD      	0 					;32λ����ַ
PDesc      	ENDS
;�洢������������ֵ˵��
ATDR     	EQU    	90H 					;���ڵ�ֻ�����ݶ�����ֵ
ATDW     	EQU    	92H 					;���ڵĿɶ�д���ݶ�����ֵ
ATDWA   	EQU    	93H 					;���ڵ��ѷ��ʿɶ�д���ݶ�����ֵ
ATCE    	EQU    	98H 					;���ڵ�ִֻ�д��������ֵ
ATCER   	EQU   	9AH 					;���ڵĿ�ִ�пɶ����������ֵ
ATCCO    	EQU    	9CH 					;���ڵ�ִֻ��һ�´��������ֵ
ATCCOR  	EQU    	9EH 					;���ڵĿ�ִ�пɶ�һ�´��������ֵ
DSEG     	SEGMENT	USE16            	;16λ���ݶ�
GDT     	LABEL  	BYTE              	;ȫ����������
DUMMY  	Desc   	<>               	;��������
Code      	Desc   	<0FFFFH,,,ATCE,,> 	;�����������
DataD    	Desc    	<0FFFFH,0,,ATDW,,>	;Դ���ݶ�������
DataE     	Desc    	<0FFFFH,,,ATDW,,> 	;Ŀ�����ݶ�������
GDTLen   	=       	$-GDT            	;ȫ������������
VGDTR  	PDesc   	<GDTLen 1,>      	;α������
Code_Sel  	=       	Code GDT         	;�����ѡ���
DataD_Sel 	=       	DataD GDT         	;Դ���ݶ�ѡ���
DataE_Sel  	=       	DataE GDT         	;Ŀ�����ݶ�ѡ���
BufLen    	=       	64                	;�������ֽڳ���
Buffer     	DB      	BufLen DUP(55H)   	;������
DSEG     	ENDS                      		;���ݶζ������
ESEG    	SEGMENT	USE16             	;16λ���ݶ�
Buffer2           DB     	BufLen DUP(0)     		;������
ESEG            ENDS                      		;���ݶζ������
SSEG            SEGMENT PARA STACK        	;16λ��ջ��
                 DW     	256 DUP (0)
SSEG            ENDS                  			;��ջ�ζ������
;��A20��ַ��
EnableA20        MACRO
                 PUSH   	AX
                 IN     	AL,92H
                 OR     	AL,00000010B
                 OUT    	92H,AL
                 POP    	AX
                 ENDM
;�ر�A20��ַ��
DisableA20       MACRO
                 PUSH   	AX
                 IN      	AL,92H
                 AND    	AL,11111101B
                 OUT    	92H,AL
                 POP    	AX
                 ENDM
;�ַ���ʾ��ָ��Ķ���
EchoCh          MACRO  	ascii
                 MOV    	AH,2
                 MOV    	DL,ascii
                 INT     	21H
                 ENDM
;16λƫ�ƵĶμ�ֱ��ת��ָ��ĺ궨��(��16λ�������ʹ��)
JUMP16          MACRO 	Selector,OFFSET
                 DB      	OEAH   				;������
                 DW     	OFFSET 				;16λƫ����
                 DW     	SELECTOR 				;��ֵ���ѡ���
                 ENDM
CSEG            SEGMENT	USE16     				;16λ�����
                 ASSUME 	CS:CSEG,DS:DSEG
START           PROC
                 MOV    	AX,DSEG
                 MOV    	DS,AX
                ;׼��Ҫ���ص�GDTR��α������
                MOV    	BX,16
                MUL    	BX
                ADD    	AX,OFFSET GDT      	;���㲢���û���ַ
                ADC    	DX,0               		;�������ڶ���ʱ���ú�
                MOV    	WORD PTR VGDTR.Base,AX
                MOV    	WORD PTR VGDTR.Base+2,DX
                ;���ô����������
                MOV    	AX,CS
                MUL    	BX
                MOV    	WORD PTR Code.BaseL,AX
                MOV    	BYTE PTR Code.BaseM,DL 
                MOV    	BYTE PTR Code.BaseH,DH
                ;����Դ���ݶ�������
                MOV    	AX,DS
                MUL    	BX
                MOV    	WORD PTR DataD.BaseL,AX
                MOV    	BYTE PTR DataD.BaseM,DL
                MOV    	BYTE PTR DataD.BaseH,DH
                ;����Ŀ�����ݶ�������
                MOV    	AX,ESEG
                MUL    	BX
                MOV    	WORD PTR DataE.BaseL,AX
                MOV    	BYTE PTR DataE.BaseM,DL
                MOV    	BYTE PTR DataE.BaseH,DH
                ;����GDTR
                LGDT   	QWORD PTR VGDTR
                CLI                          		;���ж�
                EnableA20                    		;�򿪵�ַ��A20
                ;�л���������ʽ
                MOV    	EAX,CR0
                OR     	EAX,1
                MOV    	CR0,EAX
                ;��ָ��Ԥȡ����,���������뱣����ʽ
                JUMP16 	Code_Sel,<OFFSET Virtual>
Virtual:        
                ;���ڿ�ʼ�ڱ�����ʽ������
                MOV    	AX,DataD_Sel
                MOV    	DS,AX               	;����Դ���ݶ�������
                MOV    	AX,DataE_Sel
                MOV    	ES,AX              		;����Ŀ�����ݶ�������
                CLD
                LEA    	ESI,Buffer
                LEA    	EDI,Buffer2          	;����ָ���ֵ
                MOV    	ECX,BufLen/4         	;���ô��ʹ���
                REPZ   	movsd                	;����
                ;�л���ʵģʽ
                MOV    	EAX,CR0
                AND    	AL,11111110B
                MOV    	CR0,EAX
                ;��ָ��Ԥȡ����,����ʵģʽ
                JUMP16 	<SEG Real>,<OFFSET Real>
Real:           
                ;�����ֻص�ʵģʽ
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
CSEG           ENDS                         	;����ν���
                END    	START