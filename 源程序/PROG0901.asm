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
driverStr      	byte  	"\\.\giveio", 0    	; �豸�ļ���
cmosIndex    	byte 	9, 8, 7, 4, 2, 0       	; ��/��/��/ʱ/��/�������
cmosData   		dword 	6 dup (?)          	; ��/��/��/ʱ/��/��
fmtStr        	byte   	'20%02d/%02d/%02d %02d:%02d:%02d', 0ah, 0
.code
AllowIo       	proc
              	pushfd                  	; ��־�Ĵ���ѹջ
               	pop   	eax               	; ��־�Ĵ�����EAX
               	and   	eax, 00003000h    	; ȡ���12,13λ
  	cmp   	eax, 00003000h    	; IOPL�Ƿ����3 ? 
                jnz    	IOPLZero          	; IOPL != 3, ���������������
                                            	; IOPL = 3, �������ִ��I/O
               	mov   	eax, 1            	; ����1, ��ʾTRUE 
               	ret
IOPLZero:
               	invoke 	CreateFileA,        	; ���豸�ļ�
                  	offset driverStr,   	; �ļ���
                         	GENERIC_READ,   	; ֻ����ʽ��
                        	0,  
                        	NULL,  
                        	OPEN_EXISTING, 	; ���Ѵ��ڵ��ļ�
                        	0,  
                        	0
	cmp     	eax, INVALID_HANDLE_VALUE
	jz       	OpenFail           	; ���ܴ�, �˳�
              	invoke	CloseHandle, eax 	; �ر��ļ�
               	mov  	eax, 1           	; ����1, ��ʾTRUE
              	ret
OpenFail:
            	mov  	eax, 0           	; ����0, ��ʾFALSE
	ret
AllowIo        	endp
start:
	call	AllowIo           	; �Ƿ���Խ���I/O?
	cmp   	eax, 0          	; EAX=0,���ܽ���I/O
	jz     	ExitIo            	; �˳�
	mov  	ecx, 6            	; һ��Ҫ��ȡ6���ֽ�
               	mov   	esi, 0            	; �����±��ʼ��Ϊ0
GetCmos:        
	mov  	al, cmosIndex[esI] 	; ȡ������
	out 	70h, al             	; ��������
	in   	al, 71h            			; ��ȡ����
                                                	; ��ȡ����������BCD���ʽ
                                                	; ���� Al=56H ��ʾ 56 ��
	mov	ah, al                 		; AL��AH, AH=56H
	shr    	ah, 4                   		; ȡ��4λ��AH�� 
	and  	al, 0fh                		; AL��4λ����, 
	aad                            		; AH*10+AL��AL
	mov 	byte ptr cmosData[esi*4],al		; ����
	inc    	esi                    		; ������1
	loop	GetCmos                 	; ����ȡ��
					; ��/��/��/ʱ/��/��
	invoke	printf,                  		; ��ʾ���
		offset fmtStr, 
		cmosData[0*4],          		; �� 
		cmosData[1*4],        		; ��
		cmosData[2*4],         	 	; ��
		cmosData[3*4],         	 	; ʱ
		cmosData[4*4],          		; ��
		cmosData[5*4]          	 	; ��
ExitIo:         
	ret
end        	start