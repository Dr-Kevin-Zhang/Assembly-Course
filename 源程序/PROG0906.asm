;PROG0906
.386
.model flat,stdcall
option casemap:none
includelib  	msvcrt.lib
includelib  	kernel32.lib
printf      	PROTO C format:ptr sbyte,:vararg
CreateFileA	PROTO stdcall, :NEAR32, :dword, :dword, :NEAR32, 
          	:dword, :dword, :dword  
CloseHandle	PROTO stdcall,hObject:dword
GENERIC_READ  		equ    	80000000h
OPEN_EXISTING          	equ    	3
FILE_ATTRIBUTE_NORMAL	equ    	00000080h
INVALID_HANDLE_VALUE	equ   	 1
NULL                   	equ   	0
pio_base_addr1         	equ    	01f0h
pio_base_addr2         	equ    	03f0h
numSect                	equ    	1 		; 读入的扇区个数
lbaSector            		equ 	0  		; 扇区编号LBA
.data                        
driverStr    	byte 		"\\.\giveio",0 			; 设备文件名
errStr      	byte 		'Load giveio.sys first!',0ah,0
_Buffer     	byte  		512*numSect dup (2)   	; 保存读入的扇区数据
_BufferLen		equ 		$-_Buffer
szFmt      	byte  		'%02X',0
szCRLF   	byte	    	0dh, 0ah, 0
outx       	macro  		port,val
          	mov    		dx,port
           	mov	    	al,val
          	out 	   	dx,al
          	endm
inx       	macro 		port
          	mov   	 	dx,port
          	in   		al,dx
           	endm
.code
AllowIo    	proc
           	invoke  		CreateFileA,   			; 打开文件
                       	offset driverStr,			; 文件名
                       	GENERIC_READ,     	; 只读方式打开
                       	0, 
                       	NULL, 
                       	OPEN_EXISTING,       	; 打开已存在的文件
                      	0, 
                       	0
         		cmp   		eax,INVALID_HANDLE_VALUE
           	jz    		OpenFail        			; 不能打开,退出
           	invoke 		CloseHandle,eax       	; 关闭文件
          	mov 		eax,1                	; 返回1,表示TRUE
           	ret
OpenFail:
      			mov   		eax,0			; 返回0,表示FALSE
           	ret
AllowIo    	endp
start:
            	call 		AllowIo  			; 是否可以进行I/O?
            	cmp    		eax,0                	; EAX=0,不能进行I/O
            	jnz    		AllowIoLoadOk          	; 退出
            	invoke 		printf,offset errStr      	; 显示提示信息
            	ret
AllowIoLoadOk:    
          	; SRST=1,	复位硬盘
        		outx  		pio_base_addr2+6,04h 			; SRST=1
         	 	outx   	 	pio_base_addr2+6,00h      	; SRST=0
            	; 等待，直到BSY=0而且DRQ=0.
waitReady:
           	inx    		pio_base_addr1+7				; read primary status
            	and    		al,10001000b            		; busy,or data request
            	jnz  	   	waitReady
           	; 设置feature port寄存器
      			outx    		pio_base_addr1+1,00h
            	; 设置sector count寄存器, 要读写的扇区数
           	outx   		pio_base_addr1+2,numSect
            	; 设置sector numbert寄存器, LBA(7:0)
            	outx    		pio_base_addr1+3,((lbaSector shr 0) and 0ffh)
            	; 设置cylinder low寄存器,   LBA(15:8)
            	outx    		pio_base_addr1+4,((lbaSector shr 8) and 0ffh)
            	; 设置cylinder high寄存器,  LBA(23:16)
            	outx    		pio_base_addr1+5,((lbaSector shr 16) and 0ffh)
            	; 设置device/head寄存器, LBA=1, DEV=0, LBA(27:24)
            	outx    		pio_base_addr1+6,01000000b or \
            					((lbaSector shr 24) and 0fh)
        		; 设置command寄存器, 20h表示READ SECTOR(S)
            	outx    		pio_base_addr1+7,020h 
            	; 等待，直到DRDY=1, DSC=1, DRQ=1.
waitHDD:                
            	inx     		pio_base_addr1+7
            	cmp     	al,01011000b
            	jnz   	  	waitHDD
            	; 读入256次，每次读入两个字节，顺序保存在_Buffer中
				lea 	    	edi,_Buffer
            	cld
            	mov     	ecx,numSect*256
Read2Bytes:
         		mov     	dx,pio_base_addr1
         		in	      	ax,dx
          	stosw
           	loop  		Read2Bytes
         		call		DisplayBuffer				; 显示_Buffer内容
        		ret
DisplayBuffer	proc
         		lea     		esi,_Buffer
           	mov    		ecx,_BufferLen
          	xor    		eax,eax
          	xor    		ebp,ebp
         		cld
DisplayByte:
       		push 		ecx
          	lodsb
        		invoke  		printf,offset szFmt,eax
           	inc 	    	ebp
          	test    		ebp, 0fh
          	jnz     		DisplayCRLF
          	invoke  		printf,offset szCRLF
DisplayCRLF:               
           	pop		ecx
            	loop		DisplayByte
           	ret
DisplayBuffer	endp                
end       	start