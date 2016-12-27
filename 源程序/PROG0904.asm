;PROG0904
RecieveByte    	PROC
               	MOV    	DX, 3FDH      	; LSR端口号→DX
NoByteReceived:         
               	IN     	AL, DX        	; 读入端口状态→AL
               	TEST   	AL, 01H      	; 测试状态中的第0位DR
                JZ     	NoByteReceived	; DR=0, 继续查询
              	MOV    	DX, 3F8H      	; RBR端口号→DX
                IN     	AL, DX        	; 读入RBR中的数据字节
                RET
RecieveByte    	ENDP