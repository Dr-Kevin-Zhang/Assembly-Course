.386
.model flat, stdcall
option casemap:none

; 说明程序中用到的库、函数原型和常量
includelib      msvcrt.lib
printf          PROTO C :dword, :VARARG
scanf           PROTO C :dword, :VARARG

; 数据区
.data
SizeMsg         byte    '请输入要排序的数据个数:', 0
InMsg           byte    '%d', 0
OutMsg          byte    '%d,', 0
EndMsg          byte    '%d', 0ah, 0
swap            byte    0
x               dword   0
n               dword   0
darray          dword   100 dup (0)
InputMsg        byte    '请输入数据:', 0ah, 0
OutputMsg       byte    '排序结果:', 0ah, 0 

; 代码区
.code
start:
                invoke  printf, offset SizeMsg               ;显示提示信息
                invoke  scanf, offset InMsg, offset n        ;输入n
                invoke  printf, offset InputMsg
                xor     esi, esi
L1:
                invoke  scanf, offset InMsg, offset x        ;输入待排序数组
                mov     eax, x
                mov     darray[esi*4], eax
                inc     esi
                cmp     esi, n
                jb      L1                                   ;循环输入 
i00:
                mov     ecx, n
                dec     ecx
i10:
                mov     swap, 0                              ;将swap初始化为0 
                xor     esi, esi
i20:
                mov     eax, darray[esi*4]
                mov     ebx, darray[esi*4+4]
                cmp     eax, ebx                             ;比较两个数大小 
                jg      i30
                mov     darray[esi*4], ebx                   ;若前边的数小于后边的数，则交换位置 
                mov     darray[esi*4+4], eax
                inc     swap                                 ;若发生交换，则swap加1 
i30:
                inc     esi
                cmp     esi, ecx
                jb      i20                                  ;内层循环 
                cmp     swap, 0                              ;若没发生交换，则跳出循环 
                je      i40
                loop    i10                                  ;若发生交换且循环次数小于n-1，则继续下一轮循环 
i40:
                dec     n
                xor     esi, esi
                cmp     esi, n                               ;若只有一个数，则直接输出 
                je      E
L2:
                invoke  printf, offset OutMsg, darray[esi*4] ;输出最终结果
                inc     esi
                cmp     esi, n
                jb      L2                                   ;循环输出 
E:
                invoke  printf, offset EndMsg, darray[esi*4]
                ret
end             start
