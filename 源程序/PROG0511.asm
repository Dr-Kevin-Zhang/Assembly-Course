;PROG0511
.386
.model flat,stdcall
option casemap:none
includelib	msvcrt.lib
printf  	PROTO C :dword,:vararg
.data
x  	dword	1,2,3,4,5,6,7,8,9,10
y     	dword	5,4,3,2,1,10,9,8,7,6
Rule	dword	0000000011011100B
z    	dword	10 dup (?)
szFmt	byte	'Z[%d]=%d', 0ah, 0  	;输出结果格式字符串
.code
start:
     	mov	ecx,10            	;循环次数
      	mov	edx,Rule           	;逻辑尺
	mov	ebx,0
next:
	mov	eax,x[ebx]        	;取X中的一个数
	shr	edx,1              	;逻辑尺右移一位
	jc	subs               	;分支判断并实现转移
	add	eax,y[ebx]        	;两数加
	jmp	short result
subs:
	sub	eax,y[ebx]     	;两数减
result: 
	mov	z[ebx],eax      	;存结果
	add	ebx,4            	;修改地址指针
	loop	next
	xor	ebx, ebx          	;显示出各元素的值
PrintNext:            
	invoke	printf, offset szFmt, ebx, Z[ebx*4] ; 显示
	inc	ebx     	;EBX下标加1
	cmp 	ebx,10  	;是否已全部显示完
	jb 	PrintNext 	;继续显示
	ret
	end	start