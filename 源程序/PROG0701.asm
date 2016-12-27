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
szPrompt1      	byte 	"input filename: ", 0     	; 输入文件名
szFormat1      	byte 	"%s", 0
szPrompt2      	byte 	"input cipher(0～255): ", 0 	; 输入密码
szFormat2      	byte 	"%d", 0
modestr        	byte 	"rb+", 0               	; 打开模式
filename        	byte 	80 dup (0)         	; 文件名
cipher          	byte 	?                  	; 密码
              	byte 	0,0,0
fp             	dword	?     	; FILE * fp;
buf            	byte  	256 dup (0)        	 缓冲区
bytes           	dword 	?
position        	dword 	0               	; 读写指针
.code
start:
          		invoke		printf, offset szPrompt1   	; 输入文件名
              	invoke		scanf, offset szFormat1, offset filename

              	invoke		printf, offset szPrompt2   		; 输入密码
              	invoke 	scanf, offset szFormat2, offset cipher

              	invoke 	fopen, offset filename, offset modestr 
              	mov   	fp, eax               		; fp=fopen(...);
              	cmp   	fp, 0                			; fp为NULL?
              	jz     	b40                 		; 不能打开文件, 退出
b10:
             		; fseek(fp, position, 0)
              	invoke		fseek, fp, position, 0
             		; fread(&buf, sizeof(buf), 1, fp)
               	invoke  	fread, offset buf, 1, size buf, fp
              	cmp   	eax, 0          
               	jz     	b30                 		; 读入字节数为0, 结束
                
              	mov   	bytes, eax
              	mov   	ecx, eax
              	cld
              	lea    	esi, buf
              	lea    	edi, buf
b20:            
              	lodsb                     			; 取出1个字节
              	xor   		al, cipher              		; 将该字节与密码异或
              	stosb                           		; 存入缓冲区
              	loop    	b20                     	; 处理读入的所有字节

              	; fseek(fp, position, 0)
              	invoke 	fseek, fp, position, 0
              	; fwrite(&buf, 1, bytes, fp)
              	invoke  	fwrite, offset buf, 1, bytes, fp
              	cmp   	eax, bytes
              	jnz    	b30                     	; 写入失败, 结束
                
              	mov   	eax, bytes
              	add    	position, eax           		; 更新position
              	jmp    	b10
b30:            
              	invoke		fclose, fp              		;关闭文件
b40:            
              	ret
end           		start