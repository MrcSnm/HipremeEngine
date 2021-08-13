/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
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