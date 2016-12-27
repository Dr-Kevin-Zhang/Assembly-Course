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
Counter      	dword 	?               		; ������
tID1         	dword 	?               		; �߳�1�ı�ʶ
tID2         	dword 	?               		; �߳�2�ı�ʶ
StoppedThread 	dword 	0                		; �ѽ������߳���
szMutex      	byte  	'MyCounterMutex',0 	; ������������
hMutex       	dword	?                 	; ���������
.code
Thread1:                          			; �߳�1�����￪ʼִ��
             	mov 	ecx,10000
ThreadLoop1:
            	push  	ecx
            	invoke 	WaitForSingleObject,hMutex,INFINITE
            	mov   	eax,Counter 			; ��������1
            	inc    	eax
            	mov	Counter,eax
            	invoke	ReleaseMutex,hMutex
             	pop  	ecx
            	loop 	ThreadLoop1 			; ѭ��ECX��
            	inc   	StoppedThread
            	ret
Thread2:                         				; �߳�2�����￪ʼִ��
            	mov  	ecx,10000
ThreadLoop2:
           	push  	ecx
            	invoke	WaitForSingleObject,hMutex,INFINITE
            	mov   	eax,Counter  			; ��������1
            	dec   	eax
            	mov 	Counter,eax
            	invoke	ReleaseMutex,hMutex
           	pop   	ecx
          	loop  	ThreadLoop2 			; ѭ��ECX��
          	inc  	StoppedThread
            	ret
start:
             	;����������
          	invoke	CreateMutex,NULL,FALSE,offset szMutex
         	mov   	hMutex,eax
            	invoke	CreateThread,0,0,addr Thread1,0,0,addr tID1
            	invoke	CreateThread,0,0,addr Thread2,0,0,addr tID2
loopHere:                
             	cmp   	StoppedThread,2
         	jb     	loopHere   			; �ȴ��߳�1���߳�2����
            	invoke	CloseHandle,hMutex
            	invoke	printf,offset szMsgOut,Counter
            	ret
end       	start