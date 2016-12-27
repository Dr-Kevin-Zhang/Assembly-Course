;PROG0505
.386
.model flat,stdcall
option casemap:none
includelib 	msvcrt.lib
printf       	PROTO C :dword,:vararg
.data
dArray       	byte  	15, 27, 39, 40, 68, 71, 82, 100, 200, 230
Items        	equ  	($-dArray)   		; ������Ԫ�صĸ���
Element      	byte  	82          		; �������в��ҵ�����
Index       	dword	?           		; �������е����
Count   	dword 	?             	; ���ҵĴ���
szFmt		byte 	'Index=%d Count=%d Element=%d', 0ah, 0 ; ��ʽ�ַ���
szErrMsg	byte	'Not found, Count=%d Element=%d', 0ah, 0 
.code
start:
       mov	Index, -1             	; ����ֵ, �����Ҳ���
       mov  	Count, 0           	; ����ֵ, ���Ҵ���Ϊ0
       mov 	esi, 0             	; ECX��ʾ���ҷ�Χ���½�
       mov 	edi, Items-1      	; EDX��ʾ���ҷ�Χ���Ͻ�
       mov  	al, Element        	; EAX��Ҫ�������в��ҵ�����
Compare:            
       cmp  	esi, edi           	; �½��Ƿ񳬹��Ͻ�
       jg   	notfound            	; ����½糬���Ͻ�, δ�ҵ�
       mov  	ebx, esi    	; ȡ�½���Ͻ���е�
       add   	ebx, edi    		; 
       shr	ebx, 1         			; EBX=(ESI+EDI)/2
       inc     	Count               		; ���Ҵ�����1
       cmp	al, dArray[EBX]    		; ���е��ϵ�Ԫ�رȽ�
       jz  	Found          		; ���, ���ҽ���
       ja    	MoveLow       		; �ϴ�, �ƶ��½�
       mov	edi, ebx       			; ��С, �ƶ��Ͻ�
       dec	edi             		; ESIԪ���ѱȽϹ�, ���ٱȽ�
       jmp	Compare        		; ��Χ��С��, ��������
MoveLow:    
       mov	esi, ebx          		; �ϴ�, �ƶ��½�
       inc	esi       			; ESIԪ���ѱȽϹ�, ���ٱȽ�
       jmp	Compare       		; ��Χ��С��, ��������
Found:            
       mov	Index, ebx    			; �ҵ�, EBX���±�
       xor	eax,  eax
       mov	al, dArray[esi]
       invoke 	printf, offset szFmt, Index, Count, eax
       ret
NotFound:            
       invoke	printf, offset szErrMsg, Count, Element 
       ret
end    start