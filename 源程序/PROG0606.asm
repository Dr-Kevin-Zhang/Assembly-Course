;PROG0606.ASM
.386
.model flat,stdcall
.data
.code
SubProc1        proc                    	; ʹ�ö�ջ���ݲ���
                push 	ebp
                mov  	ebp,esp
                mov  	eax,dword ptr [ebp+8] 	; ȡ����1������
                sub     eax,dword ptr [ebp+12]	; ȡ����2������
                pop     ebp                     	 
                ret                             	
SubProc1        endp
SubProc2        proc                            	; ʹ�ö�ջ���ݲ���
                push    ebp
                mov     ebp,esp
                mov    	eax,dword ptr [ebp+8]	; ȡ����1������
                sub     eax,dword ptr [ebp+12]	; ȡ����2������
                pop     ebp                     	 
                ret    	8                       	; ƽ��������Ķ�ջ
SubProc2        endp
start:          
                push    10                      	; ��2��������ջ
                push    20                      	; ��1��������ջ
                call    SubProc1                	; �����ӳ���
                add     esp, 8
                push    100                     	; ��2��������ջ
                push    200                     	; ��1��������ջ
                call    SubProc2                	; �����ӳ���
                ret
end             start