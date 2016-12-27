;程序6.6
STACKSG SEGMENT
	DW 16 DUP(?)
STACKSG ENDS

DATA    SEGMENT
ARY     DW	1,2,3,4,5,6,7,8,9,10
COUNT   DW	($-ARY)/2
SUM     DW	?
DATA    ENDS

CODE1   SEGMENT
MAIN    PROC	FAR
	ASSUME	CS:CODE1,DS:DATA
	PUSH	DS		;⑴
	XOR	AX,AX
	PUSH	AX		;⑵
	MOV	AX,DATA
	MOV	DS,AX
	
	LEA	BX,ARY
	PUSH	BX		;⑶压入数组起始地址
	LEA	BX,COUNT
	PUSH	BX		;⑷压入元素个数地址
	LEA	BX,SUM
	PUSH	BX		;⑸压入和地址
	CALL	FAR PTR ARY_SUM
				;⑹调用求和子程序
	RET			;⒅
MAIN    ENDP
CODE1   ENDS

CODE2   SEGMENT
        ASSUME CS:CODE2
ARY_SUM PROC	FAR		;数组求和子程序
	PUSH	BP		;⑺保存BP值
	MOV	BP,SP		;BP是堆栈数据的地址指针
	PUSH	AX		;⑻保存寄存器内容
	PUSH	CX		;⑼
	PUSH	SI		;⑽
	PUSH	DI		;⑾
				;MOV	BP,SP
	MOV	SI,[BP+10]	;得到数组起始地址
	MOV	DI,[BP+8]	;得到元素个数地址
	MOV	CX,[DI]		;得到元素个数
	MOV	DI,[BP+6]	;得到和地址
	XOR	AX,AX
NEXT:   ADD	AX,[SI]		;累加
	ADD	SI,2		;修改地址指针
	LOOP	NEXT
	MOV	[DI],AX		;存和
	
	POP	DI		;⑿恢复寄存器内容
	POP	SI			;⒀
	POP	CX		;⒁	
	POP	AX		;⒂
	POP	BP		;⒃
	RET	6		;⒄返回并调整SP指针
ARY_SUM ENDP
CODE2   ENDS
        END  MAIN

