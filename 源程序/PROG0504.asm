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
       	JZ      	ISLEAP 		; ��400������������
       	MOV  		EAX, YEAR
       	XOR    		EDX, EDX
       	DIV  		N100
       	CMP   		EDX, 0 
       	JZ    		NOTLEAP 		; ��100������������400��������ƽ��
       	MOV   		EAX, YEAR
       	XOR  		EDX, EDX
       	DIV    		N4
       	CMP    	EDX, 0
       	JZ     		ISLEAP    		; ��4������������100������������
NOTLEAP:                         		; ����4��������ƽ��
       	MOV   		LEAP, 0
ISLEAP: