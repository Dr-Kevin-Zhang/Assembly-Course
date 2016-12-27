/*PROG0605.C */
__declspec(naked) int subproc(int a, int b)
{
        _asm mov eax, [esp+4]
        _asm sub eax, [esp+8]
        _asm ret
}
int r;
int main( )
{
        r=subproc(30, 20);
}