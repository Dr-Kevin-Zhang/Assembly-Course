;PROG0501
       MOV   	EAX, A
       CMP    	EAX, B
       JGE     	AIsLarger    		; 如果A≥B，跳转到AIsLarger标号处
       MOV   	EAX, B
AIsLarger:
       MOV    	MAXAB, EAX