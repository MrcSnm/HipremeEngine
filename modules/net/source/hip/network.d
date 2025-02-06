module hip.network;
import hip.console.log;
import hip.net.utils;

enum NetConnectionStatus
{
	disconnected,
	connected,
	waiting,
}


enum IPType
{
	ipv4,
	ipv6
}


struct NetIPAddress
{
	string ip;
	ushort port;
	IPType type = IPType.ipv4;
}

enum NetID : size_t
{
	server,
	broadcast,
	start,
	end = size_t.max
}


package enum NetDataType : ubyte
{
	binary,
	text,
	custom
}


struct NetHeader
{
	NetDataType type;
	uint length;
}

interface INetwork
{
	/**
	 *
	 * Params:
	 *   ip = The IP to connect
	 *   id = ID of the address to connect to. Relevant when you're not using a P2P connection. Enforced when using websockets, since direct connection is unavailable.
	 * Returns: The connection status
	 */
	NetConnectionStatus connect(NetIPAddress ip, size_t id = NetID.server);
	///Gets ID for that network connection. It can't change over its lifetime
	size_t getConnectionID() const;
	///Sets that network connection connected to the specified ID
	void setConnectedTo(size_t id);

	///Sends the data by using a header
	bool sendData(ubyte[] data);

	ubyte[] getData();
	NetConnectionStatus status() const;
}


class HipNetwork
{
	INetwork netInterface;

	this()
	{
		netInterface = getNetworkImplementation();
	}




	NetConnectionStatus connect(NetIPAddress ip, size_t id = NetID.server){return netInterface.connect(ip, id);}
	size_t getConnectionID() const{return netInterface.getConnectionID();}
	void setConnectedTo(size_t id){netInterface.setConnectedTo(id);}


	T getData(T)()
	{
		import std.traits:isArray, isStaticArray;
		struct DataReceived
		{
			NetHeader header;
			T data;
		}

		ubyte[] buffer = getData();
		if(buffer is null)
			return T.init;

		DataReceived netPkg = *cast(DataReceived*)buffer.ptr;

		static if(is(T == string))
		{
			if(netPkg.header.type != NetDataType.text)
				throw new Exception("Unmatched data type when trying to get a string.");
			return cast(string)(buffer.ptr+NetHeader.sizeof)[0..netPkg.header.length];
		}
		else
		{
			if(netPkg.header.type != NetDataType.binary)
				throw new Exception("Unmatched data type when trying to get a binary.");

			static if(isArray!T)
			{
				size_t arraySize = netPkg.header.length / T.init[0].sizeof;
				static if(isStaticArray!T)
				{
					if(arraySize != T.init.length)
						throw new Exception("Received more data than the static array size of "~T.init.length.stringof);
					return netPkg.data.ptr[0..T.init.length];
				}
				else
				{
					ubyte[] actualData = (buffer.ptr + NetHeader.sizeof)[0..netPkg.header.length];

					return cast(T)actualData;
				}
			}
			else
			{
				return netPkg.data;
			}
		}

	}


	void sendData(T)(T data)
	{
		import std.traits:isDynamicArray;
		static if(is(T == string))
		{
			NetHeader header = NetHeader(NetDataType.text, cast(uint)data.length);
		}
		else
		{
			static if(isDynamicArray!T)
			{
				NetHeader header = NetHeader(NetDataType.binary, cast(uint)(T.init[0].sizeof*data.length));
			}
			else
			{
				NetHeader header = NetHeader(NetDataType.binary, T.sizeof);
			}
		}
		if(!netInterface.sendData(toNetworkBytes(toBytes(header, data))))
		{
			// writeln("Could not send data");
			return;
		}
	}
	private ubyte[] getData()
	{
		ubyte[] data = netInterface.getData();
		if(data is null)
			return null;
		return fromNetworkBytes(data);
	}
	NetConnectionStatus status() const { return netInterface.status; }

}


version(WebAssembly)
{
	INetwork getNetworkImplementation()
	{
		import hip.net.websocket;
		return new WASMWebsocketNetwork();
	}
}
else
{
	INetwork getNetworkImplementation()
	{
		import hip.net.tcp;
		return new TCPNetwork();
	}
}