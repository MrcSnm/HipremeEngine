module hip.net.utils;

T hton(T)(T data) @nogc nothrow pure
{
    import std.socket;

	static if(T.sizeof == 2)
		return htons(data);
	else static if(T.sizeof == 4)
		return htonl(data);
}

size_t sizeofTypes(T...)() @nogc nothrow pure
{
	static size_t ret;
	if(ret == 0)
	{
		foreach (t; T)
			ret+= t.sizeof;
	}
	return ret;
}

ubyte[sizeofTypes!T] toBytes(T...)(T input) @nogc nothrow pure
{
    typeof(return) ret;
	size_t offset;
	static foreach(i, t; T)
	{
		ret[offset..offset+t.sizeof] = toBytes(input[i]);
		offset+= t.sizeof;
	}
    return ret;
}

ubyte[N] toBytes(T, uint N = T.sizeof)(T input) @nogc nothrow pure
{
    ubyte[N] ret;
    ret[] = (cast(ubyte*)&input)[0..N];
    return ret;
}

bool isLittleEndian()
{
    uint value = 1;
    return (cast(ubyte*)&value)[0] == 1;
}

ubyte[N] swapEndian(uint N)(ubyte[N] bytes) @nogc nothrow pure
{
    ubyte[N] swapped;
    foreach (i; 0 .. N)
        swapped[i] = bytes[N - 1 - i];
    return swapped;
}


ubyte[N] toNetworkBytes(T, uint N = T.sizeof)(T input) @nogc nothrow pure
{
    ubyte[N] ret = toBytes(input);
    return isLittleEndian ? swapEndian(ret) : ret;
}

///Same implementation, must go back from big to little or kepe it as it is
alias fromNetworkBytes = toNetworkBytes;





ubyte[N] toNetwork(T, uint N = T.sizeof)(T data) @nogc nothrow pure
{
	ubyte[N] ret;
	static foreach(mem; __traits(allMembers, T))
	{{
		alias member = __traits(getMember, T, mem);

		static if(member.sizeof == 1)
			ret[member.offsetof] = cast(ubyte)__traits(child, data, member);
		else static if(
			is(typeof(member) == uint) ||
			is(typeof(member) == ushort) ||
			is(typeof(member) == int) ||
			is(typeof(member) == short)
		)
			ret[member.offsetof..member.offsetof + member.sizeof] = toBytes(hton(__traits(child, data, member)));
		else
			ret[member.offsetof..member.offsetof + member.sizeof] = toNetworkBytes(__traits(child, data, member));
	}}
	return ret;
}
