;PROG0404
WWidth=40			;���ڿ��
WLeftTopLine=10		;���Ͻ��к�
WLeftTopRow=20		;���Ͻ��к�
WRightBottomLine=20		;���½��к�
WRightBottomRow=WLeftTopRow+WWidth-1	;���½��к�
Collor=70H			;��ɫ������ɫǰ��
CR=0DH			;�س�
LF=0AH			;����
STACKSG	SEGMENT STACK 'S'
	DW 64 DUP('ST')
STACKSG	ENDS
DATA	SEGMENT
STRING	DB 'This is a example to call interrupt 10H.'	;��ʾ���ַ���
CT	EQU $-STRING				;����
DATA	ENDS
CODE	SEGMENT
	ASSUME CS:CODE,DS:DATA, ES:DATA, SS:STACKSG
MAIN	PROC	FAR
	MOV	AX,DATA
	MOV	DS,AX
	MOV	ES,AX	;ES��DSָ��ͬһ����
	MOV	AH,0	;����ʾģʽΪ80��25��ɫ�ı���ʽ
	MOV	AL,3
	INT	10H
	MOV	AH,6	;����
	MOV	AL,0
	MOV	BH,1FH
	MOV	CX,0
	MOV	DX,184FH
	INT	10H
	MOV	AH,6	;�����ڣ�������Ϊ��ɫ������ɫǰ��
	MOV	AL,0
	MOV	BH,Collor
	MOV	CH,WLeftTopLine
	MOV	CL,WLeftTopRow
	MOV	DH,WRightBottomLine
	MOV	DL,WRightBottomRow
	INT	10H
	MOV	AH,2	;���ù�굽�������½�
	MOV	BH,0
	MOV	DH,WRightBottomLine
	MOV	DL,WLeftTopRow
	INT	10H
	MOV	AH,9	;�ڵ�ǰ���λ����ʾһ���ڵ׻�*
	MOV	AL,'*'
	MOV	BH,0
	MOV	BL,0EH
	MOV	CX,1
	INT	10H
	MOV	AH,0EH	;��ʾ�س�
	MOV	AL,CR
	INT	10H
	MOV	AH,0EH	;��ʾ����
	MOV	AL,LF
	INT	10H
	MOV	AH,3	;�����λ��
	MOV	BH,0
	INT	10H	;���ع��ĵ�ǰ��λ����DH��
	CMP	DH,WRightBottomLine+1	;���λ�ڴ��ڵ��е���һ�У�
	JNE	L1	;��������ת
	MOV	AH,6	;�ǣ������������Ͼ�һ��
	MOV	AL,1
	MOV	BH,Collor
	MOV	CH,WLeftTopLine
	MOV	CL,WLeftTopRow
	MOV	DH,WRightBottomLine
	MOV	DL,WRightBottomRow
	INT	10H
	MOV	AH,2	;������õ����ڵ����½�
	MOV	BH,0
	MOV	DH,WRightBottomLine
	MOV	DL,WLeftTopRow
	INT	10H
L1:	MOV	AH,9
	MOV	AL,STRING	;��ʾSTRING�����еĵ�һ���ַ�T
	MOV	BH,0
	MOV	BL,4FH	;��װ���
	MOV	CX,1
	INT	10H
	MOV	AH,0	;�ȴ��������
	INT	16H
	MOV	AH,13H	;��ʾSTRING�������ַ�h��ʼ�Ĵ�
	MOV	AL,01	;�������ƶ�
	MOV	BH,0
	MOV	BL,COLLOR	;�����ֽ�
	MOV	CX,CT
	MOV	DH,WRightBottomLine
	MOV	DL,WLeftTopRow+1
	LEA	BP,STRING+1
	INT	10H
	MOV	AH,0	;�ȴ��������
	INT	16H
	MOV	AX,4C00H
	INT	21H
MAIN	ENDP
CODE	ENDS
	END	MAIN