;PROG0601
CODE 	SEGMENT
MAIN		PROC	FAR
		…
		CALL	SUB1
		…
		CALL	SUB2
		…
		RET
MAIN		ENDP
; SUB1子程序说明
SUB1		PROC	
		;一组入栈指令，例如PUSH
;以下为SUB1功能实现
		…
		;一组出栈指令，例如POP
		RET
SUB1		ENDP
; SUB2子程序说明
SUB2		PROC	
		;一组入栈指令，例如PUSH
;以下为SUB2功能实现
		…
		;一组出栈指令，例如POP
		RET
SUB2		ENDP
CODE		ENDS
		END	MAIN