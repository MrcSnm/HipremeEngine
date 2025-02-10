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

private string enumFromTypes(T...)(string enumName, string enumType)
{
	string ret = "enum "~enumName~": "~enumType~"{ invalid = 0, ";
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
		void sendData(HipNetwork net, t data)
		{
			align(1)
			static struct TypedData
			{
				t actualData;
				idType typeID = i + 1; //Invalid is 0
			}
			net.sendData(TypedData(data, i+1));
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

struct NetIPAddress
{
	string ip;
	ushort port;
	IPType type = IPType.ipv4;
}

enum NetID : uint
{
	server,
	broadcast,
	start,
	end = uint.max
}


package enum NetDataType : ubyte
{
	binary,
	text,
	custom
}


align(1) struct NetHeader
{
	uint length;
	NetDataType type;

	bool invalid() const { return length == 0; }
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
	NetConnectionStatus connect(NetIPAddress ip, uint id = NetID.server);
	///Gets ID for that network connection. It can't change over its lifetime
	uint getConnectionID() const;
	///Sets that network connection connected to the specified ID
	void setConnectedTo(uint id);

	bool isHost() const;

	///Sends the data by using a header
	bool sendData(ubyte[] data);

	size_t getData(ref ubyte[] tempBuffer);
	NetConnectionStatus status() const;
}

struct NetBufferStream
{
	NetHeader header;
	size_t expectedSize() const {return header.length; }

	size_t currentOffset;

	///Buffer may be bigger than expected size as it will be reused
	ubyte[] buffer;

	///Gets the buffer only if it has already finished, and sliced to its expected size
	ubyte[] getFinishedBuffer()
	{
		if(expectedSize == 0 || !isFinished)
			return null;
		return buffer[0..expectedSize];
	}

	/**
	 *
	 * Params:
	 *   data = The data to append to this stream. The buffer is sliced to remove the size took from it.
	 * Returns: If it has already finished appending (it is based on how much data it expectes)
	 */
	bool appendData(ref ubyte[] data)
	{
		if(isFinished())
			return true;
		if(expectedSize > buffer.length)
			buffer.length = expectedSize;

		size_t remainingSize = expectedSize - currentOffset;
		size_t sizeToTake = remainingSize < data.length ? remainingSize : data.length;

		buffer[currentOffset..currentOffset+sizeToTake] = data[0..sizeToTake];
		currentOffset+= sizeToTake;
		data = data[sizeToTake..$];
		return currentOffset == expectedSize;
	}

	bool isInvalid() const { return header.invalid; }

	bool isFinished() const { return currentOffset == expectedSize; }

	///Resets it to a reusable state
	void reset()
	{
		currentOffset = 0;
		header = header.init;
	}
}

T convertNetworkData(T)(NetHeader header, ubyte[] data)
{
	import std.traits;
	static if(is(T == string))
	{
		if(header.type != NetDataType.text)
			throw new Exception("Unmatched data type when trying to get a string.");
		return cast(string)data;
	}
	else
	{
		if(header.type != NetDataType.binary)
			throw new Exception("Unmatched data type when trying to get a binary.");

		static if(isArray!T)
		{
			size_t arraySize = header.length / T.init[0].sizeof;
			static if(isStaticArray!T)
			{
				if(arraySize != T.init.length)
					throw new Exception("Received more data than the static array size of "~T.init.length.stringof);
				return (cast(T)data)[0..T.init.length];
			}
			else
			{
				return cast(T)data;
			}
		}
		else
		{
			return *cast(T*)data.ptr;
		}
	}
}


class HipNetwork
{
	INetwork netInterface;
	NetBufferStream currentStream;
	NetBufferStream[] completedStreams;
	NetBufferStream[] streamPool;

	static struct ConnectInformation
	{
		NetIPAddress ip;
		uint id;
	}
	private ConnectInformation connInfo;
	this()
	{
		netInterface = getNetworkImplementation();
	}

	NetConnectionStatus connect(NetIPAddress ip, uint id = NetID.server)
	{
		connInfo = ConnectInformation(ip, id);
		return netInterface.connect(ip, id);
	}

	bool isHost() const { return netInterface.isHost; }
	uint getConnectionID() const{return netInterface.getConnectionID();}
	void setConnectedTo(uint id){netInterface.setConnectedTo(id);}

	private NetBufferStream getNetBufferStream(NetHeader header)
	{
		NetBufferStream ret;
		if(streamPool.length > 0)
		{
			ret = streamPool[0];
			streamPool = streamPool[1..$];
			ret.header = header;
		}
		else
			ret = NetBufferStream(header);
		return ret;
	}

	/**
	 * Only returns true if the buffer has been completely loaded by the size expected by the package.
	 *
	 * This function implements a data getter API which does not block execution (if the underlying implementation is non-blocking )
	 * Params:
	 *   data = The data if this functions returns true
	 * Returns: True when package is fully received. False if not connected or still pending data
	 */
	bool getData()
	{
		import std.traits:isArray, isStaticArray;
		if(netInterface.status == NetConnectionStatus.waiting)
			connect(connInfo.ip, connInfo.id);


		if(netInterface.status != NetConnectionStatus.connected)
			return false;
		ubyte[4096] tempBufferData = void;
		ubyte[] tempBuffer = tempBufferData;

		if(completedStreams.length != 0)
			return true;

		size_t dataLength = getDataBackend(tempBuffer);
		if(dataLength == 0)
			return false;
		if(dataLength < NetHeader.sizeof)
			throw new Exception("Some bug occurred: Data received is less than a NetHeader size.");

		while(dataLength != 0)
		{
			if(currentStream.isInvalid)
			{
				currentStream = getNetBufferStream(*cast(NetHeader*)(tempBuffer.ptr));
				dataLength-= NetHeader.sizeof;
				tempBuffer = tempBuffer[NetHeader.sizeof..$];
			}

			//If it didn't fill buffer, that means there is no data left hanging, return if we completed any stream
			if(!currentStream.appendData(tempBuffer))
				return completedStreams.length != 0;


			completedStreams~= currentStream;
			dataLength-= currentStream.expectedSize;
			currentStream = currentStream.init;
		}


		return completedStreams.length != 0;
	}

	/**
	 * WARNING: It is important to call freeBuffer at some time since getting the buffer won't remove it from the queue
	 * Returns: A buffer from the completed list. You should free it at some time so its memory can be reused.
	 */
	NetBufferStream* getCompletedBuffer()
	{
		if(completedStreams.length == 0)
			throw new Exception("No data has been received yet. Wait for getData() to return true before calling that function.");
		return &completedStreams[0];
	}

	/**
	 * Make that buffer available inside the buffer pool and saves memory
	 * Params:
	 *   buffer = A buffer inside the completed list
	 */
	void freeBuffer(NetBufferStream* buffer)
	{
		for(int i = 0 ; i < completedStreams.length; i++)
			if(buffer == &completedStreams[i])
			{
				buffer.reset();
				completedStreams = completedStreams[0..i] ~ completedStreams[i+1..$];
				streamPool~= *buffer;
				i--;
			}
	}

	/**
	 * Gets the data that is in front of queue and converts the data to the expected one.
	 * The correct usage of this function is to use it after `getData()`.
	 * If it has no data, an exception will be thrown
	 * Params:
	 *   data = Data from getData
	 * Returns:
	 */
	T getDataAsType(T)()
	{
		NetBufferStream* stream = getCompletedBuffer();
		ubyte[] data = stream.getFinishedBuffer();
		scope(exit)
			freeBuffer(stream);
		return convertNetworkData(stream.header, data);
	}


	void sendData(T)(T data)
	{
		import std.traits:isDynamicArray;
		static if(is(T == string))
		{
			NetHeader header = NetHeader(cast(uint)data.length, NetDataType.text);
		}
		else
		{
			static if(isDynamicArray!T)
			{
				NetHeader header = NetHeader(cast(uint)(T.init[0].sizeof*data.length), NetDataType.binary);
			}
			else
			{
				NetHeader header = NetHeader(T.sizeof, NetDataType.binary);
			}
		}


		ubyte[] newData = toNetworkBytes(toBytes(header, data));
		if(!netInterface.sendData(newData))
		{
			// import std.stdio;
			// throw new Error("Could not send data");
			return;
		}
	}
	private size_t getDataBackend(ref ubyte[] data)
	{
		size_t ret = netInterface.getData(data);
		if(ret != 0)
		{
			data = data[0..ret];
			toNetworkBytesInPlace(data);
		}
		return ret;
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