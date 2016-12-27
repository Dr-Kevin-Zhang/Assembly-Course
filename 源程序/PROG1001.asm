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
szTitle	byte    '��ʾ�Ĵ�����ֵ', 0
szFmt 	byte    'CS:EIP=%04X:%08X  SS:ESP=%04X:%08X',0dh,0ah
		byte    'EAX=%08X  EBX=%08X  ECX=%08X  EDX=%08X',0dh,0ah
		byte    'ESI=%08X  EDI=%08X  EBP=%08X  EFL=%08X',0dh,0ah
		byte    'DS=%04X  ES=%04X  FS=%04X  GS=%04X', 0dh,0ah
		byte    'TR=%04X  LDTR=%04X', 0dh,0ah
		byte    'GDTR=%08X:%04X', 0dh,0ah
		byte    'IDTR=%08X:%04X', 0dh,0ah
		byte    0
szOut 	byte    300 dup (0)
      	; 6���μĴ�������16λ��, ��Ҫ�ȱ��浽˫����, ������Ϊ
      	; wsprintf�Ĳ�����ʹ��
_CS  	dword  	0
_SS     	dword  	0
_DS      	dword  	0
_ES      	dword  	0
_FS      	dword  	0
_GS      	dword  	0
         	; �����в���ֱ��ʹ��EIP��EFLAGS�Ĵ���
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
       	mov     	word ptr _CS, cs      	; CS�μĴ���(16λ)��_CS
       	mov     	word ptr _SS, ss      	; SS�μĴ���(16λ)��_SS
       	mov     	word ptr _DS, ds      	; DS�μĴ���(16λ)��_DS
    	mov     	word ptr _ES, es      	; ES�μĴ���(16λ)��_ES
       	mov     	word ptr _FS, fs      	; FS�μĴ���(16λ)��_FS
       	mov     	word ptr _GS, gs      	; GS�μĴ���(16λ)��_GS
 	str      	word ptr _TR          	; TR(16λ)��_TR 
       	sldt     	word ptr _LDTR       	; LDTR(16λ)��_LDTR
       	sgdt     	_GDTR              	; GDTR(48λ)��_GDTR
       	sidt    	_IDTR               	; IDTR(48λ)��_IDTR
       	push    	dword ptr _GDTR+2 	; GDTR�еĻ�ַ(32λ)ѹջ
  	pop      	_GDTOFS           	; GDTR��ַ(32λ)��_GDTOFS
       	push     	word ptr 0        		; 0(16λ)ѹջ
     	push    	word ptr _GDTR    	; GDTR�е��޳�(16λ)ѹջ
       	pop     	_GDTLMT          	; GDTR�޳�(16λ)��_GDTLMT 
      	push  	dword ptr _IDTR+2  	; IDTR�еĻ�ַ(32λ)ѹջ     
 	pop    	_IDTOFS           	; IDTR��ַ(32λ)��_IDTOFS 
       	push   	word ptr 0         	; 0(16λ)ѹջ        
     	push 	word ptr _IDTR   		; IDTR�е��޳�(16λ)ѹջ     
      	pop 	_IDTLMT           	; IDTR�޳�(16λ)��_IDTLMT 
        pushfd                        		; EFLAGS������ѹջ
        pop     _EFLAGS               	; ������ŵ�EFLAGS��
        ; ����3���൱��: mov  _EIP, offset _here
        call    _here                 		; ����_here�ӳ��� 
_here:                                		; _here�ĵ�ַѹջ
        pop     _EIP                  		; ����_here�ĵ�ַ��_EIP��
      	; �������Ĵ��������ݰ�szFmt�ĸ�ʽ�����szOut�ַ�����
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