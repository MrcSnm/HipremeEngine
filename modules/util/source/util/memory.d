module util.memory;

public import core.stdc.stdlib:free, malloc;
public import core.stdc.string:memcpy, memcmp, memset;


void safeFree(ref void* data)
{
    if(data != null)
        free(data);
    data = null;
}
void setZeroMemory(T)(ref T variable)
{
    memset(&variable, 0, T.sizeof);
}
