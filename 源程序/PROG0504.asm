;PROG0504
YEAR  	DWORD  	2009 
N400   	DWORD  	400
N100   	DWORD  	100
N4     	DWORD  	4
LEAP  	BYTE   	?
       	MOV   		LEAP, 1
       	MOV   		EAX, YEAR
       	XOR   		EDX, EDX
       	DIV    		N400
       	CMP     	EDX, 0
       	JZ      	ISLEAP 		; 被400整除，是闰年
       	MOV  		EAX, YEAR
       	XOR    		EDX, EDX
       	DIV  		N100
       	CMP   		EDX, 0 
       	JZ    		NOTLEAP 		; 被100整除，但不被400整除，是平年
       	MOV   		EAX, YEAR
       	XOR  		EDX, EDX
       	DIV    		N4
       	CMP    	EDX, 0
       	JZ     		ISLEAP    		; 被4整除，但不被100整除，是闰年
NOTLEAP:                         		; 不被4整除，是平年
       	MOV   		LEAP, 0
ISLEAP: