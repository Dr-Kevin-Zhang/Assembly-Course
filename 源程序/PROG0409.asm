;PROG0409���ļ���Ϊhello.asm
.386
.model flat, stdcall
option casemap:none
; ˵���������õ��Ŀ⡢����ԭ�ͺͳ���
includelib      msvcrt.lib
printf          PROTO C :ptr sbyte, :VARARG
; ������
.data
szMsg           byte    "Hello World! ", 0ah, 0
; ������
.code
start:
                invoke  printf, offset szMsg
                ret
end             start