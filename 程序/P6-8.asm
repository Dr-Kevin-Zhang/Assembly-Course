;����6.8
CR      EQU	0DH
LF      EQU	0AH

STACKSG SEGMENT
	DW 64 DUP('ST')
STACKSG	ENDS

DATA    SEGMENT
PROMPT1 DB	CR,LF,'INPUT NUM1:$'
PROMPT2 DB	CR,LF,'INPUT NUM2:$'         
ASCIN1  DB	5 , ? , 5 DUP(?)
ASCIN2  DB	5 , ? , 5 DUP(?)
BIN1    DW	?	;����1������ֵ
BIN2    DW	?	;����2������ֵ
RSLTHI  DW	0	;32λ�����Ƴ˻��ĸ�16λ
RSLTLO  DW	0	;32λ�����Ƴ˻��ĵ�16λ
ASCOUT0 DB	CR,LF,'RESULT:'
ASC_OUT DB	10 DUP(0),'$'
DATA    ENDS

CODE    SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:STACKSG
MAIN    PROC	FAR
        MOV	AX,DATA
	MOV	DS,AX
	LEA	DX,PROMPT1
	CALL	DISP
	LEA	DX,ASCIN1
	CALL	INPUT		;�������1
	LEA	DX,PROMPT2
	CALL	DISP            
	LEA	DX,ASCIN2
	CALL	INPUT		;�������2
	LEA	SI,ASCIN1+1	;��������1�������ĵ�ַָ��
	CALL	ASC_BIN		;�ѳ���1ת���ɶ�������
	MOV	BIN1,AX		;�����1�Ķ�����ֵ
	LEA	SI,ASCIN2+1	;��������2�������ĵ�ַָ��
	CALL	ASC_BIN		;�ѳ���2ת���ɶ�������
	MOV	BIN2,AX		;�����2�Ķ�����ֵ
	
	MOV	AX,BIN1
	MUL	BIN2		;����1*����2�����Ϊ32λ��������
	MOV	RSLTLO,AX   	;�������ĵ�16λ
	MOV	RSLTHI,DX   	;�������ĸ�16λ
	CALL	BIN_ASC
      ;	����32λ��������ת����ʮ�������ӳ���
	LEA	DX,ASCOUT0
	CALL	DISP	    	;��ʾʮ���Ƴ˻�
	MOV	AX,4C00H
	INT	21H
MAIN	ENDP

DISP    PROC			;��ʾ�ַ����ӳ���
        MOV	AH,9
        INT	21H
        RET
DISP    ENDP

INPUT   PROC			;�����ַ����ӳ���
        MOV     AH,0AH
        INT     21H
        RET
INPUT   ENDP

ASC_BIN PROC
	XOR	AX,AX
	MOV	CL,[SI]
	XOR	CH,CH           
	INC	SI
	JCXZ	M2
M1:     MOV     BX,10
	MUL    	BX              
	MOV    	BL,[SI]	;�õ�һλʮ��������ASCII��
	INC    	SI	;�޸ĵ�ַָ��
	AND    	BX,0FH
	;��ʮ��������ASCII��ת����ʮ������
	ADD    	AX,BX
	LOOP    M1              
M2:     RET
ASC_BIN ENDP

BIN_ASC PROC
			;32λ��������ת����ʮ�������ӳ���
        LEA     DI,ASC_OUT+9
			;DIָ��ʮ���������ĸ�λ
        MOV     BX,10
C0:     MOV     DX,0
        MOV     AX,RSLTHI
        CMP     AX,0
        JE      C1
	DIV    	BX
        MOV     RSLTHI,AX
	MOV     AX,RSLTLO
        DIV     BX
        MOV     RSLTLO,AX
        OR      DL,30H
        MOV     [DI],DL
        DEC     DI
        JMP     SHORT  C0
C1:     MOV     AX,RSLTLO
C2:     CMP     AX,0
        JZ      C3
        MOV     DX,0
	DIV    	BX
	OR     	DL,30H
	MOV    	[DI],DL
	DEC    	DI
	JMP    	SHORT  C2
C3:     RET
BIN_ASC ENDP
CODE    ENDS
        END     	MAIN
