;PROG0704
IDM_CHANGE	= 40000
IDM_EXIT   	= 40001
IDM_ABOUT 	= 40002

menuName   	byte	'MAINMENU',0
aText        	byte 	'Menu Sample', 0
aTitle        	byte  	'Hello!', 0

	mov 	wcex.lpszMenuName, offset menuName

WndProc	PROC hWnd:HWND,wMsg:UINT,wParam:DWORD,lParam:DWORD
  	cmp 	wMsg, WM_DESTROY
    	je    	on_destroy
    	cmp  	wMsg, WM_COMMAND
	je     	on_command
	invoke	DefWindowProcA,hWnd,wMsg,wParam,lParam 
	ret
on_destroy:
	invoke	PostQuitMessage, 0
	xor	eax,eax
        	ret
on_command:
        	cmp  	wParam, IDM_CHANGE
        	je  	on_change
        	cmp 	wParam, IDM_EXIT
        	je   	on_exit
        	cmp  	wParam, IDM_ABOUT
        	je    	on_about
        	invoke	DefWindowProcA,hWnd,wMsg,wParam,lParam 
        	ret
on_change:
        	invoke	SetWindowTextA,hWnd,offset aTitle
        	mov  	eax,0 
        	ret 
on_exit:
        	invoke	SendMessageA,hWnd,WM_CLOSE,0,0 
        	mov  	eax,0 
        	ret 
on_about:
        	invoke	MessageBoxA,hWnd,offset aText,offset aTitle,MB_OK
        	mov  	eax,0 
        	ret 
WndProc 	endp