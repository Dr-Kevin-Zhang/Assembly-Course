;����6.4
STACKSG	SEGMENT
	DW 32 DUP('S')
STACKSG	ENDS

DATA    SEGMENT
ARY     DW	1,2,3,4,5,6,7,8,9,10
COUNT   DW	($-ARY)/2	;����Ԫ�ظ���
ARY2     DW	1,2,3,4,5,6,7,8,9,10,12
COUNT2   DW	($-ARY2)/2	;����Ԫ�ظ���
SUM     DW	?		;����͵ĵ�ַ
DATA    ENDS

CODE1   SEGMENT
MAIN    PROC	FAR
        ASSUME	CS:CODE1,DS:DATA,SS:STACKSG
        PUSH	DS
        XOR	AX,AX
        PUSH	AX
        MOV	AX,DATA
        MOV	DS,AX
        
        CALL	FAR PTR ARY_SUM
        
        RET
MAIN    ENDP
CODE1   ENDS

CODE2   SEGMENT
        ASSUME	CS:CODE2
ARY_SUM PROC	FAR		;��������ӳ���
        PUSH	AX		;����Ĵ���
        PUSH	CX
        PUSH	SI

        LEA	SI,ARY		;ȡ������ʼ��ַ
        MOV	CX,COUNT	;ȡԪ�ظ���
        XOR	AX,AX		;��0�ۼ���
NEXT:   ADD	AX,[SI]		;�ۼӺ�
        ADD	SI,2		;�޸ĵ�ַָ��
        LOOP	NEXT
        MOV	SUM,AX		;���

        POP	SI		;�ָ��Ĵ���
        POP	CX
        POP	AX
        RET 
ARY_SUM ENDP
CODE2   ENDS
        END	MAIN