.386
.model flat, stdcall
option casemap:none

; ˵���������õ��Ŀ⡢����ԭ�ͺͳ���
includelib      msvcrt.lib
printf          PROTO C :dword, :VARARG
scanf           PROTO C :dword, :VARARG

; ������
.data
SizeMsg         byte    '������Ҫ��������ݸ���:', 0
InMsg           byte    '%d', 0
OutMsg          byte    '%d,', 0
EndMsg          byte    '%d', 0ah, 0
swap            byte    0
x               dword   0
n               dword   0
darray          dword   100 dup (0)
InputMsg        byte    '����������:', 0ah, 0
OutputMsg       byte    '������:', 0ah, 0 

; ������
.code
start:
                invoke  printf, offset SizeMsg               ;��ʾ��ʾ��Ϣ
                invoke  scanf, offset InMsg, offset n        ;����n
                invoke  printf, offset InputMsg
                xor     esi, esi
L1:
                invoke  scanf, offset InMsg, offset x        ;�������������
                mov     eax, x
                mov     darray[esi*4], eax
                inc     esi
                cmp     esi, n
                jb      L1                                   ;ѭ������ 
i00:
                mov     ecx, n
                dec     ecx
i10:
                mov     swap, 0                              ;��swap��ʼ��Ϊ0 
                xor     esi, esi
i20:
                mov     eax, darray[esi*4]
                mov     ebx, darray[esi*4+4]
                cmp     eax, ebx                             ;�Ƚ���������С 
                jg      i30
                mov     darray[esi*4], ebx                   ;��ǰ�ߵ���С�ں�ߵ������򽻻�λ�� 
                mov     darray[esi*4+4], eax
                inc     swap                                 ;��������������swap��1 
i30:
                inc     esi
                cmp     esi, ecx
                jb      i20                                  ;�ڲ�ѭ�� 
                cmp     swap, 0                              ;��û����������������ѭ�� 
                je      i40
                loop    i10                                  ;������������ѭ������С��n-1���������һ��ѭ�� 
i40:
                dec     n
                xor     esi, esi
                cmp     esi, n                               ;��ֻ��һ��������ֱ����� 
                je      E
L2:
                invoke  printf, offset OutMsg, darray[esi*4] ;������ս��
                inc     esi
                cmp     esi, n
                jb      L2                                   ;ѭ����� 
E:
                invoke  printf, offset EndMsg, darray[esi*4]
                ret
end             start
