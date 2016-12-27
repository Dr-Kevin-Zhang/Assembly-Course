;PROG0909
.386P
bmcr_base_addr 	  EQU	0C000H    		; DMA主控寄存器首地址
numSect         	  EQU 	1            		; 读取1个扇区
lbaSector       	  EQU 	0            		; LBA=0
BM_COMMAND_REG  EQU 	0          		; 主控命令寄存器的偏移
BM_STATUS_REG  	  EQU	2           		; 主控状态寄存器的偏移
BM_PRD_ADDR_REG	  EQU	4           		; 物理区域描述符表指针寄存器的偏移
pio_base_addr1 	  EQU 	01F0H       		; ATA设备控制块寄存器基地址
pio_base_addr2 	  EQU	03F0H		; ATA命令命令块寄存器基地址
DSEG          	  SEGMENT USE16    		; 16位数据段
ALIGN 2                
_Buffer       	  DB  	512*numSect DUP (0) 	; 内存缓冲区
_BufferLen    	  EQU	$ _Buffer
ALIGN 4                
prdBuf    	DD 	0         			; 物理区域描述符
               	DD  	0
prdBufAddr     	DD  	0           			; 物理区域描述符地址
bufferaddr     	DD 	0          			; 内存缓冲区地址
DSEG            	ENDS                		; 数据段结束
SSEG            	SEGMENT PARA STACK  	; 堆栈段
                	DB 	512 DUP (0)
SSEG            	ENDS            		; 堆栈段结束
outx     MACRO  	Reg, Val            		; 向Reg端口写入数据Val
        MOV     	DX, Reg
        MOV     	AL, Val
        OUT     	DX, AL
        ENDM
inx      MACRO   	Reg                 	; 从Reg端口读入数据, 存放在AL中
        MOV     	DX, Reg
        IN      	AL, DX
        ENDM
CSEG   SEGMENT USE16               		; 代码段
        ASSUME  CS:CSEG,DS:DSEG
; 检查ATA状态寄存器, 直到BSY=0和DRQ=0
waitDeviceReady PROC
waitReady:
        INX   		pio_base_addr1+7    		; 读取ATA状态寄存器
        AND  		AL, 10001000b       		; BSY=1或DRQ=1,继续查询
        JNZ   		waitReady
        RET
waitDeviceReady ENDP
; 采用DMA方式读取硬盘扇区
ReadSectors   		PROC               
        ; Start/Stop=0, 停止以前的DMA传输
        outx  		bmcr_base_addr+BM_COMMAND_REG, 00H
        ; 清除主控状态寄存器的Interrupt和Error位
        outx  		bmcr_base_addr+BM_STATUS_REG, 00000110b
        ; 建立一个物理区域描述符
        MOV    	EAX, bufferaddr
        MOV    	prdBuf, EAX      			; Physical Address
        MOV    	WORD PTR prdBuf+4, _BufferLen ; Byte Count [15:1]
        MOV  		WORD PTR prdBuf+6, 8000H 	; EOT=1
        ; 物理区域描述符的地址写入PRDTR
        MOV 	EAX, prdBufAddr
        MOV  	DX, bmcr_base_addr+BM_PRD_ADDR_REG
        OUT   	DX, EAX
        ; 主控命令寄存器的R/W=1, 表示写入内存(读取硬盘)
        outx   	bmcr_base_addr+BM_COMMAND_REG, 08h 
        ; 等待硬盘BSY=0和DRQ=0
        CALL   	waitDeviceReady
        ; 设置设备/磁头寄存器的DEV=0
        outx   	pio_base_addr1+6, 00H
        ; 等待硬盘BSY=0和DRQ=0
        CALL   	waitDeviceReady
        ; 设备控制寄存器的nIEN=0, 允许中断
        outx   	pio_base_addr2+6,  00
        ; 设置ATA寄存器
        outx   	pio_base_addr1+1, 00H             		; =00
        outx   	pio_base_addr1+2, numSect            	; 扇区号
        outx   	pio_base_addr1+3, lbaSector >> 0   		; LBA第7～0位
        outx   	pio_base_addr1+4, lbaSector >> 8   		; LBA第15～8位
        outx   	pio_base_addr1+5, lbaSector >> 16  		; LBA第23～16位
        ; 设备/磁头寄存器:LBA=1, DEV=0, LBA第27～24位
        outx   	pio_base_addr1+6, 01000000b OR (lbaSector >> 24)   
        ; 设置ATA命令寄存器
        outx   	pio_base_addr1+7, 0C8H          		; 0C8h=Read DMA
        ; 读取主控命令寄存器和主控状态寄存器
        inx    	bmcr_base_addr + BM_COMMAND_REG
        inx    	bmcr_base_addr + BM_STATUS_REG
        ; 主控命令寄存器的R/W=1,Start/Stop=1, 启动DMA传输 
        outx   	bmcr_base_addr+BM_COMMAND_REG, 09H
        ; 现在开始DMA数据传送
        ; 检查主控状态寄存器, Interrupt=1时,传送结束
        MOV   	ECX, 4000H
notAsserted:
        INX    	bmcr_base_addr+BM_STATUS_REG
        AND    	AL, 00000100b
        JZ     	notAsserted
        ; 清除主控状态寄存器的Interrupt位
        outx   	bmcr_base_addr+BM_STATUS_REG, 00000100b
        ; 读取主控状态寄存器
        inx    	bmcr_base_addr+BM_STATUS_REG
        ; 主控命令寄存器的Start/Stop=０, 结束DMA传输
        outx   	bmcr_base_addr+BM_COMMAND_REG, 00H
        RET
ReadSectors    	ENDP               
START 	PROC
	MOV    	AX,DSEG
	MOV   	DS,AX                 		; ds指向数据段
	MOV  	ES,AX                 		; es指向数据段
	MOV    	BX,16                   
	MOV  	AX,DS                   
	MUL 	BX                    		; 计算并设置数据段基址
	ADD   	AX, OFFSET prdBuf     		; 数据段基址+OFFSET prdBuf
	ADC   	DX, 0                 		; DX:AX = prdBuf的物理地址
	MOV   	WORD PTR prdBufAddr, AX
	MOV  	WORD PTR prdBufAddr+2, DX
	MOV 	AX,DS
	MUL 	BX
	ADD  	AX, OFFSET _Buffer    		; 段基址+OFFSET _Buffer
	ADC   	DX, 0                 		; DX:AX = _Buffer的物理地址
	MOV   	WORD PTR bufferaddr, AX
	MOV   	WORD PTR bufferaddr+2, DX
	CLI      		               	; 关中断
	CALL  	ReadSectors         		; DMA方式读取硬盘扇区
	STI                           		; 允许中断
	CALL   	ShowBuffer          	  	; 显示缓冲区内容
	MOV   	AX,4C00H
	INT    	21H
START	ENDP
;字符显示宏指令的定义
EchoCh		MACRO  	ascii
		MOV   	AH,2
		MOV   	DL,ascii
		INT    	21H
		ENDM
ShowBuffer      	PROC
	LEA    	SI,_Buffer  			; 显示_Buffer内容
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
CSEG	ENDS                 		; 代码段结束
	END  		START