;PROG0902
                MOV  	AL, 10110110B    	; ������2�����Ϊ������ʽ
                OUT 		43H, AL         	; ���¶Լ�����2���
                                       			; ����896 HzƵ�ʵķ���
                MOV    	BX, 1331      		; 1 193 180/896 = 1 331
                MOV   	AL, BL        	; BX=1331=533H, AL=33H
                OUT   	42H, AL         	; �������1331�ĵ�8λ
                MOV    	AL, BH          	; AL=05H
                OUT    	42H, AL         	; �����1331�ĸ�8λ
                IN     	AL, 61H          	; ����61H�˿ڵ�����
                PUSH   	EAX             	; �����ڶ�ջ��
                OR     	AL, 00000011B    	; ����Bit1,Bit0Ϊ1
                MOV    	ECX, 20   		; һ��ѭ��20��
Toggle:         
                OUT    	61H, AL          	; Bit1=1ʱ, ������
                PUSH   	ECX
                MOV    	ECX, 10000000H 	; ��ʱԼ0.3��
Delay:     	                    				; (CPU=P4, 1.8 GHz)
                LOOP   	Delay
                POP    	ECX
                XOR    	AL, 00000010B   	; Bit1: 1��0��1��0
                LOOP   	Toggle           	; ѭ��20��
                                        		; 10�η���, 10�β�����
                POP    	EAX          	; ALΪ61H�˿�ԭ�е�����
                AND    	EAX, 11111100B	; ��Bit1=0, Bit0=0, ������
                OUT    	61H, AL     		; �ָ�61H�˿�ԭ�е�����