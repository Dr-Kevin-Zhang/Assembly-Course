;PROG0614.ASM
.386
.model flat
public  _a, _b                             	; ����a,b��Cģ����ʹ��
extrn   _z:sdword                       		; _z��Cģ����
.data
_a              sdword   3
_b              sdword   4
.code
CalcAXBY        proc		C x:sdword, y:sdword
                 push 	esi          		; �ӳ������õ�EBX, ESI, EDIʱ
                 push    	edi          		; ���뱣���ڶ�ջ��
                 mov    	eax, x       		; x�ڶ�ջ��             
                 mul     	_a            	; a*x �� EAX
                 mov     	esi, eax      		; a*x �� ESI       
                 mov     	eax, y        		; y�ڶ�ջ��
                 mul     	_b            	; b*y �� EAX
                 mov     	edi, eax     		; a*x+b*y �� ECX
                 add     	esi, edi     		; a*x+b*y �� ECX
                mov     	_z, esi       		; a*x+b*y �� _z
                 mov     	eax, 0    			; ��������ֵ��Ϊ0
                 pop     	edi           	; �ָ�EDI
                 pop    	esi          		; �ָ�ESI      
                 ret   
CalcAXBY        endp
                 end