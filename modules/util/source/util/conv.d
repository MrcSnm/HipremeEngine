module util.conv;
import util.string;
import std.typecons;
import std.math.traits:isNaN, isInfinity;
import std.traits:isArray;

string toString(T)(T[] arr) pure nothrow @safe
{
    string ret = "[";
    for(int i = 0; i < arr.length; i++)
    {
        ret~= toString(arr[i]);
        if(i != cast(int)arr.length - 1)
            ret~= ",";
    }
    return ret~"]";
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
string toString(bool b) pure nothrow @safe @nogc
{
    if(b) return "true";
    return "false";
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


export string toString(float f) pure nothrow @safe 
{
    if(f.isNaN) return "nan";
    if(f.isInfinity) return "inf";

    bool isNegative = f < 0;
    if(isNegative)
        f = -f;
    float decimal = f%10;
    string ret = (cast(int)f).toString;
    if(isNegative)
        ret = "-"~ret;
    
    if(decimal == 0)
        return ret;
   
    while(cast(int)decimal != decimal)
        decimal*=10;
    return ret ~ '.'~ (cast(int)decimal).toString;
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