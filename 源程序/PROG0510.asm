;PROG0510
.386
.model flat,stdcall
option casemap:none
includelib       	msvcrt.lib
printf          	PROTO C :dword,:vararg
.data
Fact   	dword 	?
N   		equ   	6
szFmt  	byte 	'factorial(%d)=%d', 0ah, 0   			;输出结果格式字符串
.code
start:
      	mov   	ecx, N                   			;循环初值
      	mov   	eax, 1                        	;Fact初值
e10:    
      	imul   	eax, ecx             	       	;Fact=Fact*ECX
      	loop  	e10                           	;循环N次
     		mov  	Fact, eax               	     	;保存结果
     		invoke	printf, offset szFmt, N, Fact 			;打印结果
      	ret
		end	start