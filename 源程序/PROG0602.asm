;PROG0602.ASM
szStr            BYTE		10 DUP (0)

                MOV 	EAX, 8192
                XOR 	EDX, EDX             
                XOR 	ECX, ECX             
                MOV 	EBX, 10              
a10:
                DIV 	EBX         		;EDX:EAX����10      
                PUSH	EDX           	; ����EDX��, EDXѹջ 
                INC 	ECX           	;ECX��ʾѹջ�Ĵ���   
                XOR 	EDX, EDX       	;EDX:EAX=��һ�γ����ı����� 
                CMP 	EAX, EDX       	; ������=0?            
                JNZ	a10             	; ���������Ϊ0������ѭ�� 
                MOV 	EDI, OFFSET szStr
a20:
                POP	EAX           	; �Ӷ�ջ��ȡ����      
                ADD 	AL, '0'         		; ת��ΪASCII��        
                MOV	[EDI], AL      		; ������szStr��            
                INC 	EDI
                LOOP	a20       	    	; ѭ������                  
                MOV	BYTE PTR [EDI], 0