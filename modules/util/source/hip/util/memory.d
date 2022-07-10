module hip.util.memory;

public import core.stdc.stdlib:free, malloc, realloc;
public import core.stdc.string:memcpy, memcmp, memset;

T* alloc(T)(size_t count = 1)
{
    static if(is(T == void))
        return cast(void*)malloc(count);
    else
        return cast(T*)malloc(T.sizeof*count);
}

T[] allocSlice(T)(size_t count)
{
    return alloc!T(count)[0..count];
}

void* toHeap(T)(T data)
{
    void* m = alloc!T;
    memcpy(m, &data, T.sizeof);
    return m;
}

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
