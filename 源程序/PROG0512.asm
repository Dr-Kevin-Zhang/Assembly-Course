;PROG0512
szStr	BYTE	'Hello World!', 0
	MOV	ESI, OFFSET szStr
g10:	
	MOV	AL, [ESI]
	CMP	AL, 0
	JZ	g30
	CMP	AL, 'A'
	JB	g20
	CMP	AL, 'Z'
	JA	g20
	ADD	AL, 'a'-'A'
	MOV	[ESI], AL
g20:
	INC	ESI
	JMP	g10
g30: