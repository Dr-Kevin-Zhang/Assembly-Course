;����6.6
STACKSG SEGMENT
	DW 16 DUP(?)
STACKSG ENDS

DATA    SEGMENT
ARY     DW	1,2,3,4,5,6,7,8,9,10
COUNT   DW	($-ARY)/2
SUM     DW	?
DATA    ENDS

CODE1   SEGMENT
MAIN    PROC	FAR
	ASSUME	CS:CODE1,DS:DATA
	PUSH	DS		;��
	XOR	AX,AX
	PUSH	AX		;��
	MOV	AX,DATA
	MOV	DS,AX
	
	LEA	BX,ARY
	PUSH	BX		;��ѹ��������ʼ��ַ
	LEA	BX,COUNT
	PUSH	BX		;��ѹ��Ԫ�ظ�����ַ
	LEA	BX,SUM
	PUSH	BX		;��ѹ��͵�ַ
	CALL	FAR PTR ARY_SUM
				;�ʵ�������ӳ���
	RET			;��
MAIN    ENDP
CODE1   ENDS

CODE2   SEGMENT
        ASSUME CS:CODE2
ARY_SUM PROC	FAR		;��������ӳ���
	PUSH	BP		;�˱���BPֵ
	MOV	BP,SP		;BP�Ƕ�ջ���ݵĵ�ַָ��
	PUSH	AX		;�̱���Ĵ�������
	PUSH	CX		;��
	PUSH	SI		;��
	PUSH	DI		;��
				;MOV	BP,SP
	MOV	SI,[BP+10]	;�õ�������ʼ��ַ
	MOV	DI,[BP+8]	;�õ�Ԫ�ظ�����ַ
	MOV	CX,[DI]		;�õ�Ԫ�ظ���
	MOV	DI,[BP+6]	;�õ��͵�ַ
	XOR	AX,AX
NEXT:   ADD	AX,[SI]		;�ۼ�
	ADD	SI,2		;�޸ĵ�ַָ��
	LOOP	NEXT
	MOV	[DI],AX		;���
	
	POP	DI		;�лָ��Ĵ�������
	POP	SI			;��
	POP	CX		;��	
	POP	AX		;��
	POP	BP		;��
	RET	6		;�շ��ز�����SPָ��
ARY_SUM ENDP
CODE2   ENDS
        END  MAIN

