;PROG0502
       MOV      EAX, A
       CMP       EAX, B
       JAE       AIsAbove      ; ���A��B����ת��AIsAbove��Ŵ�
       MOV      EAX, B
AIsAbove:
       MOV      MAXAB, EAX