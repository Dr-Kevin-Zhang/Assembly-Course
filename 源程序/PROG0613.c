/*PROG0613.C  */
#include "stdio.h"
extern int a, b; 
extern int CalcAXBY(int x, int y);
extern int z;
int z;
int x=10, y=20, 
int main()
{
	int r=CalcAXBY(x, y);
	printf("%d*%d+%d*%d=%d, r=%d\n", a, x, b, y, z, r);
	return 0;
}