module network;

enum NetID : uint
{
    server,
    broadcast,
    start,
    end = uint.max
}


T hton(T)(T data) @nogc nothrow pure
{
    import std.socket;

	static if(T.sizeof == 2)
		return htons(data);
	else static if(T.sizeof == 4)
		return htonl(data);
}

ubyte[N] toBytes(T, uint N = T.sizeof)(T input) @nogc nothrow pure
{
    ubyte[N] ret;
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

alias fromNetworkBytes = toNetworkBytes;