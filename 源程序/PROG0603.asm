;PROG0603.ASM
.386
.model flat,stdcall
option casemap:none
includelib	msvcrt.lib
printf     	PROTO C	:dword,:vararg
.data
szFmt      	byte  		'%d + %d=%d', 0ah, 0		;��������ʽ�ַ���
x           	dword		?
y           	dword		?
z           	dword		?
.code
AddProc1    	proc                         		; ʹ�üĴ�����Ϊ����
           	mov  		eax, esi              	; EAX=ESI + EDI
            	add  		eax, edi
            	ret
AddProc1     	endp
AddProc2    	proc                            	; ʹ�ñ�����Ϊ����
            	push	eax                	; C=A + B
            	mov 	eax, x
            	add 	eax, y
            	mov	z, eax
          	pop 	eax            		; �ָ�EAX��ֵ
            	ret
AddProc2   	endp
start:          
          	mov 	esi, 10 
           	mov	edi, 20            		; Ϊ�ӳ���׼������
            	call	AddProc1          		; �����ӳ���
                                           		; �����EAX��
            	mov 	x, 50               	
             	mov 	y, 60               	; Ϊ�ӳ���׼������
           	call	AddProc2            	; �����ӳ���
                                            		; �����Z��
           	invoke	printf, offset szFmt, 
                      	esi, edi, eax       		; ��ʾ��1�μӷ����
             	invoke 	printf, offset szFmt, 
                        	x, y, z            		; ��ʾ��2�μӷ����
          	ret
end        	start