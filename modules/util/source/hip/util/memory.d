/**
*   Public imports free, malloc, realloc, memcpy, memcmp, memset.
*   - toHeap!T executes malloc + memcpy
*   - safeFree executes free and sets the reference to null
*   - alloc!T is a malloc with the type size
*   - allocSlice!T will return a heap allocated slice 
*
*/
module hip.util.memory;

public import core.stdc.stdlib;
public import core.stdc.string:memcpy, memcmp, memset;
import hip.util.reflection;

version(WebAssembly) version = CustomRuntime;
version(PSVita) version = CustomRuntime;

version(CustomRuntime)
    static import core.arsd.memory_allocation;

@nogc:
void setZeroMemory(T)(ref T variable)
{
    memset(&variable, 0, T.sizeof);
}


T* alloc(T)(size_t count = 1){return cast(T*)core.stdc.stdlib.malloc(T.sizeof*count);}
T[] allocSlice(T)(size_t count){return alloc!T(count)[0..count];}

void* toHeap(T)(in T data) if(isReference!T)
{
    version(CustomRuntime)
    {
        void* m = cast(void*)data; //WASM don't need to allocate as it is not ever deleted.
    }
    else
    {
        import core.memory;
        void* m = cast(void*)data;
        GC.addRoot(cast(void*)data);
    }
    return m;
}

void* toHeap(T)(T data) if(!isReference!T)
{
    void* m = alloc!T;
    memcpy(m, &data, T.sizeof);
    return m;
}

void[] toHeapSlice(T)(T data) if(!is(T == void[]))
{
    return toHeap(data)[0..T.sizeof];
}


void freeGCMemory(void* data)
{
    assert(data !is null, "Tried to free null data.");
    version(CustomRuntime){core.arsd.memory_allocation.free(cast(ubyte*)data);}
    else
    {
        import core.memory;
        GC.removeRoot(data);
        GC.free(data);
    }
}

void freeGCMemory(ref void* data) //Remove ref.
{
    assert(data !is null, "Tried to free null data.");
    version(CustomRuntime){core.arsd.memory_allocation.free(cast(ubyte*)data);}
    else
    {
        import core.memory;
        GC.removeRoot(data);
        GC.free(data);
    }
    data = null;
}

void freeGCMemory(ref void[] data)
{
    assert(data.length, "Tried to free null data.");
    version(CustomRuntime){core.arsd.memory_allocation.free(cast(ubyte*)data.ptr);}
    else
    {
        import core.memory;
        GC.removeRoot(data.ptr);
        GC.free(data.ptr);
    }
    data = null;
}

void safeFree(T)(ref T data) if(isReference!T)
{
    version(CustomRuntime)
    {
        free(cast(ubyte*)data);
    }
    else
    {
        import core.memory;
        GC.removeRoot(cast(void*)data);
        GC.free(cast(void*)data);
    }
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