/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module util.string;
public import util.conv:to;


/** 
 *  RefCounted, @nogc string, OutputRange compatible, 
 */
struct String
{
    @nogc:
    import core.stdc.string;
    import core.stdc.stdlib;
    char* chars;
    uint length;
    private int _capacity;
    private int* countPtr;

    this(this){*countPtr = *countPtr + 1;}

    static auto opCall(const(char)* str)
    {
        String s;
        uint l = cast(uint)strlen(str);
        s.chars = cast(char*)malloc(l);
        s.countPtr = cast(int*)malloc(int.sizeof);
        memcpy(s.chars, str, l);
        *s.countPtr = 1;
        s.length = l;
        s._capacity = l;
        return s;
    }
    static auto opCall(String str)
    {
        import std.stdio;
        debug { import std.stdio : writeln; try { writeln("HERE"); } catch (Exception) {} }
        return str;
    }
    static auto opCall(string str)
    {
        String s;
        s.chars = cast(char*)malloc(str.length);
        s.countPtr = cast(int*)malloc(int.sizeof);
        s.length = cast(uint)str.length;
        s._capacity = s.length;
        *s.countPtr = 1;
        memcpy(s.chars, str.ptr, s.length);
        return s;
    }
    static auto opCall(Args...)(Args args)
    {
        import util.conv:toStringRange;
        String s;
        s._capacity = 128;
        s.chars = cast(char*)malloc(128);
        s.countPtr = cast(int*)malloc(int.sizeof);
        s.length = 0;
        *s.countPtr = 1;
        static foreach(a; args)
        {
            static if(is(typeof(a) == String))
                s~= a;
            else static if(__traits(hasMember, a, "toString"))
                s~= a.toString;
            else
                toStringRange(s, a);
        }
        return s;
    }
    alias _opApplyFn = int delegate(char c) @nogc;
    int opApply(scope _opApplyFn dg)
    {
        int result = 0;
        for(int i = 0; i < length && result; i++)
            result = dg(chars[i]);
        return result;
    }

    auto ref opOpAssign(string op, T)(T value)
    {
        static if(op == "~")
        {
            uint l = 0;
            immutable (char)* chs;
            static if(is(T == String))
            {
                l = value.length;
                chs = cast(immutable(char)*)value.chars;
            }
            else static if (is(T == string))
            {
                l = cast(uint)value.length;
                chs = value.ptr;
            }
            else static if(is(T == immutable(char)*))
            {
                l = cast(uint)strlen(value);
                chs = value;
            }
            else static if(is(T == char))
            {
                l = 1;
                chs = cast(immutable(char*))&value;
            }
            else
            {
                string temp = to!string(value);
                l = temp.length;
                chs = temp.ptr;
            }
            resize(l + this.length);
            memcpy(chars+length, chs, l);
            length+= l;
        }
        return this;
    }

    auto ref opAssign(T)(T value)
    {
        static if(is(T == String))
        {
            if(value.length > length && chars != null)
                free(chars);

            chars = cast(char*)malloc(value.length);
            memcpy(chars, value.chars, value.length);
            length = value.length;
        }
        else static if(is(T == string))
        {
            if(value.length > length && chars != null)
                free(chars);
            uint l = cast(uint)value.length;
            chars = cast(char*)malloc(l);
            memcpy(chars, value.ptr, l);
            length = l;
        }
        else static if(is(T == immutable(char)*))
        {
            uint l = cast(uint)strlen(value);
            if(l > length && chars != null)
                free(chars);
            chars = cast(char*)malloc(l);
            memcpy(chars, value, l);
            length = l;
        }
        else static assert(0, "String can only assigned to String or string");
        return this;
    }

    T opCast(T)() const
    {
        static assert(is(T == string), "String can only be casted to string");
        return cast(string)chars[0..length];
    }
    string toString() const {return cast(string)chars[0..length];}

    pragma(inline) private void resize(uint newSize)
    {
        chars = cast(char*)realloc(chars, newSize);
        _capacity = newSize;
    }
    ///Make this struct OutputRange compatible
    void put(char c)
    {
        if(this.length + 1 >= this._capacity)
            resize(this.length+1);
        chars[length] = c;
        length++;
    }
    
    /**
    *   This function serves to allocate before put. This will make less allocations occur while iterating
    * this struct as an OutputRange.
    */
    void preAllocate(uint howMuch)
    {
        this._capacity+= howMuch;
        chars = cast(char*)realloc(chars, this._capacity);
    }
    void preAllocate(ulong howMuch){preAllocate(cast(uint)howMuch);}

    ~this()
    {
        *countPtr = *countPtr - 1;
        if(*countPtr <= 0 && chars != null)
        {
            free(chars);
            free(countPtr);
        }
    }

}

struct StringBuilder
{
    private char[] builtString;
    private uint builtLength;
    string[] strings;
    private uint stringsPtr = 0;
    
    void append(T)(T value)
    {
        if(stringsPtr == strings.length)
        {
            if(strings.length == 0x10000) //65K (This will guarantee a reasonable amount of allocations)
                toString();
            else
            {
                //128 is a reasonable start, this way, no really small operation should matter on performance
                strings.length = strings.length == 0 ? 128 : strings.length * 2;
            }
        }
        strings[stringsPtr++] = value;
    }
    string toString()
    {
        import core.stdc.string:memcpy;
        if(stringsPtr == 0) return cast(string)builtString[0..builtLength];
        uint count = builtLength;
        uint i = builtLength;
        foreach(s;strings[0..stringsPtr])
            count+= s.length;
        builtString.length = count;
        
        foreach(s; strings[0..stringsPtr])
        {
            memcpy(builtString.ptr+i, s.ptr, s.length);
            i+= s.length;
        }
        builtLength = count;
        stringsPtr = 0;
        return cast(string)builtString[0..builtLength];
    }
    auto ref opAssign(T)(T value) if(is(T == string))
    {
        builtString.length = value.length;
        foreach(i, c; s)
            builtString[i] = c;
        stringsPtr = 0;
        builtLength = cast(typeof(builtLength))value.length;

        return this;
    }
    auto ref opOpAssign(string op, T)(T value) if(op == "~")
    {
        import std.traits:isArray;
        static if(isArray!T && !is(T == string))
            foreach(v; value) append(v);
        else
            append(value);
        return this;
    }
    ref auto opIndex(size_t index){return toString()[index];}
    ulong length(){return builtLength;}
    ~this(){strings.length = 0;}

    ///Interface for OutputRange
    alias put = append;
}



pure string replaceAll(string str, char what, string replaceWith = "")
{
    string ret;
    for(int i = 0; i < str.length; i++)
    {
        if(str[i] != what) ret~= str[i];
        else if(replaceWith != "") ret~=replaceWith;
    }
    return ret;
}

pure string replaceAll(string str, string what, string replaceWith = "")
{
    string ret;
    ulong z = 0;
    for(uint i = 0; i < str.length; i++)
    {
        while(z < what.length && str[i+z] == what[z])
            z++;
        if(z == what.length)
        {
            ret~= replaceWith;
            i+=z;
        }
        z = 0;
        ret~= str[i];
    }
    return ret;
}

pure long indexOf(in string str,in string toFind, int startIndex = 0) nothrow @nogc
{
    long z = 0;
    for(long i = startIndex; i < str.length; i++)
    {
        while(i+z < str.length && z < toFind.length && str[i+z] == toFind[z])
        	z++;
        if(z == toFind.length)
            return i;
        z = 0;
    }
    return -1;
}

pure long indexOf(in string str, char ch, int startIndex = 0) nothrow @nogc
{
    char[1] temp = [ch];
    return indexOf(str,  cast(string)temp, startIndex);
}

pure long count(in string str, in string countWhat) nothrow @nogc @safe
{
    int ret = 0;
    int checker = 0;
    for(int i = 0; i < str.length; i++)
    {
        while(str[i+checker] == countWhat[checker])
        {
            checker++;
            if(checker == countWhat.length)
            {
                i+= checker;
                ret++;
                break;
            }
        }
        checker = 0;
    }
    return ret;
}

alias countUntil = indexOf;

long lastIndexOf(in string str,in string toFind, long startIndex = -1) pure nothrow @nogc
{
    long z = 1;
    if(startIndex == -1) startIndex = cast(int)(str.length)-1;
    for(long i = startIndex; i >= 0; i--)
    {
        while(str[i-z+1] == toFind[$-z])
        {
            z++;
            if(z > toFind.length)break;
        }
        if(z-1 == toFind.length)
            return i-toFind.length+1;
        z = 1;
    }
    return -1;
}
T toDefault(T)(string s, T defaultValue = T.init)
{
    if(s == "")
        return defaultValue;

    T v = defaultValue;
    try{v = to!(T)(s);}
    catch(Exception e){}
    return v;
}

string fromStringz(const char* cstr) pure nothrow @nogc
{
    import core.stdc.string:strlen;
    size_t len = strlen(cstr);
    return (len) ? cast(string)cstr[0..len] : null;
}

const(char*) toStringz(string str) pure nothrow
{
    return (str~"\0").ptr;
}
pragma(inline) char toLowerCase(char c) pure nothrow @safe @nogc 
{
    if(c < 'A' || c > 'Z')
        return c;
    return cast(char)(c + ('a' - 'A'));
}

string toLowerCase(string str) pure nothrow @safe
{
    string ret;
    ret.reserve(str.length);
    for(ulong i = 0; i < str.length; i++)
        ret~= str[i].toLowerCase;
    return ret;
}

pragma(inline) char toUpper(char c) pure nothrow @safe @nogc 
{
    if(c < 'a' || c > 'z')
        return c;
    return cast(char)(c - ('a' - 'A'));
}

string toUpper(string str) pure nothrow @safe
{
    string ret;
    ret.reserve(str.length);
    for(ulong i = 0; i < str.length; i++)
        ret~= str[i].toUpper;
    return ret;
}

string[] split(string str, char separator) pure nothrow
{
    char[1] sep = [separator];
    return split(str, cast(string)sep);
}

string[] split(string str, string separator) pure nothrow @safe
{
    string[] ret;
    string curr;
    int equalCount = 0;
    for(int i = 0; i < str.length; i++)
    {
        while(str[i+equalCount] == separator[equalCount])
        {
            equalCount++;
            if(equalCount == separator.length)
            {
                i+= equalCount;
                ret~= curr;
                curr = null;
                break;
            }
        }
        equalCount = 0;
        curr~= str[i];
    }
    if(curr == separator)
        curr = null;
    return ret ~ curr;
}

pragma(inline) bool isAlpha(char c) pure nothrow @safe @nogc
{
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

pragma(inline) bool isEndOfLine(char c) pure nothrow @safe @nogc
{
    return c == '\n' || c == '\r';
}

pragma(inline) bool isNumeric(char c) pure nothrow @safe @nogc
{
    return (c >= '0' && c <= '9') || (c == '-');
}
pragma(inline) bool isWhitespace(char c) pure nothrow @safe @nogc
{
    return (c == ' ' || c == '\t' || c.isEndOfLine);
}
string[] pathSplliter(string str)
{
    string[] ret;

    string curr;
    for(ulong i = 0; i < str.length; i++)
        if(str[i] == '/' || str[i] == '\\')
        {
            ret~= curr;
            curr = null;
        }
        else
            curr~= str[i];
    ret~= curr;
    return ret;
}



string baseName(string path) pure nothrow @safe @nogc
{
    ulong lastIndex = 0;
    for(ulong i = 0; i < path.length; i++)
        if(path[i] == '/' || path[i] == '\\')
            lastIndex = i+1;

    return path[lastIndex..$];
}



string join(string[] args, string separator)
{
	if(args.length == 0) return "";
	string ret = args[0];
	for(int i = 1; i < args.length; i++)
		ret~=separator~args[i];
	return ret;
}

unittest
{
    assert(baseName("a/b/test.txt") == "test.txt");
    assert(join(["hello", "world"], ", ") == "hello, world");
    assert(split("hello world", " ").length == 2);
    assert(toDefault!int("hello") == 0);
    assert(lastIndexOf("hello, hello", "hello") == 7);
    assert(indexOf("hello, hello", "hello") == 0);
    assert(replaceAll("\nTest\n", '\n') == "Test");
}