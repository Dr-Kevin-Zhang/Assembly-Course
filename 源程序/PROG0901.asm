;PROG0901
.386
.model flat,stdcall
option casemap:none
includelib     	msvcrt.lib
includelib     	kernel32.lib
printf         	PROTO C format: ptr sbyte,:vararg
CreateFileA   	PROTO stdcall,
             	lpFileName:NEAR32, dwDesiredAccess: dword, dwShareMode: dword,
             	lpSecurityAttributes:NEAR32, dwCreationDisposition:dword,
             	dwFlagsAndAttributes:dword, hTemplateFile:dword
CloseHandle   	PROTO stdcall, hObject:dword
GENERIC_READ            	equ   		80000000h
OPEN_EXISTING           	equ    		3
FILE_ATTRIBUTE_NORMAL  	equ    		00000080h
INVALID_HANDLE_VALUE  	equ    		 1
NULL                      	equ    		0
.data
driverStr      	byte  	"\\.\giveio", 0    	; 设备文件名
cmosIndex    	byte 	9, 8, 7, 4, 2, 0       	; 年/月/日/时/分/秒的索引
cmosData   		dword 	6 dup (?)          	; 年/月/日/时/分/秒
fmtStr        	byte   	'20%02d/%02d/%02d %02d:%02d:%02d', 0ah, 0
.code
AllowIo       	proc
              	pushfd                  	; 标志寄存器压栈
               	pop   	eax               	; 标志寄存器→EAX
               	and   	eax, 00003000h    	; 取其第12,13位
  	cmp   	eax, 00003000h    	; IOPL是否等于3 ? 
                jnz    	IOPLZero          	; IOPL != 3, 需借助于驱动程序
                                            	; IOPL = 3, 程序可以执行I/O
               	mov   	eax, 1            	; 返回1, 表示TRUE 
               	ret
IOPLZero:
               	invoke 	CreateFileA,        	; 打开设备文件
                  	offset driverStr,   	; 文件名
                         	GENERIC_READ,   	; 只读方式打开
                        	0,  
                        	NULL,  
                        	OPEN_EXISTING, 	; 打开已存在的文件
                        	0,  
                        	0
	cmp     	eax, INVALID_HANDLE_VALUE
	jz       	OpenFail           	; 不能打开, 退出
              	invoke	CloseHandle, eax 	; 关闭文件
               	mov  	eax, 1           	; 返回1, 表示TRUE
              	ret
OpenFail:
            	mov  	eax, 0           	; 返回0, 表示FALSE
	ret
AllowIo        	endp
start:
	call	AllowIo           	; 是否可以进行I/O?
	cmp   	eax, 0          	; EAX=0,不能进行I/O
	jz     	ExitIo            	; 退出
	mov  	ecx, 6            	; 一共要读取6个字节
               	mov   	esi, 0            	; 数组下标初始化为0
GetCmos:        
	mov  	al, cmosIndex[esI] 	; 取得索引
	out 	70h, al             	; 设置索引
	in   	al, 71h            			; 读取数据
                                                	; 读取到的数据是BCD码格式
                                                	; 例如 Al=56H 表示 56 秒
	mov	ah, al                 		; AL→AH, AH=56H
	shr    	ah, 4                   		; 取高4位到AH中 
	and  	al, 0fh                		; AL高4位清零, 
	aad                            		; AH*10+AL→AL
	mov 	byte ptr cmosData[esi*4],al		; 保存
	inc    	esi                    		; 索引加1
	loop	GetCmos                 	; 依次取得
					; 年/月/日/时/分/秒
	invoke	printf,                  		; 显示结果
		offset fmtStr, 
		cmosData[0*4],          		; 年 
		cmosData[1*4],        		; 月
		cmosData[2*4],         	 	; 日
		cmosData[3*4],         	 	; 时
		cmosData[4*4],          		; 分
		cmosData[5*4]          	 	; 秒
ExitIo:         
	ret
end        	start