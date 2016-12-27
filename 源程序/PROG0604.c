/*PROG0604.C      */
int subproc(int a, int b)
{ 
        return a-b;
}
int r,s;
int main( )
{
        r=subproc(30, 20);
        s=subproc(r, -1);
}