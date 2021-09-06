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

string replaceAll(string str, char what, string replaceWith = "")
{
    string ret;
    for(int i = 0; i < str.length; i++)
    {
        if(str[i] != what) ret~= str[i];
        else if(replaceWith != "") ret~=replaceWith;
    }
    return ret;
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
    assert(replaceAll("\nTest\n", '\n') == "Test");
}