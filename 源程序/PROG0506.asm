;PROG0506
.386
.model flat,stdcall
option casemap:none
includelib    	msvcrt.lib
printf        	PROTO C :dword,:vararg
.data
dArray	dword	150, 178, 199, 200, 451, 680, 718, 820, 900, 950
ITEMS	equ	($-dArray)/4	; 数组中元素的个数
	dword	?	; 插入一个元素后,dArray要占用这个双字
Element	dword	700	; 要插入数组的数字
szFmt	byte	'dArray[%2d]=%d', 0ah, 0	; 输出结果格式字符串
.code
start:
         mov	eax, Element	; EAX是要在数组中插入的数字
         mov	esi, 0	; ESI是要比较的元素的下标
compare:            
         cmp	dArray[esi*4], eax	; 比较数组元素和要插入的数
         ja 	MoveArray	; 数组中的元素较大,不再比较
         inc 	esi	; 下标加1
         cmp	esi, ITEMS	; 是否数组元素全部已比较过
         jb	compare	; 没有,继续比较
			; 全部比较过,则ESI=ITEMS
MoveArray:		; 插入位置为ESI,从数组尾移动
         mov	edi, ITEMS?1	; EDI是要移动的元素下标
MoveOne:            
         cmp	edi, esi	; EDI和ESI比较
         jl   	InsertHere	; EDI<ESI, 已移动完成
         mov 	ebx, dArray[edi*4]	; 先取出这个元素
         mov	dArray[edi*4+4], ebx	; 向后移动1个位置
         dec  	edi	; EDI指向上一个元素
         jmp	MoveOne	; 继续移动
InsertHere:            
         mov	dArray[esi*4], eax	; 插入元素到下标为ESI的位置
         xor 	ebx, ebx	; 显示出各元素的值
PrintNext:            
         invoke	printf, offset szFmt, ebx, dArray[ebx*4]	; 显示
         inc	ebx	; EBX下标加1
         cmp	ebx, items	; 是否已全部显示完
         jbe	PrintNext	; 继续显示
         ret
         end	start
