;PROG0612.ASM
.386
.model flat,stdcall
public     	SubProc               				; ��������ģ�����SubProc
extrn   	result:dword           				; resultλ������ģ����
.data
.code
SubProc   	proc 	stdcall a, b    				; ��������, stdcall���÷�ʽ
           	mov 	eax, a          				; ����Ϊa,b
     		sub  	eax, b          				; EAX=a?b
           	mov  	result, eax     				; �����Ľ��������result��
           	ret   	8               			; ����a?b
SubProc     	endp
		end