;PROG0803
SUBX 	MACRO	minuend, subtrahend, difference
	PUSH 	EAX
	MOV    	EAX, minuend
	SUB     	EAX, subtrahend
	MOV     	difference, EAX
	POP      	EAX
	ENDM