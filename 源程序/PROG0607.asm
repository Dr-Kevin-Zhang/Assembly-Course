;PROG0607.ASM
.386
.model flat,stdcall
includelib       msvcrt.lib
printf           PROTO C :dword,:vararg
.data
szMsgOut        byte 		'%d?%d=%d', 0ah, 0
.code
SubProc1   	proc   	C  a:dword, b:dword 			; ʹ��C����
          	mov 		eax, a               		; ȡ����1������
            	sub  		eax, b               		; ȡ����2������
          	ret                             		; ����ֵ=a?b
SubProc1   	endp
SubProc2   	proc    	stdcall a:dword, b:dword		; ʹ��stdcall����
           	mov     	eax, a                		; ȡ����1������
          	sub     	eax, b              			; ȡ����2������
           	ret                           		; ����ֵ=a?b
SubProc2  	endp
start:
          	invoke  	SubProc1, 20, 10
           	invoke  	printf, offset szMsgOut, 20, 10, eax
                
           	invoke  	SubProc2, 200, 100
          	invoke  	printf, offset szMsgOut, 200, 100, eax
          	ret
		end		start