module hip.api.net.utils;
import std.traits;


extern(C) @safe pure @nogc
{
    ushort htons(ushort x);
    uint htonl(uint x);
    ushort ntohs(ushort x);
    uint ntohl(uint x);
}

T hton(T)(T data) @nogc nothrow pure
{
	version(WebAssembly)
	{
		return *(cast(T*)toNetworkBytes(data).ptr);
	}
	else
	{
		static if(T.sizeof == 2)
			return htons(data);
		else static if(T.sizeof == 4)
			return htonl(data);
	}
}

size_t sizeofTypes(T...)() @nogc nothrow pure if(!hasDynamicArray!T)
{
	size_t ret;
	foreach (t; T)
		ret+= t.sizeof;
	return ret;
}

bool hasDynamicArray(T)()
{
	static if(is(T == struct))
	{
		foreach(v; T.init.tupleof)
		{
			static if(hasDynamicArray!(typeof(v)))
				return true;
		}
		return false;
	}
	else
		return isDynamicArray!T;
}

/**
 * Used for determining if the data can be copied to stack and sent. This is the most efficient way to send data
 * since it won't allocate on frame.
 * Returns: If the type sequence has a dynamic array
 */
bool hasDynamicArray(T...)()
{
	static foreach(t; T)
	{
		static if(hasDynamicArray!t)
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

void copyIntoMemory(T)(T struc, ubyte[] memory)
{
	static if(is(T == struct) && hasDynamicArray!T)
	{
		uint sz;
		foreach(v; struc.tupleof)
		{
			uint tSize = getSendTypeSize(v);
			copyIntoMemory(v, memory[sz..sz+tSize]);
			sz+= tSize;
		}
	}
	else static if(isDynamicArray!T)
	{
		memory[0..uint.sizeof] = toBytes(cast(uint)struc.length);

		static if(hasDynamicArray!(typeof(T.init[0])))
		{
			size_t offset = uint.sizeof;
			foreach(i; 0..struc.length)
			{
				size_t sz = getSendTypeSize(struc[i]);
				copyIntoMemory(struc[i], memory[offset..offset+sz]);
				offset+= sz;
			}
		}
		else
		{
			size_t sz = struc.length * T.init[0].sizeof;
			memory[uint.sizeof..uint.sizeof+sz] = (cast(ubyte*)struc.ptr)[0..sz];
		}
	}
	else
	{
		memory[] = toBytes(struc);
	}
}

ubyte[] toBytes(T...)(T input) if(hasDynamicArray!T)
{
	import std.stdio;

	ubyte[] ret;
	size_t offset;
	foreach(i, t; T)
	{
		size_t sz = getSendTypeSize(input[i]);
		ret.length+= sz;
		copyIntoMemory(input[i], ret[offset..offset+sz]);
		offset+= sz;
	}
	return ret;
}

uint getSendTypeSize(T...)(const T input) if(T.length > 1)
{
	uint sz;
	foreach(i, t; T)
	{
		sz+= getSendTypeSize(input[i]);
	}
	return sz;
}

uint getSendTypeSize(T)(const T input = T.init) if(!is(T == struct) && !isDynamicArray!T)
{
	return T.sizeof;
}
uint getSendTypeSize(T)(const T input = T.init) if(isDynamicArray!T)
{
	uint sz = uint.sizeof;
	static if(hasDynamicArray!(T))
	{
		foreach(v; input)
		{
			sz+= getSendTypeSize(v);
		}
	}
	else
	{
		sz+= T.init[0].sizeof * input.length;
	}
	return sz;
}

uint getSendTypeSize(T)(const T input = T.init) if(is(T == struct))
{
	uint sz;
	foreach(v; input.tupleof)
	{
		static if(hasDynamicArray!(typeof(v)))
		{
			sz+= getSendTypeSize(v);
		}
		else
		{
			sz+= typeof(v).sizeof;
		}
	}
	return sz;
}

ubyte[N] toBytes(T, uint N = T.sizeof)(T input) @nogc nothrow pure
{
    ubyte[N] ret = void;
    ret[] = (cast(ubyte*)&input)[0..N];
    return ret;
}

bool isLittleEndian() @nogc nothrow pure
{
    uint value = 1;
    return (cast(ubyte*)&value)[0] == 1;
}

ubyte[N] swapEndian(uint N)(ubyte[N] bytes) @nogc nothrow pure
{
    ubyte[N] swapped = void;
    foreach (i; 0 .. N)
        swapped[i] = bytes[N - 1 - i];
    return swapped;
}

ubyte[] swapEndian(const ubyte[] bytes)
{
    ubyte[] swapped;
	swapped.length = bytes.length;
    foreach (i; 0 .. bytes.length)
        swapped[i] = bytes[bytes.length - 1 - i];
    return swapped;
}

void swapEndianInPlace(ref ubyte[] bytes) @nogc nothrow pure
{
    foreach (i; 0 .. bytes.length / 2)
    {
        auto tmp = bytes[i];
        bytes[i] = bytes[bytes.length - 1 - i];
        bytes[bytes.length - 1 - i] = tmp;
    }
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


void toNetworkBytesInPlace(ref ubyte[] bytes) @nogc nothrow pure
{
	if(isLittleEndian)
		swapEndianInPlace(bytes);
}

alias fromNetworkBytesInPlace = toNetworkBytesInPlace;




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


unittest
{
	struct Ultra
	{
		int[] a;
	}

	struct EvenTester
	{
		Ultra[] tester;
	}
	assert(hasDynamicArray!Ultra);
	Ultra b;
	b.a~= [500, 200];

	EvenTester t;
	t.tester~= b;

	// assert(getSendTypeSize(b) == 12);
	// import hip.api.net.hipnet;

	// assert(getSendTypeSize(NetHeader.init, b) == 17);
	// assert(toBytes(NetHeader.init, b).length == 17);

	import std.stdio;

	// writeln = getSendTypeSize(t.tester);
}

unittest
{
	import hip.api.net.server;
	import hip.api.net.controller;
	import hip.api.net.hipnet;

	ConnectedClientsResponse resp;

	ConnectedClient c = ConnectedClient(NetConnectInfo(NetIPAddress(null, 0, IPType.ipv4), 0));
	resp.clients~= [c];

	ubyte[] sendData = getNetworkFormattedData(resp, MarkedNetReservedTypes.get_connected_clients);
	ubyte[] respData = fromNetworkBytes(sendData);

	assert(getSendTypeSize(c) == 11);


	respData = respData[NetHeader.sizeof..$-1];
	assert(respData.length == 15);

	auto interpreted =  getNetworkStruct!(ConnectedClientsResponse)(respData);

	// writeln = interpreted.type;
	assert(interpreted == resp);
}