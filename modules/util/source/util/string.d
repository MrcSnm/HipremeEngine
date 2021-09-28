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
public import std.conv:to;

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

pure long lastIndexOf(in string str,in string toFind, long startIndex = -1)
{
    long z = 1;
    if(startIndex == -1) startIndex = str.length-1;
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

pure string fromStringz(const char* cstr)
{
    import core.stdc.string:strlen;
    size_t len = strlen(cstr);
    return (len) ? cast(string)cstr[0..len] : null;
}
string[] split(string str, string separator)
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


export string toString(int x)
{
    import core.stdc.stdlib:malloc;
    import core.stdc.stdio:snprintf;
    ulong length = snprintf(null, 0, "%d", x);
    char[] str;
    str.length = length+1;
    snprintf(str.ptr, length+1, "%d", x);
    return cast(string)str.ptr[0..length];
}

export string toString(float x)
{
    import core.stdc.stdlib:malloc;
    import core.stdc.stdio:snprintf;
    ulong length = snprintf(null, 0, "%f", x);
    char[] str;
    str.length = length+1;
    snprintf(str.ptr, length+1, "%f", x);
    return cast(string)str.ptr[0..length];
}
int toInt(string str)
{
    import core.stdc.stdlib:strtol;
    return strtol(str.ptr, null, 10);
}
float toFloat(string str)
{
    import core.stdc.stdlib:strtof;
    return strtof(str.ptr, null);
}

string baseName(string path)
{
    ulong lastIndex = 0;
    for(ulong i = 0; i < path.length; i++)
        if(path[i] == '/' || path[i] == '\\')
            lastIndex = i+1;

    return path[lastIndex..$];
}

string toString(T)(T struct_)
{
    string s = "(";
    bool isFirst = true;
    static foreach(m; __traits(allMembers, T))
    {
        if(!isFirst)
            s~= ", ";
        isFirst = false;
        s~= mixin("struct_."~m~".toString");
    }
    return typeof(struct_).stringof~s~")";
}

unittest
{
    assert(baseName("a/b/test.txt") == "test.txt");
    assert(toString(500) == "500");
    assert(toString(50.25)== "50.25");
    assert(split("hello world", " ").length == 2);
    assert(toDefault!int("hello") == 0);
    assert(lastIndexOf("hello, hello", "hello") == 7);
    assert(indexOf("hello, hello", "hello") == 0);
    assert(replaceAll("\nTest\n", '\n') == "Test");
}

static foreach(mem; __traits(allMembers, util.string))
{
    // static if(__traits(getOverloads, util.string, mem).length > 0)
    static foreach(i, overload; __traits(getOverloads, util.string, mem))
        pragma(msg, overload.mangleof);
        // pragma(msg, mem);
}