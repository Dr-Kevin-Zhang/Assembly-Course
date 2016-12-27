;PROG0610.ASM
.386
.model flat,stdcall
includelib  	msvcrt.lib
printf      	PROTO C:dword,:vararg
scanf     	PROTO C:dword,:vararg
.data
szMsg     	byte 	'f is called. buf=%s', 0ah, 0
szFormat   	byte 	'%s', 0
buf        	byte 	40 dup (0)
fn        	dword	offset f
.code           
f        	proc
           	invoke  	printf, offset szMsg, offset buf
           	ret
f          	endp
start:
          	invoke 	scanf, offset szFormat, offset buf

          	call    	dword ptr [fn]
invalidarg:                
           	ret
end        	start