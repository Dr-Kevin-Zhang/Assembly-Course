;PROG0609.ASM
.386
.model flat,stdcall
includelib         msvcrt.lib
printf            PROTO C:dword,:vararg
.data
szOut            byte  	'n=%d (n!)=%d', 0AH, 0
.code           
factorial   	proc 	C  n:dword
          	cmp   	n, 1
          	jbe   	exitrecurse
           	mov  	ebx, n           	; EBX=n
           	dec   	ebx            	; EBX=n?1
            	invoke	factorial, ebx    	; EAX=(n?1)!
          	imul   	n              	; EAX=EAX * n
          	ret                     	; =(n?1)! * n=n!
exitrecurse:            
          	mov  	eax, 1             	; n=1ʱ, n!=1
           	ret
factorial   	endp
start  		proc
        	local  	n,f:dword
        	mov  	n, 5
         	invoke  	factorial, n       	; EAX=n!
         	mov  	f, eax
         	invoke  	printf, offset szOut, n, f   
          	ret
start      	endp
end      	start