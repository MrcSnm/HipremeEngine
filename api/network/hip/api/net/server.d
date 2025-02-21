/** 
 * This file is a base for communication between client-server.
 * Since that happens, structures inside that file should be shared by being implemented on the server, and the client
 * will be able to interpret the data correctly.
 */
module hip.api.net.server;
public import hip.api.net.hipnet;


struct ConnectedClient
{
	NetConnectInfo connInfo;
}

/**
 * Whenever the client makes a request for the server on the connected clients, that is the structure that should be returned.
 */
pragma(LDC_no_typeinfo)
struct ConnectedClientsResponse
{
	ConnectedClient[] clients;
}

ubyte[] getNetworkFormattedData(T)(T data, MarkedNetReservedTypes code)
{
	import hip.api.net.utils;
	import std.traits:isDynamicArray;
	import std.stdio;

	uint size = getSendTypeSize(data) + cast(uint)ubyte.sizeof;

	static if(is(T == string))
	{
		NetHeader header = NetHeader(size, NetDataType.text);
	}
	else
	{
		static if(isDynamicArray!T)
		{
			NetHeader header = NetHeader(size, NetDataType.binary);
		}
		else
		{
			NetHeader header = NetHeader(size, NetDataType.binary);
		}
	}


	return toNetworkBytes(toBytes(header, data, code));
}
