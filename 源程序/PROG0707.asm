;PROG0707
.386p
.model flat,stdcall
include       windows.inc
include       user32.inc
include       kernel32.inc
include       gdi32.inc
includelib     user32.lib
includelib     kernel32.lib
includelib     gdi32.lib
IDB_BITMAP  =    103
.data 
WindowClass	byte	'GDIClass',0             	; ������
WindowTitle 	byte 	'GDI API sample',0      	; ���ڱ���
szMousePos 	byte 	30 dup (?)                  	; Ҫ��ʾ���ַ���
nStrLen    	dword	?                         	; Ҫ��ʾ���ַ����ĳ���
szFmt    	byte	'���λ��(%d,%d)     ',0    	; �ַ�����ʽ
hBitmap   	dword	?                         	; λͼ���
hBrsh1    	dword	?                         	; ��ˢ1���    
hBrsh2    	dword	?                         	; ��ˢ2���    
hBrsh3    	dword	?                         	; ��ˢ3���    
hBrsh4    	dword	?                         	; ��ˢ4���
hInstance   	HINSTANCE ?                       	; ʵ�����
hMainWnd  	HWND    ? 
wcex      	WNDCLASSEX <> 
msg       	MSG     <>
.code
_start:
  	mov	wcex.cbSize,SIZEOF WNDCLASSEX 
   	mov	wcex.style,CS_HREDRAW or CS_VREDRAW 
	mov	wcex.cbClsExtra,0 
	mov	wcex.cbWndExtra,0 
	mov 	wcex.lpfnWndProc,OFFSET WndProc 
	invoke	GetModuleHandle,NULL
	mov  	hInstance,eax 
	mov 	wcex.hInstance,eax 
	invoke	LoadIconA,hInstance,IDI_APPLICATION 
	mov 	wcex.hIcon,eax 
	invoke	LoadCursorA,0,IDC_ARROW 
	mov	wcex.hCursor,eax 
	mov  	wcex.hbrBackground,COLOR_WINDOW+1 
	mov	wcex.lpszMenuName,0 
	mov 	wcex.lpszClassName,OFFSET WindowClass 
	invoke	LoadIconA,hInstance,IDI_APPLICATION 
	mov 	wcex.hIconSm,eax 
	invoke	RegisterClassExA,addr wcex 
	invoke	CreateWindowExA,0,addr WindowClass,addr WindowTitle,
		    WS_OVERLAPPEDWINDOW,
		    100,100,720,300,
		    0,0,hInstance,NULL 
	mov 	hMainWnd,eax 
	invoke	ShowWindow,hMainWnd,SW_SHOWNORMAL 
	invoke	UpdateWindow,hMainWnd 
message_loop: 
	invoke	GetMessage,addr msg,NULL,0,0 
	cmp  	eax,0
	je    	message_exit
	invoke	TranslateMessage,addr msg 
	invoke	DispatchMessage,addr msg 
	jmp   	message_loop
message_exit:
	mov  	eax,msg.wParam
	ret 

WndProc	proc hWnd:DWORD,wMsg:DWORD,wParam:DWORD,lParam:DWORD
	local	hDC:HDC,hMemDC:HDC 
	local	ps:PAINTSTRUCT 
	cmp 	wMsg,WM_CREATE
	jz    	on_create
	cmp 	wMsg,WM_DESTROY
	jz    	on_destroy
	cmp  	wMsg,WM_MOUSEMOVE
	jz   	on_mousemove
	cmp  	wMsg,WM_PAINT
	jz   	on_paint
	invoke	DefWindowProcA,hWnd,wMsg,wParam,lParam 
	ret 
on_create:
	invoke	LoadBitmap,hInstance,IDB_BITMAP
	mov  	hBitmap,eax                	; ����Դ��װ��λͼ
	invoke	CreateSolidBrush,0ff0000H  	; ����4����ˢ
	mov  	hBrsh1,eax
	invoke	CreateSolidBrush,000ff00H
	mov   	hBrsh2,eax
	invoke	CreateHatchBrush,HS_HORIZONTAL,00000ffH
	mov   	hBrsh3,eax
	invoke 	CreateHatchBrush,HS_DIAGCROSS,0ffff00h
	mov   	hBrsh4,eax
	mov  	eax,0                	; ����0
	ret                            	; ��ʾWM_CREATE��Ϣ�ѱ�����
on_destroy:
	invoke	DeleteObject,hBrsh1  	; ɾ�������Ļ�ˢ
	invoke	DeleteObject,hBrsh2
	invoke	DeleteObject,hBrsh3
	invoke	DeleteObject,hBrsh4
	invoke	DeleteObject,HBITMAP	; ɾ��λͼ��Դ
	invoke	PostQuitMessage,0    	; ����һ��WM_QUIT��Ϣ 
	mov  	eax,0 
	ret 
on_mousemove: 
	mov 	eax,lParam  	; lParam�ĸ�16λΪy���꣬��16
λΪx����
	movzx	ebx,ax
	shr   	eax,16
	invoke	wsprintfA,offset szMousePos,offset szFmt,EBX,EAX
	mov  	nStrLen,eax
	invoke	GetDC,hWnd       	; ����GetDC(hWnd)�õ����������
	mov  	hDC,eax          	; �豸��������
	invoke	TextOutA,hDC,20,230,offset szMousePos,nStrLen
	invoke	ReleaseDC,hWnd,hDC 	; �ͷ��豸��������
	xor  	eax,eax
	ret        
on_paint:
	invoke	BeginPaint,hWnd,addr ps   	; �õ���ʾ�����hDC
	mov  	hDC,eax
	invoke	SelectObject,hDC,hBrsh1 	; ѡ���Ѵ����Ļ�ˢ
	invoke	Rectangle,hDC,20,10,90,220 	; ������
	invoke	SelectObject,hDC,hBrsh2
	invoke	Rectangle,hDC,110,10,180,220
	invoke	SelectObject,hDC,hBrsh3
	invoke 	Rectangle,hDC,200,10,270,220
	invoke	SelectObject,hDC,hBrsh4
	invoke 	Rectangle,hDC,290,10,360,220
	invoke  	CreateCompatibleDC,hDC	; ����hDC���ڴ�ӳ��hMemDC
	mov  	hMemDC,eax
	invoke 	SelectObject,hMemDC,hBitmap	; ��λͼ����"��Ļ�ڴ�ӳ��"��
			; ��λͼ��hMemDC���Ƶ�hDC 
	invoke	BitBlt,hDC,400,10,290,210,hMemDC,0,0,SRCCOPY
	invoke	DeleteDC,hMemDC    	; ɾ��hMemDC
	invoke	EndPaint,hWnd,addr ps   	; ��BeginPaint()���ʹ��
	xor   	eax,eax
	ret
WndProc ENDP
end	_start