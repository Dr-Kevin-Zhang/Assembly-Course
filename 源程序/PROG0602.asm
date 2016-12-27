;PROG0602.ASM
szStr            BYTE		10 DUP (0)

                MOV 	EAX, 8192
                XOR 	EDX, EDX             
                XOR 	ECX, ECX             
                MOV 	EBX, 10              
a10:
                DIV 	EBX         		;EDX:EAX除以10      
                PUSH	EDX           	; 商在EDX中, EDX压栈 
                INC 	ECX           	;ECX表示压栈的次数   
                XOR 	EDX, EDX       	;EDX:EAX=下一次除法的被除数 
                CMP 	EAX, EDX       	; 被除数=0?            
                JNZ	a10             	; 如果被除数为0，不再循环 
                MOV 	EDI, OFFSET szStr
a20:
                POP	EAX           	; 从堆栈中取出商      
                ADD 	AL, '0'         		; 转换为ASCII码        
                MOV	[EDI], AL      		; 保存在szStr中            
                INC 	EDI
                LOOP	a20       	    	; 循环处理                  
                MOV	BYTE PTR [EDI], 0