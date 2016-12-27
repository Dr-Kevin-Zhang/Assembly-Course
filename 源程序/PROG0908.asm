;PROG0908
.386P
DSEG     	SEGMENT USE16    	;16位数据段
CfgSpace   	DB	256 DUP(0)	;PCI设备的256个字节配置空间
bus        	DW  	0	;bus号,0～255循环
dev        	DW   	0          	;dev号,0～31循环
func       	DW  	0          	;func号,0～7循环
index     	DW     	0          	;index,0～63循环
DSEG     	ENDS               	;数据段结束
SSEG       	SEGMENT PARA STACK 	;堆栈段
            	DW 	512 DUP (0)
SSEG      	ENDS               	;堆栈段结束
;字符显示宏指令的定义
EchoCh     	MACRO  	ascii
          	MOV    	AH,2
          	MOV    	DL,ascii
	INT	21H
	ENDM
CSEG 	SEGMENT USE16      	;代码段
           	ASSUME  CS:CSEG,DS:DSEG
; 搜索PCI-IDE设备, 获取PCI配置空间
FindPCIIDE 	PROC
           	MOV  	bus, 0         	; bus号从0循环到255
loop_bus:
	MOV 	ev, 0         	; dev号从0循环到31
loop_dev:
       	MOV   	func, 0        	; func号从0循环到7
loop_func:
        	MOV   	index, 0       	; index号从0循环到63
loop_index:
;构造EAX为一个32位双字, 写入0CF8H端口
;EAX=(1 << 31)|(bus << 16)|(dev << 11)|(func << 8)|(index << 2)
	MOVZX 	EAX,bus        	;EAX=bus                
	MOVZX 	EBX,dev        	;EBX=dev                
	MOVZX 	ECX,func       	;ECX=func
	MOVZX	EDX,index      	;EDX=index
	SHL 	EAX,16         	;EAX=(bus<<16)
	SHL	EBX,11         	;EBX=(dev<<11)
	SHL	ECX,8          	;ECX=(func<<8)
	SHL	EDX,2          	;EDX=(index<<2)
	OR    	EAX,80000000H  	;EAX=(1<<31)||(bus<<16)
	OR	EAX,EBX        	;EAX=..||(dev << 11)
	OR 	EAX,ECX        	;EAX=..||(func << 8)
	OR     	EAX,EDX        	;EAX=..||(index << 2)
	;从0CF8H端口读取的配置寄存器保存在CfgSpace[index*4]中
	LEA 	EDI,CfgSpace[EDX]
	MOV    	DX,0CF8H
	OUT   	DX,EAX         	;EAX写入到0CF8H端口
	MOV 	DX,0CFCH
	IN      	EAX,DX         	;从0CFCH端口读入
	CLD
	STOSD                  	;配置寄存器保存在CfgSpace中     
	INC 	index
	CMP   	index, 64
	JB     	loop_index     	;index=0～63
	CMP 	WORD PTR CfgSpace[0AH],0101H	;检查类代码寄存器
	JZ     	FindValidOne     	;BaseClass=01H,SubClass=01H
	CMP    	func,0           	;func=0,检查是否多功能设备
	JNZ 	NotFunc0         	;func=1,不检查
	TEST	CfgSpace[0EH],80H	;D7=1,<bus,dev>是多功能设备
	JZ 	NotMultiFunc     	;D7=0,不是
NotFunc0:
	INC    	func
	CMP    	func, 8
	JB     	loop_func      	;index=0～7
NotMultiFunc:
	INC 	dev
	CMP    	dev, 32
	JB 	loop_dev       	;dev=0～31
	INC    	bus
	CMP    	bus, 256
	JB  	loop_bus       	;bus=0～255
FindValidOne:
	RET
FindPCIIDE  	ENDP
START    	PROC
	MOV 	AX,DSEG
	MOV 	DS,AX          	;DS指向数据段
	MOV  	ES,AX          	;ES指向数据段
	CALL  	FindPCIIDE     	;搜索PCI-IDE设备
	LEA	SI,CfgSpace    	;显示配置空间中的256字节数据
	CLD
	MOV    	BP,256/16
NextLine:   	MOV 	CX,16
NextCh:   	LODSB
	PUSH   	AX
	SHR	AL,4
	CALL	ToASCII
	EchoCh 	AL
	POP   	AX
	CALL	ToASCII
	EchoCh	AL
	EchoCh 	' '
	LOOP 	NextCh
	EchoCh	0DH
	EchoCh	0AH
	DEC	BP
	JNZ	NextLine
	MOV 	AX,4C00H
	INT 	21H
START  	ENDP
ToASCII   	PROC
           	AND    	AL,0FH
          	CMP    	AL,10
	JAE     	Over10
	ADD     	AL,'0'
	RET
Over10:
	ADD   	AL,'A'-10
	RET
ToASCII  	ENDP
CSEG       	ENDS                          	;代码段结束
	END 	START