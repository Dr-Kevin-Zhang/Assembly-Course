;PROG0807
.386
.model flat
option casemap:none
includelib  	msvcrt.lib
printf      	PROTO C format:ptr sbyte,:vararg
scanf      	PROTO C :dword,:vararg
.data
szInputFmtStr	byte    "%u", 0
Message0   	byte    "Find primes up to: ", 0
Message1    	byte    "Prime numbers between (1бл%d): %d", 0ah, 0
Message2    	byte    "The maximum prime number is : %d", 0ah, 0
limit        	dword  	?     			; find primes up to this limit
guess       	dword 	?              	; the current guess for prime
nums       	dword	0
maxprime    	dword	0
.code
main       	proc 	C
            	invoke	printf, offset Message0
            	invoke  	scanf, offset szInputFmtStr, offset limit
            	mov   	eax, limit
            	cmp    	eax, 5
            	jbe   	skip
                        
            	mov  	nums, 2
         	mov  	eax, 5
            	mov   	guess, eax   		; guess=5;
L10:                               		; while ( guess <= limit )
            	mov 	eax, guess
           	cmp  	eax, limit
           	ja   	L50          		; use ja for unsigned numbers
          	mov 	ebx, 3        		; EBX is factor=3;
L20:
           	cmp 	ebx, guess 
          	jae  	L30          		; EBX > guess, guess is a prime
         	mov  	eax, guess
           	xor   	edx, edx
            	div    	ebx       		; EDX=EDX:EAX % EBX
            	cmp   	edx, 0
            	je     	L40            	; if !(guess % factor != 0)
            	add    	ebx, 2          	; factor += 2;
            	jmp    	L20
L30:
          	push   	guess
         	pop   	maxprime
         	inc    	nums
L40:         
        	add    	guess, 2        	; guess += 2
           	jmp    	L10
L50:
         	invoke  	printf, offset Message1, limit, nums
          	invoke	printf, offset Message2, maxprime
skip:           
         	ret
main        	endp
end