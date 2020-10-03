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