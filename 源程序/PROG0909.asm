;PROG0909
.386P
bmcr_base_addr 	  EQU	0C000H    		; DMA���ؼĴ����׵�ַ
numSect         	  EQU 	1            		; ��ȡ1������
lbaSector       	  EQU 	0            		; LBA=0
BM_COMMAND_REG  EQU 	0          		; ��������Ĵ�����ƫ��
BM_STATUS_REG  	  EQU	2           		; ����״̬�Ĵ�����ƫ��
BM_PRD_ADDR_REG	  EQU	4           		; ����������������ָ��Ĵ�����ƫ��
pio_base_addr1 	  EQU 	01F0H       		; ATA�豸���ƿ�Ĵ�������ַ
pio_base_addr2 	  EQU	03F0H		; ATA���������Ĵ�������ַ
DSEG          	  SEGMENT USE16    		; 16λ���ݶ�
ALIGN 2                
_Buffer       	  DB  	512*numSect DUP (0) 	; �ڴ滺����
_BufferLen    	  EQU	$ _Buffer
ALIGN 4                
prdBuf    	DD 	0         			; ��������������
               	DD  	0
prdBufAddr     	DD  	0           			; ����������������ַ
bufferaddr     	DD 	0          			; �ڴ滺������ַ
DSEG            	ENDS                		; ���ݶν���
SSEG            	SEGMENT PARA STACK  	; ��ջ��
                	DB 	512 DUP (0)
SSEG            	ENDS            		; ��ջ�ν���
outx     MACRO  	Reg, Val            		; ��Reg�˿�д������Val
        MOV     	DX, Reg
        MOV     	AL, Val
        OUT     	DX, AL
        ENDM
inx      MACRO   	Reg                 	; ��Reg�˿ڶ�������, �����AL��
        MOV     	DX, Reg
        IN      	AL, DX
        ENDM
CSEG   SEGMENT USE16               		; �����
        ASSUME  CS:CSEG,DS:DSEG
; ���ATA״̬�Ĵ���, ֱ��BSY=0��DRQ=0
waitDeviceReady PROC
waitReady:
        INX   		pio_base_addr1+7    		; ��ȡATA״̬�Ĵ���
        AND  		AL, 10001000b       		; BSY=1��DRQ=1,������ѯ
        JNZ   		waitReady
        RET
waitDeviceReady ENDP
; ����DMA��ʽ��ȡӲ������
ReadSectors   		PROC               
        ; Start/Stop=0, ֹͣ��ǰ��DMA����
        outx  		bmcr_base_addr+BM_COMMAND_REG, 00H
        ; �������״̬�Ĵ�����Interrupt��Errorλ
        outx  		bmcr_base_addr+BM_STATUS_REG, 00000110b
        ; ����һ����������������
        MOV    	EAX, bufferaddr
        MOV    	prdBuf, EAX      			; Physical Address
        MOV    	WORD PTR prdBuf+4, _BufferLen ; Byte Count [15:1]
        MOV  		WORD PTR prdBuf+6, 8000H 	; EOT=1
        ; ���������������ĵ�ַд��PRDTR
        MOV 	EAX, prdBufAddr
        MOV  	DX, bmcr_base_addr+BM_PRD_ADDR_REG
        OUT   	DX, EAX
        ; ��������Ĵ�����R/W=1, ��ʾд���ڴ�(��ȡӲ��)
        outx   	bmcr_base_addr+BM_COMMAND_REG, 08h 
        ; �ȴ�Ӳ��BSY=0��DRQ=0
        CALL   	waitDeviceReady
        ; �����豸/��ͷ�Ĵ�����DEV=0
        outx   	pio_base_addr1+6, 00H
        ; �ȴ�Ӳ��BSY=0��DRQ=0
        CALL   	waitDeviceReady
        ; �豸���ƼĴ�����nIEN=0, �����ж�
        outx   	pio_base_addr2+6,  00
        ; ����ATA�Ĵ���
        outx   	pio_base_addr1+1, 00H             		; =00
        outx   	pio_base_addr1+2, numSect            	; ������
        outx   	pio_base_addr1+3, lbaSector >> 0   		; LBA��7��0λ
        outx   	pio_base_addr1+4, lbaSector >> 8   		; LBA��15��8λ
        outx   	pio_base_addr1+5, lbaSector >> 16  		; LBA��23��16λ
        ; �豸/��ͷ�Ĵ���:LBA=1, DEV=0, LBA��27��24λ
        outx   	pio_base_addr1+6, 01000000b OR (lbaSector >> 24)   
        ; ����ATA����Ĵ���
        outx   	pio_base_addr1+7, 0C8H          		; 0C8h=Read DMA
        ; ��ȡ��������Ĵ���������״̬�Ĵ���
        inx    	bmcr_base_addr + BM_COMMAND_REG
        inx    	bmcr_base_addr + BM_STATUS_REG
        ; ��������Ĵ�����R/W=1,Start/Stop=1, ����DMA���� 
        outx   	bmcr_base_addr+BM_COMMAND_REG, 09H
        ; ���ڿ�ʼDMA���ݴ���
        ; �������״̬�Ĵ���, Interrupt=1ʱ,���ͽ���
        MOV   	ECX, 4000H
notAsserted:
        INX    	bmcr_base_addr+BM_STATUS_REG
        AND    	AL, 00000100b
        JZ     	notAsserted
        ; �������״̬�Ĵ�����Interruptλ
        outx   	bmcr_base_addr+BM_STATUS_REG, 00000100b
        ; ��ȡ����״̬�Ĵ���
        inx    	bmcr_base_addr+BM_STATUS_REG
        ; ��������Ĵ�����Start/Stop=��, ����DMA����
        outx   	bmcr_base_addr+BM_COMMAND_REG, 00H
        RET
ReadSectors    	ENDP               
START 	PROC
	MOV    	AX,DSEG
	MOV   	DS,AX                 		; dsָ�����ݶ�
	MOV  	ES,AX                 		; esָ�����ݶ�
	MOV    	BX,16                   
	MOV  	AX,DS                   
	MUL 	BX                    		; ���㲢�������ݶλ�ַ
	ADD   	AX, OFFSET prdBuf     		; ���ݶλ�ַ+OFFSET prdBuf
	ADC   	DX, 0                 		; DX:AX = prdBuf�������ַ
	MOV   	WORD PTR prdBufAddr, AX
	MOV  	WORD PTR prdBufAddr+2, DX
	MOV 	AX,DS
	MUL 	BX
	ADD  	AX, OFFSET _Buffer    		; �λ�ַ+OFFSET _Buffer
	ADC   	DX, 0                 		; DX:AX = _Buffer�������ַ
	MOV   	WORD PTR bufferaddr, AX
	MOV   	WORD PTR bufferaddr+2, DX
	CLI      		               	; ���ж�
	CALL  	ReadSectors         		; DMA��ʽ��ȡӲ������
	STI                           		; �����ж�
	CALL   	ShowBuffer          	  	; ��ʾ����������
	MOV   	AX,4C00H
	INT    	21H
START	ENDP
;�ַ���ʾ��ָ��Ķ���
EchoCh		MACRO  	ascii
		MOV   	AH,2
		MOV   	DL,ascii
		INT    	21H
		ENDM
ShowBuffer      	PROC
	LEA    	SI,_Buffer  			; ��ʾ_Buffer����
	CLD
	MOV  	BP,_BufferLen/16
NextLine:
	MOV    	CX,16
NextCh:         
	LODSB
	PUSH  	AX
	SHR   		AL,4
	CALL  	ToASCII
	EchoCh 	AL
	POP     	AX
	CALL     	ToASCII
	EchoCh   	AL
	EchoCh 	'  '
	LOOP   	NextCh
	EchoCh   	0DH
	EchoCh   	0AH
	DEC     	BP
	JNZ     	NextLine
	RET
ShowBuffer        	ENDP
ToASCII          	PROC
	AND     	AL,0FH
	CMP    	AL,10
	JAE      	Over10
	ADD     	al,'0'
	RET
Over10:
	ADD  		al,'A' 10
	RET
ToASCII ENDP
CSEG	ENDS                 		; ����ν���
	END  		START