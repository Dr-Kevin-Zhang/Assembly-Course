;PROG0904
RecieveByte    	PROC
               	MOV    	DX, 3FDH      	; LSR�˿ںš�DX
NoByteReceived:         
               	IN     	AL, DX        	; ����˿�״̬��AL
               	TEST   	AL, 01H      	; ����״̬�еĵ�0λDR
                JZ     	NoByteReceived	; DR=0, ������ѯ
              	MOV    	DX, 3F8H      	; RBR�˿ںš�DX
                IN     	AL, DX        	; ����RBR�е������ֽ�
                RET
RecieveByte    	ENDP