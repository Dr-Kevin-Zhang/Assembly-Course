;PROG0506
.386
.model flat,stdcall
option casemap:none
includelib    	msvcrt.lib
printf        	PROTO C :dword,:vararg
.data
dArray	dword	150, 178, 199, 200, 451, 680, 718, 820, 900, 950
ITEMS	equ	($-dArray)/4	; ������Ԫ�صĸ���
	dword	?	; ����һ��Ԫ�غ�,dArrayҪռ�����˫��
Element	dword	700	; Ҫ�������������
szFmt	byte	'dArray[%2d]=%d', 0ah, 0	; ��������ʽ�ַ���
.code
start:
         mov	eax, Element	; EAX��Ҫ�������в��������
         mov	esi, 0	; ESI��Ҫ�Ƚϵ�Ԫ�ص��±�
compare:            
         cmp	dArray[esi*4], eax	; �Ƚ�����Ԫ�غ�Ҫ�������
         ja 	MoveArray	; �����е�Ԫ�ؽϴ�,���ٱȽ�
         inc 	esi	; �±��1
         cmp	esi, ITEMS	; �Ƿ�����Ԫ��ȫ���ѱȽϹ�
         jb	compare	; û��,�����Ƚ�
			; ȫ���ȽϹ�,��ESI=ITEMS
MoveArray:		; ����λ��ΪESI,������β�ƶ�
         mov	edi, ITEMS?1	; EDI��Ҫ�ƶ���Ԫ���±�
MoveOne:            
         cmp	edi, esi	; EDI��ESI�Ƚ�
         jl   	InsertHere	; EDI<ESI, ���ƶ����
         mov 	ebx, dArray[edi*4]	; ��ȡ�����Ԫ��
         mov	dArray[edi*4+4], ebx	; ����ƶ�1��λ��
         dec  	edi	; EDIָ����һ��Ԫ��
         jmp	MoveOne	; �����ƶ�
InsertHere:            
         mov	dArray[esi*4], eax	; ����Ԫ�ص��±�ΪESI��λ��
         xor 	ebx, ebx	; ��ʾ����Ԫ�ص�ֵ
PrintNext:            
         invoke	printf, offset szFmt, ebx, dArray[ebx*4]	; ��ʾ
         inc	ebx	; EBX�±��1
         cmp	ebx, items	; �Ƿ���ȫ����ʾ��
         jbe	PrintNext	; ������ʾ
         ret
         end	start
