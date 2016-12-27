;PROG0703
.386p 
.model flat,stdcall 
include    windows.inc
include    user32.inc
include    kernel32.inc
include    gdi32.inc
includelib  user32.lib
includelib  kernel32.lib
includelib  gdi32.lib
public _start

.data
msgbuf   	MSG      <>
wcex        	WNDCLASSEX <>
wndClassName 	byte    'GENERIC',0
wndTitle     	byte     'ApplicationSample',0
hWindow     	dword  0

.code
_start:
    	mov 	wcex.cbSize,SIZEOF WNDCLASSEX 
    	mov  	wcex.style,CS_HREDRAW or CS_VREDRAW 
      	mov   	wcex.cbClsExtra,0 
      	mov   	wcex.cbWndExtra,0 
      	mov   	wcex.lpfnWndProc,offset WndProc 
      	invoke	GetModuleHandleA, 0
    	mov  	wcex.hInstance,eax 
    	invoke 	LoadIconA,0,IDI_WINLOGO 
    	mov   	wcex.hIcon,eax 
     	invoke 	LoadCursorA,0,IDC_ARROW 
     	mov   	wcex.hCursor,eax 
     	mov  	wcex.hbrBackground,COLOR_WINDOW+1 
     	mov   	wcex.lpszMenuName,0
     	mov   	wcex.lpszClassName,offset wndClassName 
     	invoke  	LoadIconA,0,IDI_APPLICATION 
     	mov   	wcex.hIconSm,eax 
            
      	invoke 	RegisterClassExA, offset wcex
      	cmp   	eax, 0
     	jz  	end_loop

        invoke	CreateWindowExA, 
		0,                     			; dwExStyle
		OFFSET wndClassName,   		; lpszClass
		OFFSET wndTitle,       			; lpszName
		WS_OVERLAPPEDWINDOW,  	; style
		CW_USEDEFAULT,         		; x
		CW_USEDEFAULT,         		; y
		CW_USEDEFAULT,         		; cx (width)
		CW_USEDEFAULT,         		; cy (height)
		0,                    			; hwndParent
		0,                     			; hMenu
		wcex.hInstance,        				; hInstance
		0                      			; lpCreateParams
  	cmp   	eax, 0
     	jz     	end_loop
     	mov   	hWindow, eax
      	invoke  	ShowWindow, hWindow, SW_SHOWDEFAULT 
     	invoke 	UpdateWindow, hWindow 
msg_loop:
     	invoke	GetMessageA, offset msgbuf, 0, 0, 0
     	or   	eax,eax
    	jz    	end_loop
     	invoke  	TranslateMessage, offset msgbuf
    	invoke	DispatchMessageA, offset msgbuf
	jmp    	msg_loop
end_loop:
	invoke	ExitProcess, 0

WndProc PROC hWnd:HWND,wMsg:UINT,wParam:DWORD,lParam:DWORD
	cmp	wMsg, WM_DESTROY
	je   	on_destroy
	invoke	DefWindowProcA,hWnd,wMsg,wParam,lParam 
      	ret
on_destroy:
   	invoke	PostQuitMessage, 0
      	xor	eax,eax
	ret
WndProc	endp
    	end	_start