;PROG0907
DMA_PORT    	EQU	0
PAGE_PORT   	EQU    	81H
DMAInit       	PROC
              	CLI
              	; ���ֽڴ���, ��ַ��1, ���Զ�����, ���ڴ浽I/O, ͨ��2
              	MOV 	AL, 4AH  			; 01001010b
           	OUT   	DMA_PORT+11,AL	; ����DMA������ʽ
	; 16λ��ַ��16λ����Ҫ������д��DMAC, �����/��״̬��,
           	; ��д��DMA����Ϊ���ֽ�
             	MOV 	AL, 0
         	OUT    	DMA_PORT+12,AL	; �����/��״̬
            	; A23~A0���ڴ��ַ, ��24λ, ��3��д��DMAC��
              	MOV    	AL, A7_A0     	; �洢����ַ�ĵ�7λ����0λ
             	OUT    	DMA_PORT+4,AL  	; д��DMAC��
             	MOV  	AL, A15_A8     	; �洢����ַ�ĵ�15λ����8λ
             	OUT    	DMA_PORT+4,AL 	; д��DMAC��
             	MOV   	AL, A23_A16  		; �洢����ַ�ĵ�23λ����16λ
             	OUT   	PAGE_PORT,AL 	; д��DMAҳ��Ĵ�����
                                    			; Count�Ǵ�����ֽ���
            	MOV  	AX, Count    			; ������ֽ�����7λ����0λ
           	OUT    	DMA_PORT+5,AL 	; д��DMAC��
            	MOV  	AL,AH         	; ������ֽ�����15λ����8λ
              	OUT    	DMA_PORT+5,AL 	; д��DMAC��
	STI
              	MOV     	AL,2          		; 00000010b
             	OUT    	DMA_PORT+10,AL 	; ����DMAͨ��2
              	RET
DMAInit       	ENDP