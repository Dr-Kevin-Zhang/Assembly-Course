;PROG0503
X         	SDWORD	-45
SIGNX     	SDWORD  	?
         	MOV      	SIGNX, 0 
          	CMP      	X, 0     
         	JGE       	XisPostive        ; X��0����ת
          	MOV      	SIGNX, -1 
           	JMP       	HERE           ; ������MOV SIGNX, 1�����
XisPostive:                     
             	MOV     	SIGNX, 1 
HERE: