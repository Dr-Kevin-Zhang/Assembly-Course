;PROG0702
.386
.model flat,stdcall
includelib         msvcrt.lib
printf            PROTO C :dword,:vararg
.data
szOut1	byte  	'argc=%d', 0AH, 0
szOut2 	byte	'argv [%d]="%s"', 0AH, 0
.code
main  	proc 	C argc, argv

     	invoke	printf, offset szOut1, argc    			;��ʾargc

      	mov  	ebx, argv                  			;EBX=argv
      	xor 	esi, esi                      	   	;ESI=i
a10:                                                    
      	mov  	edi, [ebx+esi*4]            			;ȡ��argv��i��
     	invoke	printf, offset szOut2, esi, edi				;��ʾi, argv��i��
      	inc    	esi                        			;i++
     	cmp 	esi, argc                          
     	jb   	a10                            		;i < argc, ����

      	mov 	eax, argc                  			;����ֵ��Ϊargc
      	ret
main 	endp    
end