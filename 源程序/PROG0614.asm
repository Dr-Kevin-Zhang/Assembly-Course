;PROG0614.ASM
.386
.model flat
public  _a, _b                             	; 允许a,b被C模块所使用
extrn   _z:sdword                       		; _z在C模块中
.data
_a              sdword   3
_b              sdword   4
.code
CalcAXBY        proc		C x:sdword, y:sdword
                 push 	esi          		; 子程序中用到EBX, ESI, EDI时
                 push    	edi          		; 必须保存在堆栈中
                 mov    	eax, x       		; x在堆栈中             
                 mul     	_a            	; a*x → EAX
                 mov     	esi, eax      		; a*x → ESI       
                 mov     	eax, y        		; y在堆栈中
                 mul     	_b            	; b*y → EAX
                 mov     	edi, eax     		; a*x+b*y → ECX
                 add     	esi, edi     		; a*x+b*y → ECX
                mov     	_z, esi       		; a*x+b*y → _z
                 mov     	eax, 0    			; 函数返回值设为0
                 pop     	edi           	; 恢复EDI
                 pop    	esi          		; 恢复ESI      
                 ret   
CalcAXBY        endp
                 end