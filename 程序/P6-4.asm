;程序6.4
STACKSG	SEGMENT
	DW 32 DUP('S')
STACKSG	ENDS

DATA    SEGMENT
ARY     DW	1,2,3,4,5,6,7,8,9,10
COUNT   DW	($-ARY)/2	;数组元素个数
ARY2     DW	1,2,3,4,5,6,7,8,9,10,12
COUNT2   DW	($-ARY2)/2	;数组元素个数
SUM     DW	?		;数组和的地址
DATA    ENDS

CODE1   SEGMENT
MAIN    PROC	FAR
        ASSUME	CS:CODE1,DS:DATA,SS:STACKSG
        PUSH	DS
        XOR	AX,AX
        PUSH	AX
        MOV	AX,DATA
        MOV	DS,AX
        
        CALL	FAR PTR ARY_SUM
        
        RET
MAIN    ENDP
CODE1   ENDS

CODE2   SEGMENT
        ASSUME	CS:CODE2
ARY_SUM PROC	FAR		;数组求和子程序
        PUSH	AX		;保存寄存器
        PUSH	CX
        PUSH	SI

        LEA	SI,ARY		;取数组起始地址
        MOV	CX,COUNT	;取元素个数
        XOR	AX,AX		;清0累加器
NEXT:   ADD	AX,[SI]		;累加和
        ADD	SI,2		;修改地址指针
        LOOP	NEXT
        MOV	SUM,AX		;存和

        POP	SI		;恢复寄存器
        POP	CX
        POP	AX
        RET 
ARY_SUM ENDP
CODE2   ENDS
        END	MAIN