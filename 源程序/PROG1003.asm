;PROG1003
INCLUDE         386SCD.INC
RDataSeg          SEGMENT PARA USE16            	;ʵģʽ���ݶ�
                  ;ȫ����������
GDT              LABEL  	BYTE
                 	;��������
DUMMY         	Desc   	<>
                 	;�淶��������
Normal           	Desc   	<0FFFFH,,,ATDW,,>
                 	;��Ƶ��������������(DPL=3)
VideoBuf         	Desc   	<0FFFFH,8000H,0BH,ATDW+DPL3,,>
EFFGDT          	LABEL	BYTE
                 	;��ʾ����ľֲ���������ε�������
DemoLDTab       	Desc   	<DemoLDTLen 1,DemoLDTSeg,,ATLDT,,>
         	 	;��ʾ���������״̬��������
DemoTSS         	Desc   	<DemoTSSLen 1,DemoTSSSeg,,AT386TSS,,>
                 	;��ʱ���������״̬��������
TempTSS          	Desc   	<TempTSSLen 1,TempTSSSeg,,AT386TSS+DPL2,,>
                 	;��ʱ�����������
TempCode        	Desc   	<0FFFFH,TempCodeSeg,,ATCE,,>
                 	;�ӳ�������������
SubR             	Desc   	<SubRLen 1,SubRSeg,,ATCE,D32,>
GDNum          	=    	($ EFFGDT)/8     	;�账�����ַ������������
GDTLen          	=      	$ GDT          		;ȫ������������
VGDTR         	PDesc  	<GDTLen 1,>      	;GDTα������
SPVar           	DW     	?              		;���ڱ���ʵģʽ�µ�SP
SSVar           	DW     	?             	 	;���ڱ���ʵģʽ�µ�SS
RDataSeg        	ENDS
Normal_Sel       	=      	Normal GDT
Video_Sel        	=      	VideoBuf GDT
DemoLDT_Sel    	=       	DemoLDTab GDT
DemoTSS_Sel    	=       	DemoTSS GDT
TempTSS_Sel     	=       	TempTSS GDT
TempCode_Sel    	=        	TempCode GDT
SubR_Sel        	=        	SubR GDT
DemoLDTSeg    	SEGMENT PARA USE16     	;�ֲ������������ݶ�(16λ)
DemoLDT       	LABEL  	BYTE          	 	;�ֲ���������
                	;0����ջ��������(32λ��)
DemoStack0     	Desc   	<DemoStack0Len 1,DemoStack0Seg,,ATDW,D32,>
                	;2����ջ��������(32λ��)
DemoStack2     	Desc   	<DemoStack2Len 1,DemoStack2Seg,,ATDW+DPL2,D32,>
                	;��ʾ��������������(32λ��,DPL=2)
DemoCode       	Desc   	<DemoCodeLen 1,DemoCodeSeg,,ATCE+DPL2,D32,>
                 	;��ʾ�������ݶ�������(32λ��,DPL=3)
DemoData       	Desc 	<DemoDataLen 1,DemoDataSeg,,ATDW+DPL3,D32,>
                	;��LDT��Ϊ��ͨ���ݶ�������������(DPL=2)
ToDLDT        	Desc  	<DemoLDTLen 1,DemoLDTSeg,,ATDW+DPL2,,>
                	;��TSS��Ϊ��ͨ���ݶ�������������(DPL=2)
ToTTSS         	Desc   	<TempTSSLen 1,TempTSSSeg,,ATDW+DPL2,,>
DemoLDNum     	=      	($ DemoLDT)/(8) ;�账�����ַ��LDT��������
                	;ָ���ӳ���SubRB����εĵ�����(DPL=3)
ToSubR         	Gate   	<SubRB,SubR_Sel,,AT386CGate+DPL3,>
                	;ָ����ʱ����Temp��������(DPL=3)
ToTempT        	Gate   	<,TempTSS_Sel,,ATTaskGate+DPL3,>
DemoLDTLen   	=      	$ DemoLDT
DemoLDTSeg    	ENDS                    	;�ֲ���������ζ������
DemoStack0_Sel  	=     	DemoStack0 DemoLDT+TIL
DemoStack2_Sel   	=     	DemoStack2 DemoLDT+TIL+RPL2
DemoCode_Sel    	=      	DemoCode DemoLDT+TIL+RPL2
DemoData_Sel     	=       	DemoData DemoLDT+TIL
ToDLDT_Sel      	=       	ToDLDT DemoLDT+TIL
ToTTSS_Sel       	=       	ToTTSS DemoLDT+TIL
ToSubR_Sel       	=       	ToSubR DemoLDT+TIL+RPL2
ToTempT_Sel      	=       	ToTempT DemoLDT+TIL
DemoTSSSeg      	SEGMENT PARA USE16   	;����״̬��TSS
                 	DD    	0                	;������
                 	DD   	DemoStack0Len    	;0����ջָ��
                 	DW   	DemoStack0_Sel,0 	;0����ջѡ���
                 	DD    	0                	;1����ջָ��(ʵ����ʹ��)
                 	DW    	0,0              	;1����ջѡ���(ʵ����ʹ��)
                 	DD    	0                	;2����ջָ��
                 	DW   	0,0              	;2����ջѡ���
                 	DD    	0                	;CR3
                 	DW   	DemoBegin,0      	;EIP
                 	DD  	0                	;EFLAGS
                 	DD   	0                	;EAX
                 	DD    	0                	;ECX
                 	DD    	0                	;EDX
                 	DD    	0                	;EBX
                 	DD    	DemoStack2Len    	;ESP
                 	DD    	0                	;EBP
                 	DD   	0                	;ESI
                DD    	(80*4+50)*2      		;EDI
                DW     	Video_Sel,0         	;ES
                DW     	DemoCode_Sel,0      	;CS
                DW     	DemoStack2_Sel,0    	;SS
                DW     	DemoData_Sel,0      	;DS
                DW     	ToDLDT_Sel,0        	;FS
                DW     	ToTTSS_Sel,0        	;GS
                DW     	DemoLDT_Sel,0      	;LDTR
                DW     	0                  	;���������־
                DW     	$+2                	;ָ��I/O���λͼ
                DB     	0FFH               	;I/O���λͼ������־
DemoTSSLen     =     	$
DemoTSSSeg     ENDS                        	;����״̬��TSS����
DemoStack0Seg   SEGMENT PARA USE32       	;��ʾ����0����ջ��(32λ��)
DemoStack0Len   =    		1024
                DB     	DemoStack0Len DUP(0)
DemoStack0Seg   ENDS                     	    ;��ʾ����0����ջ�ν���
DemoStack2Seg   SEGMENT PARA USE32          	;��ʾ����2����ջ��(32λ��)
DemoStack2Len   =      	512
                DB     	DemoStack2Len DUP(0)
DemoStack2Seg   ENDS                          	;��ʾ����2����ջ�ν���
DemoDataSeg    SEGMENT PARA USE32          	;��ʾ�������ݶ�(32λ��)
Message         DB     	'EDI=',0
tableH2A        DB     	'0123456789ABCDEF'
DemoDataLen     =      	$
DemoDataSeg     ENDS                          	;��ʾ�������ݶν���
SubRSeg         SEGMENT PARA USE32          	;�ӳ�������(32λ)
                 ASSUME  CS:SubRSeg
SubRB           PROC  	FAR
                 PUSH  	EBP
                 MOV    	EBP,ESP
                 PUSH  	EDI
                 MOV   	ESI,DWORD PTR [EBP+12]	;��0��ջ��ȡ��ƫ��ESI
                 MOV   	AH,47H                		;������ʾ����
SubR1:          
                LODSB
                OR    	AL,AL
                JZ     	SubR2
                STOSW
                JMP  		short SubR1
SubR2:                
                MOV    	AH,4EH                	;������ʾ����
                MOV    	EDX,DWORD PTR [EBP+16]	;��0��ջ��ȡ����ʾֵ
                MOV    	ECX,8
SubR3:          
                ROL   	EDX,4
                MOV   	AL,DL
                AND    	AL,0FH
                MOVZX	EBX,AL
                MOV    	AL,DS:tableH2A[EBX]
                STOSW
                LOOP  	SubR3
                POP    	EDI
                ADD   	EDI,160
                POP    	EBP
                RET   	8
SubRB          ENDP
SubRLen          =     	$
SubRSeg        ENDS                           		;�ӳ������ν���
DemoCodeSeg    SEGMENT PARA USE32            	;��ʾ�����32λ�����
                ASSUME 	CS:DemoCodeSeg,DS:DemoDataSeg
DemoBegin      PROC  	FAR
                ;��Ҫ���ƵĲ����������������
                MOV   	BYTE PTR FS:ToSubR.DCount,2
                ;��2����ջ��ѹ�����
                PUSH  	EDI
                PUSH  	OFFSET Message
                ;ͨ�������ŵ���SubRB
                CALL32 	ToSubR_Sel,0
                ;ͨ���������л�����ʱ����
                JUMP32 	ToTempT_Sel,0
                JMP   	DemoBegin
DemoBegin       ENDP
DemoCodeLen    =      	$
DemoCodeSeg  	ENDS                     		;��ʾ�����32λ����ν���
TempTSSSeg   	SEGMENT PARA USE16       	;��ʱ���������״̬��TSS
TempTask       	TSS   		<>
              	DB     	0FFH             		;I/O���λͼ������־
TempTSSLen      =      	$
TempTSSSeg     ENDS
TempCodeSeg    SEGMENT PARA USE16       	;��ʱ����Ĵ����
                ASSUME 	CS:TempCodeSeg
Virtual           PROC   	FAR
                MOV    	AX,TempTSS_Sel   	;װ��TR
                LTR     	AX
                
                MOV   	AX,Video_Sel
                MOV    	ES,AX
                MOV    	AX,Normal_Sel
                MOV    	DS,AX
                MOV    	FS,AX
                MOV    	GS,AX
                MOV    	SS,AX
                XOR     	EDI,EDI
                MOV    	ECX,25*80
                MOV    	AX,0720H
                CLD
                REP     	STOSW
                MOV   	BYTE PTR ES:[0H], '0'
                MOV    	ECX,5
Virtual0:       
                JUMP16	DemoTSS_Sel,0   	;ֱ���л�����ʾ����
                INC     	BYTE PTR ES:[0H]
                LOOP  	Virtual0
                CLTS                    	;�������л���־
                MOV   	EAX,CR0         	;׼������ʵģʽ
                AND    	AL,11111110B
                MOV   	CR0,EAX
                JUMP16 	<SEG Real>,<OFFSET Real>
Virtual           ENDP
TempCodeSeg     ENDS
RStackSeg        SEGMENT PARA STACK     	;ʵģʽ��ջ��
                 DB      	512 DUP (0)
RStackSeg        ENDS                     	;��ջ�ν���
RCodeSeg        SEGMENT PARA USE16
                 ASSUME 	CS:RCodeSeg,DS:RDataSeg,ES:RDataSeg
START           PROC
                MOV  	AX,RDataSeg
                MOV    	DS,AX
                MOV    	SSVar,SS
                MOV    	SPVar,SP
                CLD
                CALL  	InitGDT               	;��ʼ��ȫ����������GDT
                CALL   	InitLDT               	;��ʼ���ֲ���������LDT
                LGDT   	QWORD PTR VGDTR   	;װ��GDTR�л�������ģʽ
                CLI
                MOV  	EAX,CR0
                OR      	AL,1
                MOV    	CR0,EAX
                JUMP16 	<TempCode_Sel>,<OFFSET Virtual>
Real:           
                MOV   	AX,RDataSeg           	;�ֻص�ʵģʽ
                MOV    	DS,AX
                MOV    	SP,SPVar
                MOV    	SS,SSVar
                STI
                MOV    	AX,4C00H
                INT      	21H
START          ENDP
InitGDT         PROC
                MOV  	CX,GDNum
                MOV    	SI,OFFSET EFFGDT
                MOV    	BX,16
InitG:          
                MOV    	AX,[SI].BaseL
                MUL     	BX
                MOV    	WORD PTR [SI].BaseL,AX
                MOV    	BYTE PTR [SI].BaseM,DL
                MOV    	BYTE PTR [SI].BaseH,DH
                ADD   	SI,8
                LOOP   	InitG
                MOV    	AX,DS
                MUL    	BX
                ADD    	AX,OFFSET GDT
                ADC    	DX,0
                MOV     	WORD PTR VGDTR.Base,AX
                MOV  	WORD PTR VGDTR.Base+2,DX
                RET
InitGDT         ENDP
InitLDT         PROC
                MOV   	AX,DemoLDTSeg
                MOV    	ES,AX
                MOV    	SI,OFFSET DemoLDT
                MOV    	CX,DemoLDNum
                MOV    	BX,16
InitL:
                MOV    	AX,WORD PTR ES:[SI].BaseL
                MUL    	BX
                MOV    	WORD PTR ES:[SI].BaseL,AX
                MOV    	BYTE PTR ES:[SI].BaseM,DL
                MOV    	BYTE PTR ES:[SI].BaseH,DH
                ADD    	SI,8
                LOOP   	InitL
                RET
InitLDT          ENDP
RCodeSeg        ENDS
                END    	start