module hip.util.conv;
import hip.util.string;
import std.typecons;
import std.math.traits:isNaN, isInfinity;
import std.traits:isArray;

string toString(T)(T[] arr) pure nothrow @safe
{
    string ret = "[";
    for(int i = 0; i < arr.length; i++)
    {
        if(i)
            ret~= ",";
        ret~= toString(arr[i]);
    }
    return ret~"]";
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
            put(sink, ", ");
        toStringRange(sink, arr[i]);
    }
    put(sink, ']');
}

string toString(T)(T structOrTuple) pure nothrow @safe if(!isArray!T)
{
    static if(isTuple!T)
    {
        alias tupl = structOrTuple;
        string ret;
        foreach(i, v; tupl)
        {
            if(i > 0)
                ret~= ", ";
            ret~= to!string(v);
        }
        return T.stringof~"("~ret~")";
    }
    else static if(is(T == struct))//For structs declaration
    {
        alias struct_ = structOrTuple;
        string s = "(";
        static foreach(i, alias m; T.tupleof)
        {
            if(i > 0)
                s~= ", ";
            s~= toString(struct_.tupleof[i]);
        }
        return T.stringof~s~")";
    }
    else static assert(0, "Not implemented for "~T.stringof);
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


string dumpStructToString(T)(T struc) if(is(T == struct))
{
    string s = "\n(";
    static foreach(i, alias m; T.tupleof)
    {
        s~= "\n\t "~m.stringof~": ";
        s~= toString(struc.tupleof[i]);
    }
    return T.stringof~s~"\n)";
}


T toStruct(T)(string struc) pure nothrow
{
    T ret;
    string[] each;
    string currentArg;

    bool isInsideString = false;
    for(ulong i = 1; i < (cast(int)struc.length)-1; i++)
    {
        if(!isInsideString && struc[i] == ',')
        {
            each~= currentArg;
            currentArg = null;
            if(struc[i+1] == ' ')
            	i++;
            continue;
        }
        else if(struc[i] == '"')
        {
            isInsideString = !isInsideString;
            continue;
        }
        currentArg~= struc[i];
    }
    if(currentArg.length != 0)
        each~=currentArg;

    static foreach(i, m; __traits(allMembers, T))
    {
        mixin("ret."~m~" = to!(typeof(ret."~m~"))(each[i]);");
    }
    return ret;
}


bool toBool(string str) pure nothrow @safe @nogc {return str == "true";}

///Use that for making toStruct easier
string toString(string str) pure nothrow @safe @nogc {return str;}
void   toStringRange(Sink)(auto ref Sink sink, string str) if(isOutputRange!(Sink, char))
{
    static if(__traits(compiles, sink.preAllocate))
        sink.preAllocate(str.length);
    put(sink, str);
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

void toStringRange(Sink)(auto ref Sink sink, void* ptr) if(isOutputRange!(Sink, char))
{
    toHex(sink, cast(size_t)ptr);
}
string toString(bool b) pure nothrow @safe @nogc
{
    if(b) return "true";
    return "false";
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

TO to(TO, FROM)(FROM f) pure nothrow
{
    static if(is(TO == string))
    {
        static if(is(FROM == const(char)*) || is(FROM == char*))
            return fromStringz(f);
        else
            return toString(f);
    }
    else static if(is(TO == int))
        return toInt(f);
    else static if(is(TO == uint) || is(TO == ulong) || is(TO == ubyte) || is(TO == ushort))
        return cast(TO)toInt(f);
    else static if(is(TO == float))
        return toFloat(f);
    else static if(is(TO == bool))
        return toBool(f);
    else
        return toStruct!TO(f);
}

/// This function can be called at compilation time without bringing runtime
export string toString(int x) pure nothrow @safe
{
    enum numbers = "0123456789";
    bool isNegative = x < 0;
    if(isNegative)
        x*= -1;
    ulong div = 10;
    int length = 1;
    int count = 1;
    while(div <= x)
    {
        div*=10;
        length++;
    }
    if(isNegative) length++;
    char[] ret = new char[](length);
    if(isNegative)
        ret[0] = '-';
    div = 10;
    while(div <= x)
    {
        count++;
        ret[length-count]=numbers[(x/div)%10];
        div*=10;
    }
    ret[length-1] = numbers[x%10];
    return ret[0..$];
}

import std.range.interfaces;
import std.range.primitives;
import std.range:put;

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


export string toString(float f) pure nothrow @safe 
{
    if(f.isNaN) return "nan";
    if(f.isInfinity) return "inf";

    bool isNegative = f < 0;
    if(isNegative)
        f = -f;
    float decimal = f - cast(int)f;
    string ret = (cast(int)f).toString;
    if(isNegative)
        ret = "-"~ret;
    
    if(decimal == 0)
        return ret;
   
    while(cast(int)decimal != decimal)
        decimal*=10;
    return ret ~ '.'~ (cast(int)decimal).toString;
}

void toStringRange(Sink)(auto ref Sink sink, float f)
{
    if(f.isNaN)
    {
        static if(__traits(hasMember, sink, "preAllocate"))
            sink.preAllocate("nan".length);
        put(sink, "nan");
        return;
    } 
    if(f.isInfinity)
    {
        static if(__traits(hasMember, sink, "preAllocate"))
            sink.preAllocate("inf".length);
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
   
    while(cast(int)decimal != decimal)
        decimal*=10;

    put(sink, '.');
    toStringRange(sink, cast(int)decimal);
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

string toHex(size_t n)
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
    char[] ret = new char[](preAllocSize);
    int i = 0;

    while(div >= 16)
    {
        ret[i++] = numbers[(n/div)%16];
        div/= 16;
    }
    ret[i] = numbers[n%16];
    return cast(string)ret;
}


string fromUTF16(wstring str) pure nothrow
{
    string ret;
    foreach(c;str) ret~= c;
    return ret;
}

int toInt(string str) pure nothrow @safe @nogc
{
    if(str.length == 0) return 0;


    int i = (cast(int)str.length)-1;

    int last = 0;
    int multiplier = 1;
    int ret = 0;
    if(str[0] == '-')
    {
        last++;
        multiplier*= -1;
    }
    for(; i >= last; i--)
    {
        if(str[i] >= '0' && str[i] <= '9')
            ret+= (str[i] - '0') * multiplier;
        else
            return ret;
        multiplier*= 10;
    }
    return ret;
}


float toFloat(string str) pure nothrow @safe @nogc
{
    if(str.length == 0) return 0;
    if(str == "nan" || str == "NaN") return float.init;
    if(str == "inf" || str == "infinity" || str == "Infinity") return float.infinity;

    int i = 0;
    int integerPart = 0;
    int decimalPart = 0;
    
    bool isNegative = str[0] == '-';
    if(isNegative) i = 1;

    bool isDecimal = false;
    for(; i < str.length; i++)
    {
        if(str[i] =='.')
        {
            isDecimal = true;
            continue;
        }
        if(isDecimal)
            decimalPart++;
        else
            integerPart++;
    }
    if(decimalPart == 0)
        return cast(float)str.toInt;

    i = (isNegative ? 1 : 0);
    float decimal= 0;
    float integer  = 0;
    int integerMultiplier = 1;
    float floatMultiplier = 1.0f/10.0f;

    int integerPartBackup = integerPart;
    if(isNegative)
        integerPartBackup++;

    while(integerPart > 0)
    {
        integer+= (str[integerPartBackup-i] - '0') * integerMultiplier;
        integerMultiplier*= 10;
        integerPart--;
        i++;
    }
    i++; //Jump the .
    while(decimalPart > 0)
    {
        decimal+= (str[i] - '0') * floatMultiplier;
        floatMultiplier/= 10;
        decimalPart--;
        i++;
    }
    return (integer + decimal) * (isNegative ? -1 : 1);
}


unittest
{
    assert(toString(500) == "500");
    assert(toFloat("50.5" == 50.5f));
    assert(toString(100.0) == "100");
    assert(toInt("-500") == -500);
    assert(toString("Hello") == "Hello");
    assert(toString(true) == "true");
    assert(toString(50.25)== "50.25");
}