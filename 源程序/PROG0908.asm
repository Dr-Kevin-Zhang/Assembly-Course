;PROG0908
.386P
DSEG     	SEGMENT USE16    	;16λ���ݶ�
CfgSpace   	DB	256 DUP(0)	;PCI�豸��256���ֽ����ÿռ�
bus        	DW  	0	;bus��,0��255ѭ��
dev        	DW   	0          	;dev��,0��31ѭ��
func       	DW  	0          	;func��,0��7ѭ��
index     	DW     	0          	;index,0��63ѭ��
DSEG     	ENDS               	;���ݶν���
SSEG       	SEGMENT PARA STACK 	;��ջ��
            	DW 	512 DUP (0)
SSEG      	ENDS               	;��ջ�ν���
;�ַ���ʾ��ָ��Ķ���
EchoCh     	MACRO  	ascii
          	MOV    	AH,2
          	MOV    	DL,ascii
	INT	21H
	ENDM
CSEG 	SEGMENT USE16      	;�����
           	ASSUME  CS:CSEG,DS:DSEG
; ����PCI-IDE�豸, ��ȡPCI���ÿռ�
FindPCIIDE 	PROC
           	MOV  	bus, 0         	; bus�Ŵ�0ѭ����255
loop_bus:
	MOV 	ev, 0         	; dev�Ŵ�0ѭ����31
loop_dev:
       	MOV   	func, 0        	; func�Ŵ�0ѭ����7
loop_func:
        	MOV   	index, 0       	; index�Ŵ�0ѭ����63
loop_index:
;����EAXΪһ��32λ˫��, д��0CF8H�˿�
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
	;��0CF8H�˿ڶ�ȡ�����üĴ���������CfgSpace[index*4]��
	LEA 	EDI,CfgSpace[EDX]
	MOV    	DX,0CF8H
	OUT   	DX,EAX         	;EAXд�뵽0CF8H�˿�
	MOV 	DX,0CFCH
	IN      	EAX,DX         	;��0CFCH�˿ڶ���
	CLD
	STOSD                  	;���üĴ���������CfgSpace��     
	INC 	index
	CMP   	index, 64
	JB     	loop_index     	;index=0��63
	CMP 	WORD PTR CfgSpace[0AH],0101H	;��������Ĵ���
	JZ     	FindValidOne     	;BaseClass=01H,SubClass=01H
	CMP    	func,0           	;func=0,����Ƿ�๦���豸
	JNZ 	NotFunc0         	;func=1,�����
	TEST	CfgSpace[0EH],80H	;D7=1,<bus,dev>�Ƕ๦���豸
	JZ 	NotMultiFunc     	;D7=0,����
NotFunc0:
	INC    	func
	CMP    	func, 8
	JB     	loop_func      	;index=0��7
NotMultiFunc:
	INC 	dev
	CMP    	dev, 32
	JB 	loop_dev       	;dev=0��31
	INC    	bus
	CMP    	bus, 256
	JB  	loop_bus       	;bus=0��255
FindValidOne:
	RET
FindPCIIDE  	ENDP
START    	PROC
	MOV 	AX,DSEG
	MOV 	DS,AX          	;DSָ�����ݶ�
	MOV  	ES,AX          	;ESָ�����ݶ�
	CALL  	FindPCIIDE     	;����PCI-IDE�豸
	LEA	SI,CfgSpace    	;��ʾ���ÿռ��е�256�ֽ�����
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
CSEG       	ENDS                          	;����ν���
	END 	START