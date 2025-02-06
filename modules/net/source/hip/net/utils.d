module hip.net.utils;
import std.traits;

T hton(T)(T data) @nogc nothrow pure
{
	version(WebAssembly)
	{
		return *(cast(T*)toNetworkBytes(data).ptr);
	}
	else
	{
		import std.socket;
		static if(T.sizeof == 2)
			return htons(data);
		else static if(T.sizeof == 4)
			return htonl(data);
	}
}

size_t sizeofTypes(T...)() @nogc nothrow pure
{
	size_t ret;
	foreach (t; T)
		ret+= t.sizeof;
	return ret;
}

bool hasDynamicArray(T...)()
{
	static foreach(t; T)
	{
		static if(isDynamicArray!t)
			return true;
	}
	return false;
}

@nogc nothrow pure
ubyte[sizeofTypes!T] toBytes(T...)(T input) if(!hasDynamicArray!(T))
{
    typeof(return) ret = void;
	size_t offset;
	static foreach(i, t; T)
	{
		ret[offset..offset+t.sizeof] = toBytes!(t, t.sizeof)(input[i]);
		offset+= t.sizeof;
	}
    return ret;
}
ubyte[] toBytes(T...)(T input)
{
	ubyte[] ret;
	size_t offset;
	foreach(i, t; T)
	{
		static if(isDynamicArray!t)
		{
			size_t sz = input[i].length * t.init[0].sizeof;
			ret.length+= sz;
			ret[offset..offset+sz] = (cast(ubyte*)input[i].ptr)[0..sz];
			offset+= sz;
		}
		else
		{
			ret.length+= t.sizeof;
			ret[offset..offset+t.sizeof] = toBytes(input[i]);
			offset+= t.sizeof;
		}
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

ubyte[] swapEndian(ubyte[] bytes)
{
    ubyte[] swapped;
	swapped.length = bytes.length;
    foreach (i; 0 .. bytes.length)
        swapped[i] = bytes[bytes.length - 1 - i];
    return swapped;
}
ubyte[] toNetworkBytes(ubyte[] input)
{
    return isLittleEndian ? swapEndian(input) : input;
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
