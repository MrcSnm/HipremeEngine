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
            return i;
        z = 1;
    }
    return -1;
}