module hip.util.sumtype;

enum Type
{
    undefined,
    void_,
    object,
    string_,
    bool_,
    //Signed
    byte_,
    short_,
    int_,
    long_,
    //Unsigned
    ubyte_,
    ushort_,
    uint_,
    ulong_,
    //Floating
    float_,
    double_,
    ///Untested
    real_
}

private union TypeUnion
{
    string string_;
    void* void_;
    Object object;
    bool bool_;
    //Signed
    byte byte_;
    short short_;
    int int_;
    long long_;
    //Unsigned
    ubyte ubyte_;
    ushort ushort_;
    uint uint_;
    ulong ulong_;
    //Floating
    float float_;
    double double_;
    ///Untested
    real real_;
}
pure Type getType(T)()  nothrow @nogc @safe
{
    with(Type)
    {
        static if(is(T == string))
            return string_;
        else static if(is(T == void*))
            return void_;
        else static if(is(T : Object))
            return object;
        else static if(is(T == bool))
            return bool_;
        else static if(is(T == byte))
            return byte_;
        else static if(is(T == short))
            return short_;
        else static if(is(T == int))
            return int_;
        else static if(is(T == long))
            return long_;
        else static if(is(T == ubyte))
            return ubyte_;
        else static if(is(T == ushort))
            return ushort_;
        else static if(is(T == uint))
            return uint_;
        else static if(is(T == ulong))
            return ulong_;
        else static if(is(T == float))
            return float_;
        else static if(is(T == double))
            return double_;
        else static if(is(T == real))
            return real_;
        else static assert(false, "Unimplemented for type "~T.stringof);
    }
}

/**
*   Use that when you want to hold arbitrary defined type (which usually must be converted)
*   By using sumtype, your data will be converted only once and after that, it will be runtime
*   type strict.
*/
struct Sumtype
{
    Type type = Type.undefined;
    TypeUnion data = void;

    string getTypeName() const @nogc
    {
        switch(type)
        {
            static foreach(mem; __traits(allMembers, Type))
            {
                case __traits(getMember, Type, mem):
                    return mem[0..$-1];
            }
            default:
                return "undefined";
        }
    }

    T get(T)() const
    {
        if(getType!T != type)
            throw new Exception("Tried to get a mismatching type: "~T.stringof~" (expected "~getTypeName~")");
        return *cast(T*)(cast(void*)&data);
    }
    T set(T)(T value)
    {
        if(type == Type.undefined)
            this.type = getType!T;
        else if(type != getType!T)
            throw new Exception("Tried to get a mismatching type: "~T.stringof~" (expected "~getTypeName~")");
        data = *cast(TypeUnion)(cast(void*)&data);
        return value;
    }

    T opCast(T)() const
    {
        return get!T;   
    }
    bool opBinary(string op : "in")(const Type t) const
    {
        return type == t;
    }
    alias opBinaryRight = opBinary;

    static Sumtype make(string data)
    {
        return Sumtype(Type.string_, cast(TypeUnion)data);
    }
    
    static Sumtype make(T)(T data) if(!is(T == string))
    {
        Sumtype s = void;
        s.type = getType!T;
        s.data = *cast(TypeUnion*)(cast(void*)&data);
        return s;
    }

    static Sumtype make(T)(string data)
    {
        import hip.util.conv:to;
        return make!T(to!T(data));
    }
}