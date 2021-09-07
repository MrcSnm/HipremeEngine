/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
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

pure long lastIndexOf(in string str,in string toFind)
{
    long z = 1;
    for(long i = str.length-1; i >= 0; i--)
    {
        while(str[i-z+1] == toFind[$-z] && z < toFind.length)
            z++;
        if(z == toFind.length)
            return i-z+1;
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

unittest
{
    assert(toDefault!int("hello") == 0);
    assert(lastIndexOf("hello, hello", "hello") == 7);
    assert(indexOf("hello, hello", "hello") == 0);
    assert(replaceAll("\nTest\n", '\n') == "Test");
}