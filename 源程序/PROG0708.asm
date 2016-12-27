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
Counter1     	dword 	?           		; ������1
Counter2    	dword 	?          		; ������2
tID1        	dword 	?           		; �߳�1�ı�ʶ
tID2        	dword 	?           		; �߳�2�ı�ʶ
AbortIt     	dword 	0          		; =1ʱ���߳��˳�ѭ��
nEvt       	dword 	0          		; �¼�����
hStdIn      	dword 	0          		; ��׼�����豸���ļ����
STD_INPUT_HANDLE 	EQU 10  		; ��׼�����豸�ľ����
.code
Thread1:                           		; �߳�1�����￪ʼִ��
           	mov 	Counter1,0
ThreadLoop1:
            	inc   	Counter1  		; ������1��1
	invoke	Sleep,500    		; ��ʱ�ȴ�500����
	cmp	AbortIt,0
	jz   	ThreadLoop1		; AbortIt=0ʱ������
	ret
Thread2:                            		; �߳�2�����￪ʼִ��
	mov	Counter2,0
ThreadLoop2:
	inc  	Counter2 		; ������2��1
	invoke	Sleep,1000 		; ��ʱ�ȴ�1��
	cmp 	AbortIt,0
	jz  	ThreadLoop2  	; AbortIt=0ʱ������
	ret             
start:
        	invoke  	GetStdHandle,STD_INPUT_HANDLE
         	mov     	hStdIn,eax
           	invoke	CreateThread,0,0,addr Thread1,0,0,addr tID1
          	invoke	CreateThread,0,0,addr Thread2,0,0,addr tID2
loopHere:                
       	invoke  	Sleep,250  		; ��ʱ�ȴ�250����
	invoke  	printf,offset szMsgOut,Counter1,Counter2
	invoke  	GetNumberOfConsoleInputEvents,hStdIn,addr nEvt
	cmp   	nEvt,0
	jz     	loopHere  		; nEvt=0, û���¼�������
	mov  	AbortIt,1  		; AbortIt=1��ʹ�����߳̽���
	invoke	printf,offset szMsgStop
	call  	getchar  			; �ȴ��û�����س���
	ret
end      	start