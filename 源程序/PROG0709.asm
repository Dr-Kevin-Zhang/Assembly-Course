;PROG0709
.386
.model flat,stdcall
includelib     	msvcrt.lib
includelib     	kernel32.lib
printf         	PROTO C :dword,:vararg
CreateThread  	PROTO :dword,:dword,:dword,:dword,:dword,:dword
.data
szMsgOut     	byte    	'Counter=%d',0ah,0
Counter       	dword  	?           		; ������
tID1          	dword  	?            	; �߳�1�ı�ʶ
tID2          	dword  	?           		; �߳�2�ı�ʶ
StoppedThread  	dword 	0          		; �ѽ������߳���
.code
Thread1:                             		; �߳�1�����￪ʼִ��
            	mov 	ecx,100000000
ThreadLoop1:
              	mov 	eax,Counter  		; ��������1
           	inc   	eax
	mov  	Counter,eax
            	loop   	ThreadLoop1   	; ѭ��ECX��
             	inc    	StoppedThread
             	ret
Thread2:                             		; �߳�2�����￪ʼִ��
              	mov   	ecx,100000000
ThreadLoop2:
             	mov   	eax,Counter 		; ��������1
             	dec    	eax
              	mov   	Counter,eax
             	loop  	ThreadLoop2  	; ѭ��ECX��
             	inc    	StoppedThread
             	ret
start:
         	invoke	CreateThread,0,0,addr Thread1,0,0,addr tID1
            	invoke	CreateThread,0,0,addr Thread2,0,0,addr tID2
loopHere:                
             	cmp   	StoppedThread,2
             	jb     	loopHere    		; �ȴ��߳�1���߳�2����
             	invoke	printf,offset szMsgOut,Counter
             	ret
end          	start