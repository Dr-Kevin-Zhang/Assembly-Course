;PROG0612.ASM
.386
.model flat,stdcall
public     	SubProc               				; 允许其他模块调用SubProc
extrn   	result:dword           				; result位于其他模块中
.data
.code
SubProc   	proc 	stdcall a, b    				; 减法函数, stdcall调用方式
           	mov 	eax, a          				; 参数为a,b
     		sub  	eax, b          				; EAX=a?b
           	mov  	result, eax     				; 减法的结果保存在result中
           	ret   	8               			; 返回a?b
SubProc     	endp
		end