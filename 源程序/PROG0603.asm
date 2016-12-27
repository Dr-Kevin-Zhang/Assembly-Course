;PROG0603.ASM
.386
.model flat,stdcall
option casemap:none
includelib	msvcrt.lib
printf     	PROTO C	:dword,:vararg
.data
szFmt      	byte  		'%d + %d=%d', 0ah, 0		;输出结果格式字符串
x           	dword		?
y           	dword		?
z           	dword		?
.code
AddProc1    	proc                         		; 使用寄存器作为参数
           	mov  		eax, esi              	; EAX=ESI + EDI
            	add  		eax, edi
            	ret
AddProc1     	endp
AddProc2    	proc                            	; 使用变量作为参数
            	push	eax                	; C=A + B
            	mov 	eax, x
            	add 	eax, y
            	mov	z, eax
          	pop 	eax            		; 恢复EAX的值
            	ret
AddProc2   	endp
start:          
          	mov 	esi, 10 
           	mov	edi, 20            		; 为子程序准备参数
            	call	AddProc1          		; 调用子程序
                                           		; 结果在EAX中
            	mov 	x, 50               	
             	mov 	y, 60               	; 为子程序准备参数
           	call	AddProc2            	; 调用子程序
                                            		; 结果在Z中
           	invoke	printf, offset szFmt, 
                      	esi, edi, eax       		; 显示第1次加法结果
             	invoke 	printf, offset szFmt, 
                        	x, y, z            		; 显示第2次加法结果
          	ret
end        	start