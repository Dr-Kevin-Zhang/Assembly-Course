;����6.3
STASG	SEGMENT
	DW 32 DUP(?)
STASG   ENDS

CODE   	SEGMENT
	ASSUME	CS:CODE,SS:STASG
MAIN   	PROC	FAR
	MOV	BX,8192
	CALL	TERN    
	MOV	AX,4C00H
        INT	21H
MAIN    ENDP

TERN    PROC		;����ʮ����ʾ��
        MOV	CX,10000
	CALL	DEC_DIV	;ת����λ��
        MOV	CX,1000
	CALL	DEC_DIV	;ת��ǧλ��
        MOV	CX,100
	CALL	DEC_DIV	;ת����λ��
        MOV	CX,10
	CALL	DEC_DIV	;ת��ʮλ��
        MOV	CX,1
	CALL	DEC_DIV	;ת����λ��
	RET
TERN  	ENDP

DEC_DIV	PROC		;CX��Ϊʮ���Ƶ�λȨ
	MOV	AX,BX
	MOV	DX,0
        DIV	CX	;��Ϊת�����һλʮ������
	MOV	BX,DX	;AXΪ�̣�DXΪ����
	MOV	DL,AL
        ADD	DL,30H	;ת����ASCII��
        MOV	AH,2	;��ʾ
	INT	21H
    	RET
DEC_DIV	ENDP

CODE    	ENDS
     		END 	MAIN