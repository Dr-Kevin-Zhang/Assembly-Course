;PROG0608.ASM
.386
.model flat, stdcall
includelib 	msvcrt.lib
printf      	PROTO c :dword,:vararg
.data
r           	dword  10
s           	dword  20
szMsgOut  	byte	'r=%d s=%d', 0ah, 0
.code           
swap      	proc	C  a:ptr dword, b:ptr dword	; 使用堆栈传递参数
		local	temp1,temp2:dword
		mov	eax, a                   
		mov	ecx, [eax]
		mov	temp1, ecx            	; temp1=*a
		mov	ebx, b                  
		mov	edx, [ebx]
		mov	temp2, edx           	; temp2=*b
		mov	ecx, temp2
		mov	eax, a	
		mov	[eax], ecx           	; *a=temp2
		mov	ebx, b                  
		mov	edx, temp1
		mov	[ebx], edx      	; *b=temp1
		ret
swap		endp
start		proc
		invoke	printf, offset szMsgOut, r, s
		invoke	swap, offset r, offset s  
		invoke	printf, offset szMsgOut, r, s
		ret
start		endp
end		start