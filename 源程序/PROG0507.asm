;PROG0507
.386
.model flat,stdcall
option casemap:none
includelib      msvcrt.lib
printf         PROTO C:ptr sbyte,:vararg 	; 用法：printf(str);
scanf         PROTO C:ptr sbyte,:vararg 	; 用法：scanf("%d", &op);
.data
Msg1	db '1——create',0ah         	; 菜单字符串
    	db '2——update',0ah
    	db '3——delete',0ah
     	db '4——print',0ah
    	db '5——quit',0ah,0
Msg2  	db 'input select:',0ah,0     	; 提示字符串
Fmt2	db '%d',0                       	; scanf的格式字符串
op   	dd ?                           	; scanf结果(用户输入的整数)
Msg3	db 'Error!',0ah,0             	; 输入错误后的显示的字符串
MsgC 	db 'Create a File',0ah,0ah,0     	; 选择菜单1后的显示的字符串
MsgU	db 'Update a File',0ah,0ah,0   	; 选择菜单2后的显示的字符串
MsgD	db 'Delete a File',0ah,0ah,0   	; 选择菜单3后的显示的字符串
MsgP 	db 'Print a File',0ah,0ah,0     	; 选择菜单4后的显示的字符串
MsgQ	db 'Quit',0ah,0              	; 选择菜单5后的显示的字符串
JmpTab	dd offset cr              	; 跳转表，保存5个标号
    	dd offset up
    	dd offset de
     	dd offset pr
     	dd offset qu
.code
start:  
  	invoke  printf,offset Msg1     	; 显示菜单      
Rdkb:
    	invoke  printf,offset Msg2    	; 显示提示 
   	invoke  scanf,offset Fmt2,offset op	; 接收用户的输入
	cmp 	op,1               	; 与1比较
	jb 	Beep                 	; 输入的数字比1小，不合法
	cmp	op,5                	; 与5比较 
	ja  	Beep                  	; 输入的数字比5大，不合法
	mov 	ebx,op
	dec 	ebx                   	; 转换为跳转表的索引
	mov  	eax, JmpTab[ebx*4]   	; 得到表项地址
	jmp 	eax	; 按表项地址转到对应的标号处
	jmp 	JmpTab[ebx*4]          	; 可以用这一指令替换上面两条
Beep:
   	invoke	printf,offset Msg3     	; 提示输入错误
   	jmp	Rdkb
CR:
    	invoke	printf,offset MsgC     	; 显示 Create a File
   	jmp	start          	; 回到主菜单，继续运行
UP:                               
   	invoke	printf,offset MsgU     	; 显示 Update a File
   	jmp	start
DE:     
    	invoke	printf,offset MsgD  	; 显示 Delete a File
   	jmp	start
PR:     
   	invoke	printf,offset MsgP   	; 显示 Print a File
    	jmp	start
QU:     
    	invoke	printf,offset MsgQ     	; 显示 Quit
     	ret                             	; 返回系统
end	start
