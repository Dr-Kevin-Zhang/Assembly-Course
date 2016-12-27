;PROG0606.ASM
.386
.model flat,stdcall
.data
.code
SubProc1        proc                    	; 使用堆栈传递参数
                push 	ebp
                mov  	ebp,esp
                mov  	eax,dword ptr [ebp+8] 	; 取出第1个参数
                sub     eax,dword ptr [ebp+12]	; 取出第2个参数
                pop     ebp                     	 
                ret                             	
SubProc1        endp
SubProc2        proc                            	; 使用堆栈传递参数
                push    ebp
                mov     ebp,esp
                mov    	eax,dword ptr [ebp+8]	; 取出第1个参数
                sub     eax,dword ptr [ebp+12]	; 取出第2个参数
                pop     ebp                     	 
                ret    	8                       	; 平衡主程序的堆栈
SubProc2        endp
start:          
                push    10                      	; 第2个参数入栈
                push    20                      	; 第1个参数入栈
                call    SubProc1                	; 调用子程序
                add     esp, 8
                push    100                     	; 第2个参数入栈
                push    200                     	; 第1个参数入栈
                call    SubProc2                	; 调用子程序
                ret
end             start