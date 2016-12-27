;PROG0905
PrintByte	PROC
           	MOV	DX, 378H
           	OUT   	DX, AL
               	INC	DX
PrinterIsBusy:          
               	IN     	AL, DX
	TEST   	AL, 80H
               	JZ     	PrinterIsBusy
                
              	MOV    	AL, 00001101B
               	INC    	DX
               	OUT    	DX, AL
             	MOV    	AL, 00001100B
	OUT    	DX, AL
               	RET
PrintByte      	ENDP