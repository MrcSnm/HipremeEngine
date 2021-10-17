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


struct String
{
    import core.stdc.string;
    import core.stdc.stdlib;
    char* chars;
    uint length;

    static auto opCall(const(char)* str)
    {
        String s;
        uint l = cast(uint)strlen(str);
        s.chars = cast(char*)malloc(l);
        memcpy(s.chars, str, l);
        s.length = l;
        return s;
    }

    auto opOpAssign(string op, T)(T value)
    {
        static if(op == "~")
        {
            uint l = 0;
            immutable (char)* chs;
            static if(is(T == String))
            {
                l = value.length;
                chs = cast(char*)value.chars;
            }
            else static if (is(T == string))
            {
                l = cast(uint)value.length;
                chs = value.ptr;
            }
            else static if(is(T == immutable(char)*))
            {
                l+= cast(uint)strlen(value);
                chs = value;
            }
            free(chars);
            chars = cast(char*)realloc(chars, l);
            memcpy(chars+length, chs, l);
            length+= l;
        }
        return this;
    }

    auto opAssign(T)(T value)
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
    char[] toString() const {return cast(char[])chars[0..length];}

    ~this()
    {
        if(chars != null)
            free(chars);
    }

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
    for(ulong i = 0; i < str.length; i++)
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

pure long indexOf(in string str,in string toFind, int startIndex = 0)
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

long lastIndexOf(in string str,in string toFind, long startIndex = -1) pure nothrow
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

string fromStringz(const char* cstr) pure nothrow
{
    import core.stdc.string:strlen;
    size_t len = strlen(cstr);
    return (len) ? cast(string)cstr[0..len] : null;
}

const(char*) toStringz(string str) pure nothrow
{
    return (str~"\0").ptr;
}
char toLowerCase(char c) pure nothrow @safe
{
    if(c < 'A' || c > 'Z')
        return c;
    return cast(char)(c + ('a' - 'A'));
}

string toLowerCase(string str)
{
    string ret;
    ret.reserve(str.length);
    for(ulong i = 0; i < str.length; i++)
        ret~= str[i].toLowerCase;
    return ret;
}

string[] split(string str, char separator) pure nothrow
{
    char[1] sep = [separator];
    return split(str, cast(string)sep);
}

string[] split(string str, string separator) pure nothrow
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
    return ret ~ curr;
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



string baseName(string path)
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