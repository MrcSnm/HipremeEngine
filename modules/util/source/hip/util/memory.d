/**
*   Public imports free, malloc, realloc, memcpy, memcmp, memset.
*   - toHeap!T executes malloc + memcpy
*   - safeFree executes free and sets the reference to null
*   - alloc!T is a malloc with the type size
*   - allocSlice!T will return a heap allocated slice 
*
*/
module hip.util.memory;

public import core.stdc.stdlib:free, malloc, realloc;
public import core.stdc.string:memcpy, memcmp, memset;
import hip.util.reflection;

@nogc:


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
    import hip.util.reflection;
    static if(isReference!T)
    {
        import core.memory;
        void* m = cast(void*)data;
        GC.addRoot(cast(void*)data);
    }
    else
    {
        void* m = alloc!T;
        memcpy(m, &data, T.sizeof);
    }
    return m;
}

void[] toHeapSlice(T)(T data) if(!is(T == void[]))
{
    return toHeap(data)[0..T.sizeof];
}


void freeGCMemory(ref void* data)
{
    import core.memory;
    GC.removeRoot(data);
    data = null;
}

void freeGCMemory(ref void[] data)
{
    import core.memory;
    GC.removeRoot(data.ptr);
    data = [];
}

void safeFree(T)(ref T data) if(isReference!T)
{
    import core.memory;
    GC.removeRoot(cast(void*)data);
    data = null;
}

void safeFree(ref void* data)
{
    if(data != null)
        free(data);
    data = null;
}
void safeFree(ref void[] data)
{
    if(data.ptr !is null)
        free(data.ptr);
    data = [];
}
void setZeroMemory(T)(ref T variable)
{
    memset(&variable, 0, T.sizeof);
}
