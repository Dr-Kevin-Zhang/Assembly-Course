;PROG0507
.386
.model flat,stdcall
option casemap:none
includelib      msvcrt.lib
printf         PROTO C:ptr sbyte,:vararg 	; �÷���printf(str);
scanf         PROTO C:ptr sbyte,:vararg 	; �÷���scanf("%d", &op);
.data
Msg1	db '1����create',0ah         	; �˵��ַ���
    	db '2����update',0ah
    	db '3����delete',0ah
     	db '4����print',0ah
    	db '5����quit',0ah,0
Msg2  	db 'input select:',0ah,0     	; ��ʾ�ַ���
Fmt2	db '%d',0                       	; scanf�ĸ�ʽ�ַ���
op   	dd ?                           	; scanf���(�û����������)
Msg3	db 'Error!',0ah,0             	; �����������ʾ���ַ���
MsgC 	db 'Create a File',0ah,0ah,0     	; ѡ��˵�1�����ʾ���ַ���
MsgU	db 'Update a File',0ah,0ah,0   	; ѡ��˵�2�����ʾ���ַ���
MsgD	db 'Delete a File',0ah,0ah,0   	; ѡ��˵�3�����ʾ���ַ���
MsgP 	db 'Print a File',0ah,0ah,0     	; ѡ��˵�4�����ʾ���ַ���
MsgQ	db 'Quit',0ah,0              	; ѡ��˵�5�����ʾ���ַ���
JmpTab	dd offset cr              	; ��ת������5�����
    	dd offset up
    	dd offset de
     	dd offset pr
     	dd offset qu
.code
start:  
  	invoke  printf,offset Msg1     	; ��ʾ�˵�      
Rdkb:
    	invoke  printf,offset Msg2    	; ��ʾ��ʾ 
   	invoke  scanf,offset Fmt2,offset op	; �����û�������
	cmp 	op,1               	; ��1�Ƚ�
	jb 	Beep                 	; ��������ֱ�1С�����Ϸ�
	cmp	op,5                	; ��5�Ƚ� 
	ja  	Beep                  	; ��������ֱ�5�󣬲��Ϸ�
	mov 	ebx,op
	dec 	ebx                   	; ת��Ϊ��ת�������
	mov  	eax, JmpTab[ebx*4]   	; �õ������ַ
	jmp 	eax	; �������ַת����Ӧ�ı�Ŵ�
	jmp 	JmpTab[ebx*4]          	; ��������һָ���滻��������
Beep:
   	invoke	printf,offset Msg3     	; ��ʾ�������
   	jmp	Rdkb
CR:
    	invoke	printf,offset MsgC     	; ��ʾ Create a File
   	jmp	start          	; �ص����˵�����������
UP:                               
   	invoke	printf,offset MsgU     	; ��ʾ Update a File
   	jmp	start
DE:     
    	invoke	printf,offset MsgD  	; ��ʾ Delete a File
   	jmp	start
PR:     
   	invoke	printf,offset MsgP   	; ��ʾ Print a File
    	jmp	start
QU:     
    	invoke	printf,offset MsgQ     	; ��ʾ Quit
     	ret                             	; ����ϵͳ
end	start
