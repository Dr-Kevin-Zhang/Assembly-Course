/* PROG0408，设程序名为Violate.c  */
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[])
{
    unsigned int var = 10;
    unsigned int * ptr1 = &var;
    unsigned int * ptr2 = (unsigned int *)0xC0000000L;
    printf("*(0x%08X)=", ptr1); 
    printf("0x%08X\n", *ptr1);
    printf("*(0x%08X)=", ptr2); 
    printf("0x%08X\n", *ptr2);
}