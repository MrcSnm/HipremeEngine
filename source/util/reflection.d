/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module util.reflection;
int asInt(alias enumMember)()
{
    alias T = typeof(enumMember);
    foreach(i, mem; __traits(allMembers, T))
    {
        if(mem == enumMember.stringof)
            return i;
    }
    assert(0, "Member "~enumMember.stringof~" from type " ~ T.stringof~ " does not exist");
}


bool isLiteral(alias variable)(string var = variable.stringof)
{
    import std.string : isNumeric;
    import std.algorithm : count;
    return (isNumeric(var) || count(var, "\"") == 2);
}