;PROG0907
DMA_PORT    	EQU	0
PAGE_PORT   	EQU    	81H
DMAInit       	PROC
              	CLI
              	; 单字节传送, 地址加1, 不自动重载, 从内存到I/O, 通道2
              	MOV 	AL, 4AH  			; 01001010b
           	OUT   	DMA_PORT+11,AL	; 设置DMA工作方式
	; 16位地址和16位计数要分两次写入DMAC, 清除先/后状态后,
           	; 先写入DMA的作为低字节
             	MOV 	AL, 0
         	OUT    	DMA_PORT+12,AL	; 清除先/后状态
            	; A23~A0是内存地址, 共24位, 分3次写到DMAC中
              	MOV    	AL, A7_A0     	; 存储器地址的第7位到第0位
             	OUT    	DMA_PORT+4,AL  	; 写到DMAC中
             	MOV  	AL, A15_A8     	; 存储器地址的第15位到第8位
             	OUT    	DMA_PORT+4,AL 	; 写到DMAC中
             	MOV   	AL, A23_A16  		; 存储器地址的第23位到第16位
             	OUT   	PAGE_PORT,AL 	; 写到DMA页面寄存器中
                                    			; Count是传输的字节数
            	MOV  	AX, Count    			; 传输的字节数第7位到第0位
           	OUT    	DMA_PORT+5,AL 	; 写到DMAC中
            	MOV  	AL,AH         	; 传输的字节数第15位到第8位
              	OUT    	DMA_PORT+5,AL 	; 写到DMAC中
	STI
              	MOV     	AL,2          		; 00000010b
             	OUT    	DMA_PORT+10,AL 	; 允许DMA通道2
              	RET
DMAInit       	ENDP