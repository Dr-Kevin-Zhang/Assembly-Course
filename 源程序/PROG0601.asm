;PROG0601
CODE 	SEGMENT
MAIN		PROC	FAR
		��
		CALL	SUB1
		��
		CALL	SUB2
		��
		RET
MAIN		ENDP
; SUB1�ӳ���˵��
SUB1		PROC	
		;һ����ջָ�����PUSH
;����ΪSUB1����ʵ��
		��
		;һ���ջָ�����POP
		RET
SUB1		ENDP
; SUB2�ӳ���˵��
SUB2		PROC	
		;һ����ջָ�����PUSH
;����ΪSUB2����ʵ��
		��
		;һ���ջָ�����POP
		RET
SUB2		ENDP
CODE		ENDS
		END	MAIN