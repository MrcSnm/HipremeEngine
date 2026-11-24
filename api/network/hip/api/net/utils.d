module hip.api.net.utils;
public import hip.util.binary;


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
	import hip.util.reflection : hasDynamicArray;

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

	// assert(getTypeSize(b) == 12);
	// import hip.api.net.hipnet;

	// assert(getTypeSize(NetHeader.init, b) == 17);
	// assert(toBytes(NetHeader.init, b).length == 17);

	import std.stdio;

	// writeln = getTypeSize(t.tester);
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

	assert(getTypeSize(c) == 11);


	respData = respData[NetHeader.sizeof..$-1];
	assert(respData.length == 15);

	auto interpreted =  getNetworkStruct!(ConnectedClientsResponse)(respData);

	// writeln = interpreted.type;
	assert(interpreted == resp);
}