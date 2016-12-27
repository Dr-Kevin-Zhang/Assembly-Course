;����6.5
STACKSG	SEGMENT
	DW 32 DUP('S')
STACKSG ENDS

DATA    SEGMENT
ARY     DW	1,2,3,4,5,6,7,8,9,10	;����1
COUNT   DW	($-ARY)/2	;����1��Ԫ�ظ���
SUM     DW	?		;����1�ĺ͵�ַ
NUM     DW	10,20,30,40,50	;����2
CT      DW	($-NUM)/2	;����2��Ԫ�ظ���
TOTAL   DW	?		;����2�ĺ͵�ַ
TABLE   DW	3 DUP(?)	;��ַ��
DATA    ENDS

CODE1	SEGMENT
MAIN	PROC	FAR
	ASSUME	CS:CODE1,DS:DATA,SS:STACKSG
	PUSH	DS
	XOR	AX,AX
	PUSH	AX
	MOV	AX,DATA
	MOV	DS,AX	
		
	MOV	TABLE,OFFSET ARY;��������1�ĵ�ַ��	
	MOV	TABLE+2,OFFSET COUNT
	MOV	TABLE+4,OFFSET SUM
	LEA	BX,TABLE	;���ݵ�ַ���׵�ַ
        CALL	FAR PTR ARY_SUM	
        
	MOV	TABLE,OFFSET NUM;��������2�ĵ�ַ��
	MOV	TABLE+2,OFFSET CT
	MOV	TABLE+4,OFFSET TOTAL
	LEA	BX,TABLE	;���ݵ�ַ����׵�ַ
	CALL	FAR PTR ARY_SUM	;�μ���õ�����������ӳ���
		
	RET
MAIN    ENDP
CODE1   ENDS

CODE2   SEGMENT
        ASSUME	CS:CODE2
ARY_SUM	PROC	FAR		;��������ӳ���
	PUSH	AX		;����Ĵ���
	PUSH	CX
	PUSH	SI
	PUSH	DI
                  
	MOV	SI,[BX]		;ȡ������ʼ��ַ
	MOV	DI,[BX+2]	;ȡԪ�ظ�����ַ
	MOV	CX,[DI]		;ȡԪ�ظ���
	MOV	DI,[BX+4]	;ȡ�����ַ
	XOR	AX,AX		;��0�ۼ���
NEXT:   ADD	AX,[SI]		;�ۼӺ�
	ADD	SI,TYPE ARY	;�޸ĵ�ַָ��
	LOOP	NEXT
	MOV	[DI],AX		;���

	POP	DI		;�ָ��Ĵ���
	POP	SI
	POP	CX
	POP	AX
	RET 
ARY_SUM ENDP
CODE2   ENDS
        END MAIN
