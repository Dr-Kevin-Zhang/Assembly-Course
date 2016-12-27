;PROG0706
.386p 
.model flat,stdcall 
include     windows.inc
include     user32.inc
include     kernel32.inc
include     gdi32.inc
includelib   user32.lib
includelib   kernel32.lib
includelib   gdi32.lib
public _start

IDC_EDIT    	=3000 
IDC_INSERT  	=3001 
IDC_EXIT    	=3002 
IDC_INFO   	=3003

.data 
ClassName  		byte "DLGCLASS",0 
DlgName   		byte "MyDialog",0 
AppName   		byte "Dialog Box",0 
EmptyString 		byte 0 

.code 
_start 	proc 
    	local   	wc:WNDCLASSEX 
    	local   	msg:MSG 
    	local   	hDlg:HWND
     	local	hInstance:HINSTANCE
    	mov   	wc.cbSize,SIZEOF WNDCLASSEX 
     	mov   	wc.style,CS_HREDRAW or CS_VREDRAW 
     	mov   	wc.lpfnWndProc,OFFSET WndProc 
    	mov   	wc.cbClsExtra,NULL 
    	mov 	wc.cbWndExtra,DLGWINDOWEXTRA 
    	invoke	GetModuleHandle,NULL 
     	mov   	wc.hInstance,eax
     	mov   	hInstance,eax
     	mov   	wc.hbrBackground,COLOR_BTNFACE+1 
     	mov   	wc.lpszMenuName,NULL 
     	mov   	wc.lpszClassName,OFFSET ClassName 
    	invoke	LoadIcon,NULL,IDI_APPLICATION 
    	mov   	wc.hIcon,eax 
     	mov   	wc.hIconSm,eax 
     	invoke	LoadCursor,NULL,IDC_ARROW 
     	mov    	wc.hCursor,eax 
      	invoke	RegisterClassEx,addr wc 
     	invoke	CreateDialogParam,hInstance,ADDR DlgName,0,0,0
     	mov   	hDlg,eax 
     	invoke 	ShowWindow,hDlg,SW_SHOWNORMAL 
     	invoke 	UpdateWindow,hDlg 
     	invoke 	GetDlgItem,hDlg,IDC_EDIT 
    	invoke 	SetFocus,eax 
message_loop: 
   	invoke 	GetMessage,ADDR msg,NULL,0,0 
     	cmp     	eax,0
     	je        	message_exit
     	invoke  	IsDialogMessage,hDlg,ADDR msg 
     	cmp     	eax,0
    	jne      	message_loop
    	invoke  	TranslateMessage,ADDR msg 
    	invoke  	DispatchMessage,ADDR msg 
     	jmp  	message_loop
message_exit:
      	mov    	eax,msg.wParam 
      	ret 
_start	ENDP 

WndProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM 
     	local	szText£Û256£Ý:byte
     	cmp   	uMsg,WM_DESTROY
     	je    	on_destroy
     	cmp  	uMsg,WM_COMMAND
 	je    	on_command
on_default:
   	invoke	DefWindowProc,hWnd,uMsg,wParam,lParam 
     	ret 
on_destroy:
	invoke  	PostQuitMessage,NULL 
	xor     	eax,eax 
	ret 
on_command:
	mov   	eax,wParam 
	mov    	edx,wParam 
	shr    	edx,16     
	cmp    	dx,BN_CLICKED
	jne    	on_default
	cmp    	ax,IDC_INSERT 
	je     	on_InsertClicked
	cmp   	ax,IDC_EXIT 
	je      	on_ExitClicked
	jmp    	on_default
on_InsertClicked:
	invoke	GetDlgItemText,hWnd,IDC_EDIT,
		addr szText,sizeof szText
	invoke	SendDlgItemMessage,hWnd,IDC_INFO,
		LB_INSERTSTRING,0,addr szText
	invoke	SetDlgItemText,hWnd,IDC_EDIT,ADDR EmptyString
	xor   	eax,eax 
	ret 
on_ExitClicked: 
	invoke 	PostQuitMessage,0
	xor   	eax,eax
	ret
WndProc endp 
end	_start 