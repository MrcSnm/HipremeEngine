module hip.util.to_string_range;
import std.range.interfaces;
import std.range.primitives;
import std.range:put;
import std.traits:isArray;
import std.typecons:isTuple;

void toStringRange(Sink)(auto ref Sink sink, float f)
{
    if(f != f) //nan
    {
        static if(__traits(hasMember, sink, "preAllocate"))
            sink.preAllocate("nan".length);
        foreach(v; "nan")
            put(sink, v);
        return;
    } 
    if(f == float.infinity)
    {
        static if(__traits(hasMember, sink, "preAllocate"))
            sink.preAllocate("inf".length);
        foreach(v; "inf")
            put(sink, v);
        return;
    }
    if(f < 0)
    {
        f = -f;
        put(sink, '-');
    }
    float decimal = f - cast(int)f;
    toStringRange(sink, cast(int)f);
    if(decimal == 0)
        return;
   
    while(cast(int)decimal != decimal)
        decimal*=10;

    put(sink, '.');
    toStringRange(sink, cast(int)decimal);
}

void toStringRange(Sink, T)(auto ref Sink sink, T[] arr)
if(isOutputRange!(Sink, char) && !is(T[] == string)) //There is a better match for string
{
    put(sink, '[');
    static if(__traits(compiles, sink.preAllocate))
    {
        //2: '[' and ']'
        // 2 * (cast(int)arr.length - 1): ", "
        sink.preAllocate(2 * arr.length);
    }
    for(int i = 0; i < arr.length; i++)
    {
        if(i != 0)
        {
            foreach(character; " ")
                put(sink, character);
        }
        toStringRange(sink, arr[i]);
    }
    put(sink, ']');
}


void toStringRange(Sink, T)(auto ref Sink sink, T structOrTuple) 
if(!isArray!T && (is(T == struct) || isTuple!T))
{
    static if(isTuple!T)
    {
        alias tupl = structOrTuple;
        put(sink, T.stringof);
        put(sink, '(');
        foreach(i, v; tupl)
        {
            if(i > 0)
                put(sink, ", ");
            toStringRange(sink, v);
        }
        put(sink, ')');
    }
    else static if(is(T == struct))//For structs declaration
    {
        alias struct_ = structOrTuple;
        put(sink, T.stringof);
        put(sink, '(');
        static foreach(i, alias m; T.tupleof)
        {
            if(i > 0)
                put(sink, ", ");
            toStringRange(sink, struct_.tupleof[i]);
        }
        put(sink, ')');
    }
    else static assert(0, "Not implemented for "~T.stringof);
}

void   toStringRange(Sink)(auto ref Sink sink, string str) if(isOutputRange!(Sink, char))
{
    static if(__traits(compiles, sink.preAllocate))
        sink.preAllocate(str.length);
    foreach(character; str)
        put(sink, character);
}
void   toStringRange(Sink)(auto ref Sink sink, const(char)* str) if(isOutputRange!(Sink, char))
{
    import core.stdc.string:strlen;
    size_t length = strlen(str);
    static if(__traits(compiles, sink.preAllocate))
        sink.preAllocate(length);
    for(int i = 0; i < length; i++)
        put(sink, str[i]);
}

void   toStringRange(Sink)(auto ref Sink sink, const(ubyte)* str) if(isOutputRange!(Sink, char))
{
    toStringRange(sink, cast(const(char)*)str);
}

void toStringRange(Sink)(auto ref Sink sink, void* ptr) if(isOutputRange!(Sink, char))
{
    toHex(sink, cast(size_t)ptr);
}

void toStringRange(Sink)(auto ref Sink sink, bool b) if(isOutputRange!(Sink, char))
{
    if(b)
    {
        static if(__traits(compiles, sink.preAllocate))
            sink.preAllocate("true".length);
        put(sink, "true");
    }
    else
    {
        static if(__traits(compiles, sink.preAllocate))
            sink.preAllocate("false".length);
        put(sink, "false");
    }
}

void toStringRange(Sink)(auto ref Sink sink, int x) 
if(isOutputRange!(Sink, char))
{
    enum numbers = "0123456789";
    int preAllocSize = 0;
    bool isNegative = x < 0;
    if(isNegative)
    {
        x*= -1;
        preAllocSize++;
    }
    ulong div = 10;
    while(div <= x)
    {
        div*=10;
        preAllocSize++;
    }
    div/= 10;
    static if(__traits(hasMember, sink, "preAllocate"))
        sink.preAllocate(preAllocSize);
    if(isNegative)
        put(sink, '-');
    while(div >= 10)
    {
        put(sink, numbers[(x/div)%10]);
        div/=10;
    }
    put(sink, numbers[x%10]);
}


void toHex(Sink)(auto ref Sink sink, size_t n)
if(isOutputRange!(Sink, char))
{
    enum numbers = "0123456789ABCDEF";
    int preAllocSize = 1;
    size_t div = 16;
    while(div <= n)
    {
        div*= 16;
        preAllocSize++;
    }
    div/= 16;
    static if(__traits(hasMember, sink, "preAllocate"))
        sink.preAllocate(preAllocSize);

    while(div >= 16)
    {
        put(sink, numbers[(n/div)%16]);
        div/= 16;
    }
    put(sink, numbers[n%16]);
}