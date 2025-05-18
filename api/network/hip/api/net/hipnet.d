module hip.api.net.hipnet;
public import hip.api.net.server;


/**
 * Network module is one which can't be abstracted much.
 * That happens because, by using templates, it is possible to reduce the
 * memory footprint required for sending and getting data.
 * The implementation of sending data without templates would likely require to allocate memory
 * on heap instead of stack.
 *
 * So, most functionality will actually be implemented on API instead of inside the engine module.
 *
 */


enum NetConnectStatus
{
	///Represents basically a blank state where it can transition to connected or waiting
	disconnected,
	///It is currently connected and getting data will actually send the data instead of trying to connect.
	connected,
	///It is attempting to connect to the specified IP+ID Address
	waiting,
	///It was connected, but for some reason, client sent a disconnect message and now it is trying to reconnect
	attemptingReconnect
}


enum IPType : ubyte
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

/**
 * Currently, tcp is used everywhere and websockets are used on WASM
 */
enum NetInterface
{
	automatic,
    tcp,
    websocket
}

/**
 * Those are the NetIDs that your server must implement.
 * Basically, 0 is ought to be a message that the server must interpret
 * While 1 is the broadcast one. The IDs are mostly relevant to WebSockets
 */
enum NetID : uint
{
	server,
	broadcast,
	start,
	end = uint.max
}

/**
 * Currently, only binary seems to be relevant.
 * Custom + might be reserved for implementing known formats (such as JSON)
 */
package enum NetDataType : ubyte
{
	binary,
	text,
	custom
}


/**
 * Usage of Alignment(1) can reduce the memory footprint.
 * It also should use a fixed size type since there will be no surprises when running
 * the code via another platform or something like that.
 */
struct NetHeader
{
	align(1):
	uint length;
	NetDataType type;

	bool invalid() const { return length == 0; }
}

struct NetConnectInfo
{
    NetIPAddress ip;
    uint id;
}

template NetBinding(Req, Resp)
{
	alias Request = Req;
	alias Response = Resp;
}


struct NetBuffer
{
	///The header may change after some time since it will be reused.
	NetHeader header;
	///Buffer may be bigger than expected size as it will be reused
	ubyte[] buffer;

	size_t expectedSize() const {return header.length; }
	bool isInvalid() const { return header.invalid; }

	///Gets the buffer only if it has already finished, and sliced to its expected size
	ubyte[] getFinishedBuffer()
	{
		if(expectedSize == 0)
			return null;
		return buffer[0..expectedSize];
	}
}

/**
 * Those are the reserved type IDs that are found in every MarkNetData instance.
 * Since a new instance of this enum is created, the reserved types are written
 * snake-cased.
 * Custom type members will have the exact same name as the type they intend to use.
 *
 *	connect: void send_connect(INetwork)
 *	disconnect: void send_disconnect(INetwork)
 *	get_connected_clients: send_get_connected_clients(INetwork)
 *  client_connect: send_client_connect(INetwork, uint targetID)
 */
enum MarkedNetReservedTypes : ubyte
{
	invalid,
	///Send that message so NetController can identify that a network connection was established.
	@NetBinding!(void, void) connect,
	///Send that message so NetController can identify that a network interface was disconnected
	@NetBinding!(void, void) disconnect,
	///Sends a message to the server requesting for the available connection IDs
	@NetBinding!(void, ConnectedClientsResponse) get_connected_clients,
	///The ID to connect to. Must be a valid ID received from get_connected_clients
	@NetBinding!(uint, ConnectToClientResponse) client_connect
}

template Attributes(T, string mem)
{
	alias Attributes = __traits(getAttributes, __traits(getMember, T, mem));
}

static foreach(m; __traits(allMembers, MarkedNetReservedTypes))
{
	static if(Attributes!(MarkedNetReservedTypes, m).length)
	{
		static if(is(Attributes!(MarkedNetReservedTypes, m)[0].Request == void))
		{
			mixin("void send_",m,"(INetwork net){",
			"net.sendDataToServer(__traits(getMember, MarkedNetReservedTypes, m));}");
		}
		else
		{
			mixin("void send_",m,"(INetwork net, Attributes!(MarkedNetReservedTypes, m)[0].Request d){",
			"pragma(LDC_no_typeinfo) static struct Data { align(1): MarkedNetReservedTypes t; Attributes!(MarkedNetReservedTypes, m)[0].Request data;} ",
			"net.sendDataToServer(Data(__traits(getMember, MarkedNetReservedTypes, m), d));}");
		}
	}
}


/**
 * This function is only used inside MarkNetData, this allows to create automatically an enum which is used
 * for being able to iterate type safely through its members on NetController.
 *
 * Params:
 *   enumName = Enum name that will be generated
 *   enumType = The enum type
 * Returns: A string to be mixed which defines a new enum.
 */
private string enumFromTypes(T...)(string enumName, string enumType)
{
	string ret = "enum "~enumName~": "~enumType~"{";
	foreach(mem; __traits(allMembers, MarkedNetReservedTypes))
		ret~= mem ~ ", ";
	static foreach(t; T)
	{
		static assert(is(t == struct) || is(t == enum), "MarkNetData only works for enums and structs.");
		ret~=  t.stringof~",";
	}
	return ret~"}";
}


/**
 * Creates a set of types which
 * Params:
 *   T = The types that are valid to send on network.
 */
template MarkNetData(T...)
{
	enum PredefinedTypesCount = __traits(allMembers, MarkedNetReservedTypes).length;

	static if(T.length <= ubyte.max)
		alias idType = ubyte;
	else static if(T.length <= ushort.max)
		alias idType = ushort;

	mixin(enumFromTypes!(T)("Types", "idType"));

	string getTypeName(idType v)
	{
		static foreach(t; T)
		{
			if(v == __traits(getMember, Types, t.stringof))
				return t.stringof;
		}
		return "Unknown";
	}

    bool isInvalid(idType v)
    {
        return v == 0 || v >= T.length;
    }

	static foreach(i, t; T)
	{
		void sendData(INetwork net, t data)
		{
			align(1)
			static struct TypedData
			{
				t actualData;
				idType typeID = i + PredefinedTypesCount;
			}
			net.sendData(TypedData(data, i+PredefinedTypesCount));
		}
	}

	/**
	 * To its data removing the type id.
	 * Params:
	 *   buffer = The buffer that is used to take the type id and slices it to the actual data
	 * Returns: The type id from that buffer. Also enforces it is not invalid
	 */
	Types getDataFromBuffer(ref ubyte[] buffer)
	{
		idType typeID = *cast(idType*)(buffer.ptr + buffer.length - idType.sizeof);
		buffer = buffer[0..buffer.length - idType.sizeof];
		return cast(Types)typeID;
	}



    bool isUnknown(Q)()
    {
        static foreach(t; T)
			static if(is(t == Q))
            	return false;
        return true;
    }

	alias RegisteredTypes = T;
}


/**
 * Implementation currently follows at `hip.network`
 */
interface INetwork
{
	/**
	 *
	 * Params:
	 *   ip = The IP to connect
	 *   onConnect = Delegate to execute when connecting
	 *   id = ID of the address to connect to. Relevant when you're not using a P2P connection. Enforced when using websockets, since direct connection is unavailable.
	 * Returns: The connection status
	 */
	NetConnectStatus connect(NetIPAddress ip, void delegate(INetwork) onConnect, uint id = NetID.server);
	///Gets ID for that network connection. It can't change over its lifetime
	uint getConnectionSelfID() const;
	///Sets that network connection connected to the specified ID
	void targetConnectionID(uint id);
	uint targetConnectionID() const;
	bool isHost() const;
    ///Returns whether it has got any data
	NetConnectStatus status() const;
    NetInterface getNetInterfaceType() const;
    NetConnectInfo getConnectInfo() const;
    ///Returns if there is any data available to take
	bool getData();
    ///Sends the data without modifying it further. It is called like that since it will be able to overload with templates
	void sendDataRaw(ubyte[] data);

	/**
	 * WARNING: It is important to call freeBuffer at some time since getting the buffer won't remove it from the queue
	 * This function must only be called after getData() returns true.
	 * Returns: A buffer stream or [a datagram buffer](This one is only on future)
	 */
	NetBuffer* getCompletedBuffer() const;
	/**
	 * Make that buffer available inside the buffer pool and saves memory
	 * Params:
	 *   buffer = A buffer inside the completed list
	 */
	void freeBuffer(NetBuffer* buffer);

    /**
     * Due to performance reasons, toNetworkBytes and toBytes needs to be in api instead of back implementation.
     * This allows to use non-allocating memory when sending data.
     * Keep in mind that the data is converted to big endian before being sent.
     * Params:
     *   data = Any data type wanted to send
     */
    void sendData(T)(T data)
	{
		import std.traits:isDynamicArray;
        import hip.api.net.utils;
		uint size = getSendTypeSize(data);

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
		sendDataRaw(toNetworkBytes(toBytes(header, data)));
	}

	final void withServerTarget(scope void delegate() dg)
	{
		uint currID = targetConnectionID;
		targetConnectionID = NetID.server;
		scope(exit)
			targetConnectionID = currID;
		dg();
	}


	void sendDataToServer(T)(T data)
	{
		withServerTarget((){sendData(data);});
	}

	void disconnect();
	final bool isConnected() const { return status == NetConnectStatus.connected; }

}