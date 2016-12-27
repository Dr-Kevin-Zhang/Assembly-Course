;PROG0615.ASM
.386
.model flat
input           PROTO C px:ptr sdword, py:ptr sdword
output          PROTO C x:dword, y:dword
.data
x               dword   ?
y               dword   ?
.code
main            proc    C
                invoke  input, offset x, offset y
                invoke  output, x, y
                ret
main            endp
end
/*PROG0616.c           */
#include "stdio.h"
extern void input(int *px, int *py);
extern void output(int x, int y);
void input(int *px, int *py)
{
        printf("input x y: ");
        scanf("%d %d", px, py);
}
void output(int x, int y)
{
        printf("%d*%d+%d*%d=%d\n", x, x, y, y, x*x+y*y);
}