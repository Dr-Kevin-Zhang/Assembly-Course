;PROG0708
.386
.model flat,stdcall
includelib   	msvcrt.lib
includelib    	kernel32.lib
printf     	PROTO C :dword,:vararg
Sleep       	PROTO :dword
CreateThread 	PROTO :dword,:dword,:dword,:dword,:dword,:dword
GetNumberOfConsoleInputEvents PROTO :dword,:dword
GetStdHandle 	PROTO nStdHandle:dword
getchar      	PROTO C
.data
szMsgOut  	byte  	'Counter1=% 3d Counter2=% 3d',0AH,0
szMsgStop  	byte   	'Thread stopped',0ah,0
Counter1     	dword 	?           		; 计数器1
Counter2    	dword 	?          		; 计数器2
tID1        	dword 	?           		; 线程1的标识
tID2        	dword 	?           		; 线程2的标识
AbortIt     	dword 	0          		; =1时，线程退出循环
nEvt       	dword 	0          		; 事件个数
hStdIn      	dword 	0          		; 标准输入设备的文件句柄
STD_INPUT_HANDLE 	EQU 10  		; 标准输入设备的句柄号
.code
Thread1:                           		; 线程1从这里开始执行
           	mov 	Counter1,0
ThreadLoop1:
            	inc   	Counter1  		; 计数器1加1
	invoke	Sleep,500    		; 延时等待500毫秒
	cmp	AbortIt,0
	jz   	ThreadLoop1		; AbortIt=0时，继续
	ret
Thread2:                            		; 线程2从这里开始执行
	mov	Counter2,0
ThreadLoop2:
	inc  	Counter2 		; 计数器2加1
	invoke	Sleep,1000 		; 延时等待1秒
	cmp 	AbortIt,0
	jz  	ThreadLoop2  	; AbortIt=0时，继续
	ret             
start:
        	invoke  	GetStdHandle,STD_INPUT_HANDLE
         	mov     	hStdIn,eax
           	invoke	CreateThread,0,0,addr Thread1,0,0,addr tID1
          	invoke	CreateThread,0,0,addr Thread2,0,0,addr tID2
loopHere:                
       	invoke  	Sleep,250  		; 延时等待250毫秒
	invoke  	printf,offset szMsgOut,Counter1,Counter2
	invoke  	GetNumberOfConsoleInputEvents,hStdIn,addr nEvt
	cmp   	nEvt,0
	jz     	loopHere  		; nEvt=0, 没有事件，继续
	mov  	AbortIt,1  		; AbortIt=1，使两个线程结束
	invoke	printf,offset szMsgStop
	call  	getchar  			; 等待用户输入回车键
	ret
end      	start