;PROG0412
;ʵ�֣�a+b��/d����,���������Ļ����ʾ
.386
.model  flat,stdcall
option  casemap:none
includelib       msvcrt.lib
printf  PROTO C:ptr sbyte,:VARARG
.data
szMsg 	byte   	"(a+b)/d=?",0ah,0
a       	dw    	100
b       	dw    	26
d       	dw    	5
sum    	dw   	?
res     	dw    	?
.code
start:
        invoke	printf,offset szMsg
        mov   	ax,a
        add   	ax,b
        mov   	sum,ax
        mov   	bx,d
        sub   	dx,dx
        div   	bx
        mov  	res,ax
        ret
end     start