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