;PROG0510
.386
.model flat,stdcall
option casemap:none
includelib       	msvcrt.lib
printf          	PROTO C :dword,:vararg
.data
Fact   	dword 	?
N   		equ   	6
szFmt  	byte 	'factorial(%d)=%d', 0ah, 0   			;��������ʽ�ַ���
.code
start:
      	mov   	ecx, N                   			;ѭ����ֵ
      	mov   	eax, 1                        	;Fact��ֵ
e10:    
      	imul   	eax, ecx             	       	;Fact=Fact*ECX
      	loop  	e10                           	;ѭ��N��
     		mov  	Fact, eax               	     	;������
     		invoke	printf, offset szFmt, N, Fact 			;��ӡ���
      	ret
		end	start