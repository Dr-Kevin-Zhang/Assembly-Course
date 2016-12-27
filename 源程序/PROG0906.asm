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
numSect                	equ    	1 		; �������������
lbaSector            		equ 	0  		; �������LBA
.data                        
driverStr    	byte 		"\\.\giveio",0 			; �豸�ļ���
errStr      	byte 		'Load giveio.sys first!',0ah,0
_Buffer     	byte  		512*numSect dup (2)   	; ����������������
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
           	invoke  		CreateFileA,   			; ���ļ�
                       	offset driverStr,			; �ļ���
                       	GENERIC_READ,     	; ֻ����ʽ��
                       	0, 
                       	NULL, 
                       	OPEN_EXISTING,       	; ���Ѵ��ڵ��ļ�
                      	0, 
                       	0
         		cmp   		eax,INVALID_HANDLE_VALUE
           	jz    		OpenFail        			; ���ܴ�,�˳�
           	invoke 		CloseHandle,eax       	; �ر��ļ�
          	mov 		eax,1                	; ����1,��ʾTRUE
           	ret
OpenFail:
      			mov   		eax,0			; ����0,��ʾFALSE
           	ret
AllowIo    	endp
start:
            	call 		AllowIo  			; �Ƿ���Խ���I/O?
            	cmp    		eax,0                	; EAX=0,���ܽ���I/O
            	jnz    		AllowIoLoadOk          	; �˳�
            	invoke 		printf,offset errStr      	; ��ʾ��ʾ��Ϣ
            	ret
AllowIoLoadOk:    
          	; SRST=1,	��λӲ��
        		outx  		pio_base_addr2+6,04h 			; SRST=1
         	 	outx   	 	pio_base_addr2+6,00h      	; SRST=0
            	; �ȴ���ֱ��BSY=0����DRQ=0.
waitReady:
           	inx    		pio_base_addr1+7				; read primary status
            	and    		al,10001000b            		; busy,or data request
            	jnz  	   	waitReady
           	; ����feature port�Ĵ���
      			outx    		pio_base_addr1+1,00h
            	; ����sector count�Ĵ���, Ҫ��д��������
           	outx   		pio_base_addr1+2,numSect
            	; ����sector numbert�Ĵ���, LBA(7:0)
            	outx    		pio_base_addr1+3,((lbaSector shr 0) and 0ffh)
            	; ����cylinder low�Ĵ���,   LBA(15:8)
            	outx    		pio_base_addr1+4,((lbaSector shr 8) and 0ffh)
            	; ����cylinder high�Ĵ���,  LBA(23:16)
            	outx    		pio_base_addr1+5,((lbaSector shr 16) and 0ffh)
            	; ����device/head�Ĵ���, LBA=1, DEV=0, LBA(27:24)
            	outx    		pio_base_addr1+6,01000000b or \
            					((lbaSector shr 24) and 0fh)
        		; ����command�Ĵ���, 20h��ʾREAD SECTOR(S)
            	outx    		pio_base_addr1+7,020h 
            	; �ȴ���ֱ��DRDY=1, DSC=1, DRQ=1.
waitHDD:                
            	inx     		pio_base_addr1+7
            	cmp     	al,01011000b
            	jnz   	  	waitHDD
            	; ����256�Σ�ÿ�ζ��������ֽڣ�˳�򱣴���_Buffer��
				lea 	    	edi,_Buffer
            	cld
            	mov     	ecx,numSect*256
Read2Bytes:
         		mov     	dx,pio_base_addr1
         		in	      	ax,dx
          	stosw
           	loop  		Read2Bytes
         		call		DisplayBuffer				; ��ʾ_Buffer����
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