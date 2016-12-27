;PROG1001
.586
.model flat, stdcall
includelib       user32.lib
includelib       kernel32.lib
wsprintfA       PROTO C :dword,:vararg
wsprintf         equ     <wsprintfA>
MessageBoxA    PROTO stdcall   :dword,:dword,:dword,:dword
MessageBox     equ     <MessageBoxA>
ExitProcess       PROTO stdcall   :dword
NULL           equ     0
MB_OK          equ     0h
.data
szTitle	byte    '显示寄存器的值', 0
szFmt 	byte    'CS:EIP=%04X:%08X  SS:ESP=%04X:%08X',0dh,0ah
		byte    'EAX=%08X  EBX=%08X  ECX=%08X  EDX=%08X',0dh,0ah
		byte    'ESI=%08X  EDI=%08X  EBP=%08X  EFL=%08X',0dh,0ah
		byte    'DS=%04X  ES=%04X  FS=%04X  GS=%04X', 0dh,0ah
		byte    'TR=%04X  LDTR=%04X', 0dh,0ah
		byte    'GDTR=%08X:%04X', 0dh,0ah
		byte    'IDTR=%08X:%04X', 0dh,0ah
		byte    0
szOut 	byte    300 dup (0)
      	; 6个段寄存器都是16位的, 需要先保存到双字中, 才能作为
      	; wsprintf的参数来使用
_CS  	dword  	0
_SS     	dword  	0
_DS      	dword  	0
_ES      	dword  	0
_FS      	dword  	0
_GS      	dword  	0
         	; 程序中不能直接使用EIP和EFLAGS寄存器
_EIP     	dword  	0
_EFLAGS 	dword  	0
_TR     	dword   	0
_LDTR  	dword  	0
_GDTR  	fword  	0
_IDTR   	fword  	0
_GDTOFS	dword  	0
_IDTOFS	dword   	0
_GDTLMT	dword  	0
_IDTLMT	dword  	0
.code
start:
       	mov     	word ptr _CS, cs      	; CS段寄存器(16位)→_CS
       	mov     	word ptr _SS, ss      	; SS段寄存器(16位)→_SS
       	mov     	word ptr _DS, ds      	; DS段寄存器(16位)→_DS
    	mov     	word ptr _ES, es      	; ES段寄存器(16位)→_ES
       	mov     	word ptr _FS, fs      	; FS段寄存器(16位)→_FS
       	mov     	word ptr _GS, gs      	; GS段寄存器(16位)→_GS
 	str      	word ptr _TR          	; TR(16位)→_TR 
       	sldt     	word ptr _LDTR       	; LDTR(16位)→_LDTR
       	sgdt     	_GDTR              	; GDTR(48位)→_GDTR
       	sidt    	_IDTR               	; IDTR(48位)→_IDTR
       	push    	dword ptr _GDTR+2 	; GDTR中的基址(32位)压栈
  	pop      	_GDTOFS           	; GDTR基址(32位)→_GDTOFS
       	push     	word ptr 0        		; 0(16位)压栈
     	push    	word ptr _GDTR    	; GDTR中的限长(16位)压栈
       	pop     	_GDTLMT          	; GDTR限长(16位)→_GDTLMT 
      	push  	dword ptr _IDTR+2  	; IDTR中的基址(32位)压栈     
 	pop    	_IDTOFS           	; IDTR基址(32位)→_IDTOFS 
       	push   	word ptr 0         	; 0(16位)压栈        
     	push 	word ptr _IDTR   		; IDTR中的限长(16位)压栈     
      	pop 	_IDTLMT           	; IDTR限长(16位)→_IDTLMT 
        pushfd                        		; EFLAGS的内容压栈
        pop     _EFLAGS               	; 弹出后放到EFLAGS中
        ; 以下3行相当于: mov  _EIP, offset _here
        call    _here                 		; 调用_here子程序 
_here:                                		; _here的地址压栈
        pop     _EIP                  		; 弹出_here的地址到_EIP中
      	; 将各个寄存器的内容按szFmt的格式输出到szOut字符串中
        invoke	wsprintf,
		offset szOut, offset szFmt,
		_CS, _EIP, _SS, esp,
		eax, ebx, ecx, edx,
		esi, edi, ebp, _EFLAGS,
		_DS, _ES, _FS, _GS,
		_TR, _LDTR,
		_GDTOFS, _GDTLMT, 
		_IDTOFS, _IDTLMT
        invoke 	MessageBox,
		NULL, offset szOut, offset szTitle, MB_OK
        invoke	ExitProcess, 0
end     start