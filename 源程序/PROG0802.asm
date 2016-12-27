;PROG0802
MIN             MACRO   A, B, X
                 PUSH     EAX
                 MOV      EAX, A
                 CMP      EAX, B
                 JB        ExitMin
                 MOV      EAX, B
ExitMin:
                 MOV      X, EAX
                 POP       EAX
                 ENDM