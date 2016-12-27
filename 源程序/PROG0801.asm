;PROG0801
PUSHREG       MACRO
                PUSH    EAX
                PUSH    EBX
                PUSH    ECX
                PUSH    EDX
                ENDM
POPREG        MACRO
                POP     EDX
                POP     ECX
                POP     EBX
                POP     EAX
                ENDM