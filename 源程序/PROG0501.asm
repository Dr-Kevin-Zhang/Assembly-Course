;PROG0501
       MOV   	EAX, A
       CMP    	EAX, B
       JGE     	AIsLarger    		; ���A��B����ת��AIsLarger��Ŵ�
       MOV   	EAX, B
AIsLarger:
       MOV    	MAXAB, EAX