;PROG0701
.386
.model flat,stdcall
option casemap:none
includelib      	msvcrt.lib
fopen          	PROTO C :dword,:dword
fread         	PROTO C :dword,:dword,:dword,:dword
fwrite          	PROTO C :dword,:dword,:dword,:dword
fseek          	PROTO C :dword,:dword,:dword
fclose           	PROTO C :dword
scanf          	PROTO C szformat:dword,:vararg
printf          	PROTO C szformat:dword,:vararg
.data
szPrompt1      	byte 	"input filename: ", 0     	; �����ļ���
szFormat1      	byte 	"%s", 0
szPrompt2      	byte 	"input cipher(0��255): ", 0 	; ��������
szFormat2      	byte 	"%d", 0
modestr        	byte 	"rb+", 0               	; ��ģʽ
filename        	byte 	80 dup (0)         	; �ļ���
cipher          	byte 	?                  	; ����
              	byte 	0,0,0
fp             	dword	?     	; FILE * fp;
buf            	byte  	256 dup (0)        	 ������
bytes           	dword 	?
position        	dword 	0               	; ��дָ��
.code
start:
          		invoke		printf, offset szPrompt1   	; �����ļ���
              	invoke		scanf, offset szFormat1, offset filename

              	invoke		printf, offset szPrompt2   		; ��������
              	invoke 	scanf, offset szFormat2, offset cipher

              	invoke 	fopen, offset filename, offset modestr 
              	mov   	fp, eax               		; fp=fopen(...);
              	cmp   	fp, 0                			; fpΪNULL?
              	jz     	b40                 		; ���ܴ��ļ�, �˳�
b10:
             		; fseek(fp, position, 0)
              	invoke		fseek, fp, position, 0
             		; fread(&buf, sizeof(buf), 1, fp)
               	invoke  	fread, offset buf, 1, size buf, fp
              	cmp   	eax, 0          
               	jz     	b30                 		; �����ֽ���Ϊ0, ����
                
              	mov   	bytes, eax
              	mov   	ecx, eax
              	cld
              	lea    	esi, buf
              	lea    	edi, buf
b20:            
              	lodsb                     			; ȡ��1���ֽ�
              	xor   		al, cipher              		; �����ֽ����������
              	stosb                           		; ���뻺����
              	loop    	b20                     	; �������������ֽ�

              	; fseek(fp, position, 0)
              	invoke 	fseek, fp, position, 0
              	; fwrite(&buf, 1, bytes, fp)
              	invoke  	fwrite, offset buf, 1, bytes, fp
              	cmp   	eax, bytes
              	jnz    	b30                     	; д��ʧ��, ����
                
              	mov   	eax, bytes
              	add    	position, eax           		; ����position
              	jmp    	b10
b30:            
              	invoke		fclose, fp              		;�ر��ļ�
b40:            
              	ret
end           		start