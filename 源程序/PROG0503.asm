;PROG0503
X         	SDWORD	-45
SIGNX     	SDWORD  	?
         	MOV      	SIGNX, 0 
          	CMP      	X, 0     
         	JGE       	XisPostive        ; X¡Ý0£¬Ìø×ª
          	MOV      	SIGNX, -1 
           	JMP       	HERE           ; Ìø¹ý¡°MOV SIGNX, 1¡±Óï¾ä
XisPostive:                     
             	MOV     	SIGNX, 1 
HERE: