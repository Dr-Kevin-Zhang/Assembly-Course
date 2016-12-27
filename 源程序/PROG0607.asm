;PROG0607.ASM
.386
.model flat,stdcall
includelib       msvcrt.lib
printf           PROTO C :dword,:vararg
.data
szMsgOut        byte 		'%d?%d=%d', 0ah, 0
.code
SubProc1   	proc   	C  a:dword, b:dword 			; 使用C规则
          	mov 		eax, a               		; 取出第1个参数
            	sub  		eax, b               		; 取出第2个参数
          	ret                             		; 返回值=a?b
SubProc1   	endp
SubProc2   	proc    	stdcall a:dword, b:dword		; 使用stdcall规则
           	mov     	eax, a                		; 取出第1个参数
          	sub     	eax, b              			; 取出第2个参数
           	ret                           		; 返回值=a?b
SubProc2  	endp
start:
          	invoke  	SubProc1, 20, 10
           	invoke  	printf, offset szMsgOut, 20, 10, eax
                
           	invoke  	SubProc2, 200, 100
          	invoke  	printf, offset szMsgOut, 200, 100, eax
          	ret
		end		start