;����6.9
STACKSG SEGMENT
	DW 128 DUP(?)
STACKSG ENDS

DATA    SEGMENT
N_VAL   DW	3	;����Nֵ
RESULT  DW	?	;���
DATA    ENDS

CODE  SEGMENT
      ASSUME CS:CODE,DS:DATA,SS:STACKSG

FRAME	STRUC			;����֡�ṹ
	SAV_BP	    DW	?	;����BPֵ
	SAV_CS_IP   DW  2 DUP(?);���淵�ص�ַ
	N	    DW	?	;��ǰNֵ
	RESULT_ADDR DW	?	;�����ַ
FRAME	ENDS

MAIN    PROC	FAR
	MOV	AX,DATA
	MOV	DS,AX
	LEA	BX,RESULT
	PUSH	BX	   	;�����ַ��ջ
	PUSH	N_VAL   	;Nֵ��ջ
	CALL	FAR PTR	FACT	;���õݹ��ӳ���
				 
R1:	MOV	AX,4C00H
        INT	21H
MAIN    ENDP

FACT	PROC	FAR		;N���ݹ��ӳ���
	PUSH	BP			;����BPֵ
	MOV 	BP,SP		;BPָ��֡����ַ
	PUSH	BX
	PUSH	AX
	MOV	BX,[BP].RESULT_ADDR
	MOV	AX,[BP].N	;ȡ֡��Nֵ
	CMP	AX,0
	JE	DONE  		;N��0ʱ�˳��ӳ���Ƕ��
	PUSH	BX		;Ϊ��һ�ε���ѹ������ַ
	DEC	 AX
	PUSH	AX		;Ϊ��һ�ε���ѹ��(N��1)ֵ
	CALL	FAR PTR FACT
R2:	MOV	BX,[BP].RESULT_ADDR
	MOV	AX,[BX]   	;ȡ�м���(N��1)!
	MUL	[BP].N    	;N*��N��1��!
	JMP	SHORT RETURN
DONE:   MOV	AX,1      	;0!��1
RETURN: MOV	[BX],AX   	;���м���
	POP     AX
	POP     BX
	POP     BP
	RET     4
FACT    ENDP
CODE    ENDS
        END     MAIN
