;PROG0508
COM_TAB DB 		'g'               		;������ת��
     	DW      	OFFSET G_COM    	   
     	DB       	'r'                
     	DW      	OFFSET R_COM       
     	DB       	't'                
     	DW      	OFFSET T_COM       
     	DB       	'q'                
     	DW      	OFFSET Q_COM       
COUNT  	EQU ($-COM_TAB)/3    			;�������
M1:   						;����������ĸ��AL�У��ԣ�  
   		MOV     	AL,COM_BUF+2  		;ȡ������ĸ
   	OR      	AL,20H        			;ʹ������ĸΪСд
   	LEA     	SI,COM_TAB 			;������ת��ָ��
    		MOV    	CX,COUNT          
M2: 	CMP     	AL,[SI]       			;�Ƚ�������ĸ
  	JE        	M3             			;���ת��ִ����Ӧ����
	ADD     	SI,3           			;����ָ��ָ����һ��������ĸ
	LOOP    	M2
                        				;������Ч������ԣ�
    	JMP      	M1
M3: 	CALL    	WORD PTR [SI+1] 		;����������ӳ���   
	JNC      	EXIT         			;��ѡ�����Q������׼���˳�
  	JMP      	M1          			;ת���������
EXIT: 	RET
G_COM	PROC               				; G�����ӳ���
	STC
	RET
G_COM 	ENDP
R_COM 	PROC         			; R�����ӳ���
	STC
     	RET
R_COM 	ENDP
T_COM 	PROC         			; T�����ӳ���
	STC
	RET
T_COM	ENDP
Q_COM 	PROC              			; Q�����ӳ���
 	CLC
      	RET
Q_COM 	ENDP