;PROG0511
.386
.model flat,stdcall
option casemap:none
includelib	msvcrt.lib
printf  	PROTO C :dword,:vararg
.data
x  	dword	1,2,3,4,5,6,7,8,9,10
y     	dword	5,4,3,2,1,10,9,8,7,6
Rule	dword	0000000011011100B
z    	dword	10 dup (?)
szFmt	byte	'Z[%d]=%d', 0ah, 0  	;��������ʽ�ַ���
.code
start:
     	mov	ecx,10            	;ѭ������
      	mov	edx,Rule           	;�߼���
	mov	ebx,0
next:
	mov	eax,x[ebx]        	;ȡX�е�һ����
	shr	edx,1              	;�߼�������һλ
	jc	subs               	;��֧�жϲ�ʵ��ת��
	add	eax,y[ebx]        	;������
	jmp	short result
subs:
	sub	eax,y[ebx]     	;������
result: 
	mov	z[ebx],eax      	;����
	add	ebx,4            	;�޸ĵ�ַָ��
	loop	next
	xor	ebx, ebx          	;��ʾ����Ԫ�ص�ֵ
PrintNext:            
	invoke	printf, offset szFmt, ebx, Z[ebx*4] ; ��ʾ
	inc	ebx     	;EBX�±��1
	cmp 	ebx,10  	;�Ƿ���ȫ����ʾ��
	jb 	PrintNext 	;������ʾ
	ret
	end	start