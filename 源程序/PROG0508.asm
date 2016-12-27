;PROG0508
COM_TAB DB 		'g'               		;命令跳转表
     	DW      	OFFSET G_COM    	   
     	DB       	'r'                
     	DW      	OFFSET R_COM       
     	DB       	't'                
     	DW      	OFFSET T_COM       
     	DB       	'q'                
     	DW      	OFFSET Q_COM       
COUNT  	EQU ($-COM_TAB)/3    			;命令个数
M1:   						;输入命令字母在AL中（略）  
   		MOV     	AL,COM_BUF+2  		;取命令字母
   	OR      	AL,20H        			;使命令字母为小写
   	LEA     	SI,COM_TAB 			;建立跳转表指针
    		MOV    	CX,COUNT          
M2: 	CMP     	AL,[SI]       			;比较命令字母
  	JE        	M3             			;相等转移执行相应命令
	ADD     	SI,3           			;不等指针指向下一个命令字母
	LOOP    	M2
                        				;输入无效命令处理（略）
    	JMP      	M1
M3: 	CALL    	WORD PTR [SI+1] 		;调用命令处理子程序   
	JNC      	EXIT         			;若选择的是Q命令则准备退出
  	JMP      	M1          			;转到输入命令处
EXIT: 	RET
G_COM	PROC               				; G命令子程序
	STC
	RET
G_COM 	ENDP
R_COM 	PROC         			; R命令子程序
	STC
     	RET
R_COM 	ENDP
T_COM 	PROC         			; T命令子程序
	STC
	RET
T_COM	ENDP
Q_COM 	PROC              			; Q命令子程序
 	CLC
      	RET
Q_COM 	ENDP