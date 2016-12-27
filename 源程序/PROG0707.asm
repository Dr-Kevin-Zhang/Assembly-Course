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
WindowClass	byte	'GDIClass',0             	; 窗口类
WindowTitle 	byte 	'GDI API sample',0      	; 窗口标题
szMousePos 	byte 	30 dup (?)                  	; 要显示的字符串
nStrLen    	dword	?                         	; 要显示的字符串的长度
szFmt    	byte	'鼠标位置(%d,%d)     ',0    	; 字符串格式
hBitmap   	dword	?                         	; 位图句柄
hBrsh1    	dword	?                         	; 画刷1句柄    
hBrsh2    	dword	?                         	; 画刷2句柄    
hBrsh3    	dword	?                         	; 画刷3句柄    
hBrsh4    	dword	?                         	; 画刷4句柄
hInstance   	HINSTANCE ?                       	; 实例句柄
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
	mov  	hBitmap,eax                	; 从资源中装入位图
	invoke	CreateSolidBrush,0ff0000H  	; 创建4个画刷
	mov  	hBrsh1,eax
	invoke	CreateSolidBrush,000ff00H
	mov   	hBrsh2,eax
	invoke	CreateHatchBrush,HS_HORIZONTAL,00000ffH
	mov   	hBrsh3,eax
	invoke 	CreateHatchBrush,HS_DIAGCROSS,0ffff00h
	mov   	hBrsh4,eax
	mov  	eax,0                	; 返回0
	ret                            	; 表示WM_CREATE消息已被处理
on_destroy:
	invoke	DeleteObject,hBrsh1  	; 删除创建的画刷
	invoke	DeleteObject,hBrsh2
	invoke	DeleteObject,hBrsh3
	invoke	DeleteObject,hBrsh4
	invoke	DeleteObject,HBITMAP	; 删除位图资源
	invoke	PostQuitMessage,0    	; 发送一个WM_QUIT消息 
	mov  	eax,0 
	ret 
on_mousemove: 
	mov 	eax,lParam  	; lParam的高16位为y坐标，低16
位为x坐标
	movzx	ebx,ax
	shr   	eax,16
	invoke	wsprintfA,offset szMousePos,offset szFmt,EBX,EAX
	mov  	nStrLen,eax
	invoke	GetDC,hWnd       	; 调用GetDC(hWnd)得到窗口区域的
	mov  	hDC,eax          	; 设备描述表句柄
	invoke	TextOutA,hDC,20,230,offset szMousePos,nStrLen
	invoke	ReleaseDC,hWnd,hDC 	; 释放设备描述表句柄
	xor  	eax,eax
	ret        
on_paint:
	invoke	BeginPaint,hWnd,addr ps   	; 得到显示区域的hDC
	mov  	hDC,eax
	invoke	SelectObject,hDC,hBrsh1 	; 选择已创建的画刷
	invoke	Rectangle,hDC,20,10,90,220 	; 画矩形
	invoke	SelectObject,hDC,hBrsh2
	invoke	Rectangle,hDC,110,10,180,220
	invoke	SelectObject,hDC,hBrsh3
	invoke 	Rectangle,hDC,200,10,270,220
	invoke	SelectObject,hDC,hBrsh4
	invoke 	Rectangle,hDC,290,10,360,220
	invoke  	CreateCompatibleDC,hDC	; 创建hDC的内存映像hMemDC
	mov  	hMemDC,eax
	invoke 	SelectObject,hMemDC,hBitmap	; 将位图画在"屏幕内存映像"上
			; 将位图从hMemDC复制到hDC 
	invoke	BitBlt,hDC,400,10,290,210,hMemDC,0,0,SRCCOPY
	invoke	DeleteDC,hMemDC    	; 删除hMemDC
	invoke	EndPaint,hWnd,addr ps   	; 和BeginPaint()配对使用
	xor   	eax,eax
	ret
WndProc ENDP
end	_start