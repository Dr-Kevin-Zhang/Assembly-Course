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

     	invoke	printf, offset szOut1, argc    			;显示argc

      	mov  	ebx, argv                  			;EBX=argv
      	xor 	esi, esi                      	   	;ESI=i
a10:                                                    
      	mov  	edi, [ebx+esi*4]            			;取得argv［i］
     	invoke	printf, offset szOut2, esi, edi				;显示i, argv［i］
      	inc    	esi                        			;i++
     	cmp 	esi, argc                          
     	jb   	a10                            		;i < argc, 继续

      	mov 	eax, argc                  			;返回值设为argc
      	ret
main 	endp    
end