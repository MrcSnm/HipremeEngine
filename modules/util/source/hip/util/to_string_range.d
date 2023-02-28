module hip.util.to_string_range;
import std.range.interfaces;
import std.range.primitives;
import std.traits:isArray;
import std.typecons:isTuple;

private void put(Sink, E)(ref Sink sink, E e)
{
    static if(is(E == U[], U))
    {
        static if(__traits(hasMember, sink, "preAllocate"))
            sink.preAllocate(e.length);
        foreach(element; e)
            sink.put(element);
    }
    else
        sink.put(e);
}


void toStringRange(Sink, Enum)(ref Sink sink, Enum enumMember) if(is(Enum == enum))
{
    foreach(mem; __traits(allMembers, Enum))
        if(__traits(getMember, Enum, mem) == enumMember)
        {
            put(sink, Enum.stringof ~ "." ~ mem); //@nogc string, resolved at compile time
            return;
        }
    put(sink, Enum.stringof ~ ".|MEMBER_NOT_FOUND|"); //@nogc string, resolved at compile time
}

void toStringRange(Sink)(ref Sink sink, float f)
{
    if(f != f) //nan
    {
        put(sink, "nan");
        return;
    } 
    if(f == float.infinity)
    {
        put(sink, "inf");
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
    put(sink, '.');
    while(cast(int)decimal != decimal)
    {
        decimal*=10;
        if(cast(int)decimal == 0)
            put(sink, '0');
    }
    toStringRange(sink, cast(int)decimal);
}


void toStringRange(Sink, T)(auto ref Sink sink, T[] arr)
if(isOutputRange!(Sink, char) && !is(T[] == string)) //There is a better match for string
{
    static if(__traits(compiles, sink.preAllocate))
    {
        //2: '[' and ']'
        // 2 * arr.length: ", " (no need to use - 1 as there will be the inputs)
        sink.preAllocate(2 + 2 * arr.length);
    }
    put(sink, '[');
    for(int i = 0; i < arr.length; i++)
    {
        if(i != 0)
        {
            foreach(character; ", ")
                put(sink, character);
        }
        toStringRange(sink, arr[i]);
    }
    put(sink, ']');
}


void toStringRange(Sink, T)(auto ref Sink sink, T structOrTupleOrClass) 
if(!isArray!T && (is(T == struct) || is(T == class) || is(T == interface) || isTuple!T))
{
    static if(isTuple!T)
    {
        alias tupl = structOrTupleOrClass;
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
        alias struct_ = structOrTupleOrClass;
        put(sink, T.stringof);
        put(sink, '(');
        foreach(i, v; struct_.tupleof)
        {
            if(i > 0)
                put(sink, ", ");
            toStringRange(sink, v);
        }
        put(sink, ')');
    }
    else static if(is(T == class))
    {
        alias class_ = structOrTupleOrClass;
        put(sink, T.classinfo.name);
        put(sink, '(');
        foreach(i, v; class_.tupleof)
        {
            if(i > 0)
                put(sink, ", ");
            toStringRange(sink, v);
        }
        put(sink, ')');
    }
    else static if(is(T == interface))
    {
        put(sink, T.classinfo.name);
    }
    else static assert(0, "Not implemented for "~T.stringof);
}

// void toStringRange(Sink)(auto ref Sink sink, scope const char[] arr) if(isOutputRange!(Sink, char))
// {
//     static if(__traits(compiles, sink.preAllocate))
//         sink.preAllocate(arr.length);
//     foreach(ch; arr)
//         put(sink, ch);
// }

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
    if(ptr is null)
        put(sink, "null");
    else
        toHex(sink, cast(size_t)ptr);
}

void toStringRange(Sink)(auto ref Sink sink, bool b) if(isOutputRange!(Sink, char))
{
    put(sink, b ? "true" :"false");
}

void toStringRange(Sink)(ref Sink sink, long x) 
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
    put(sink, numbers[cast(size_t)(x%10)]);
}


void toHex(Sink)(auto ref Sink sink, size_t n)
if(isOutputRange!(Sink, char))
{
    enum numbers = "0123456789ABCDEF";
    int preAllocSize = 1;
    ulong div = 16;
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