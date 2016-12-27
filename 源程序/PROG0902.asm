;PROG0902
                MOV  	AL, 10110110B    	; 计数器2的输出为方波形式
                OUT 		43H, AL         	; 以下对计数器2编程
                                       			; 产生896 Hz频率的方波
                MOV    	BX, 1331      		; 1 193 180/896 = 1 331
                MOV   	AL, BL        	; BX=1331=533H, AL=33H
                OUT   	42H, AL         	; 首先输出1331的低8位
                MOV    	AL, BH          	; AL=05H
                OUT    	42H, AL         	; 再输出1331的高8位
                IN     	AL, 61H          	; 读入61H端口的内容
                PUSH   	EAX             	; 保存在堆栈中
                OR     	AL, 00000011B    	; 设置Bit1,Bit0为1
                MOV    	ECX, 20   		; 一共循环20次
Toggle:         
                OUT    	61H, AL          	; Bit1=1时, 允许发声
                PUSH   	ECX
                MOV    	ECX, 10000000H 	; 延时约0.3秒
Delay:     	                    				; (CPU=P4, 1.8 GHz)
                LOOP   	Delay
                POP    	ECX
                XOR    	AL, 00000010B   	; Bit1: 1→0→1→0
                LOOP   	Toggle           	; 循环20次
                                        		; 10次发声, 10次不发声
                POP    	EAX          	; AL为61H端口原有的内容
                AND    	EAX, 11111100B	; 置Bit1=0, Bit0=0, 不发声
                OUT    	61H, AL     		; 恢复61H端口原有的内容