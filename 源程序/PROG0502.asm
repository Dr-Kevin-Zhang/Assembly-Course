;PROG0502
       MOV      EAX, A
       CMP       EAX, B
       JAE       AIsAbove      ; 如果A≥B，跳转到AIsAbove标号处
       MOV      EAX, B
AIsAbove:
       MOV      MAXAB, EAX