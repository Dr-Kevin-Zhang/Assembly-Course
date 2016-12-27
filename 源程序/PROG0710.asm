;PROG0710
.386
.model flat,stdcall
option casemap :none
include   	windows.inc
include    	kernel32.inc
includelib  	msvcrt.lib
includelib  	kernel32.lib
printf     	PROTO C :dword,:vararg
.data
szMsgOut    	byte 	'Counter=%d',0ah,0
Counter      	dword 	?               		; 计数器
tID1         	dword 	?               		; 线程1的标识
tID2         	dword 	?               		; 线程2的标识
StoppedThread 	dword 	0                		; 已结束的线程数
szMutex      	byte  	'MyCounterMutex',0 	; 互斥锁的名称
hMutex       	dword	?                 	; 互斥锁句柄
.code
Thread1:                          			; 线程1从这里开始执行
             	mov 	ecx,10000
ThreadLoop1:
            	push  	ecx
            	invoke 	WaitForSingleObject,hMutex,INFINITE
            	mov   	eax,Counter 			; 计数器加1
            	inc    	eax
            	mov	Counter,eax
            	invoke	ReleaseMutex,hMutex
             	pop  	ecx
            	loop 	ThreadLoop1 			; 循环ECX次
            	inc   	StoppedThread
            	ret
Thread2:                         				; 线程2从这里开始执行
            	mov  	ecx,10000
ThreadLoop2:
           	push  	ecx
            	invoke	WaitForSingleObject,hMutex,INFINITE
            	mov   	eax,Counter  			; 计数器减1
            	dec   	eax
            	mov 	Counter,eax
            	invoke	ReleaseMutex,hMutex
           	pop   	ecx
          	loop  	ThreadLoop2 			; 循环ECX次
          	inc  	StoppedThread
            	ret
start:
             	;创建互斥锁
          	invoke	CreateMutex,NULL,FALSE,offset szMutex
         	mov   	hMutex,eax
            	invoke	CreateThread,0,0,addr Thread1,0,0,addr tID1
            	invoke	CreateThread,0,0,addr Thread2,0,0,addr tID2
loopHere:                
             	cmp   	StoppedThread,2
         	jb     	loopHere   			; 等待线程1和线程2结束
            	invoke	CloseHandle,hMutex
            	invoke	printf,offset szMsgOut,Counter
            	ret
end       	start