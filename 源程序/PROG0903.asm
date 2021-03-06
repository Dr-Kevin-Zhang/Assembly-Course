;PROG0903
SendByte        PROC
              	PUSH  	EAX          	; 要发送的数据压栈
               	MOV   	DX, 3FDH   	; LSR端口号→DX
SendByteBusy:
               	IN 	AL, DX        	; 读入端口状态→AL
               	TEST   	AL, 20H       	; 测试状态中的第5位THRE
               	JZ     	SendByteBusy  	; THRE=0, 继续查询
               	POP    	EAX           	; 要发送的数据出栈
               	MOV    	DX, 3F8H      	; THR端口号→DX
          	OUT    	DX, AL        	; 数据发送到THR
               	RET
SendByte       	ENDP