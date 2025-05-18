module hip.network;
import hip.console.log;
import hip.api.net.utils;
import hip.api.net.hipnet;

struct NetBufferStream
{
	NetBuffer self;

	size_t currentOffset;

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


	bool isFinished() const { return currentOffset == expectedSize; }

	///Resets it to a reusable state
	void reset()
	{
		currentOffset = 0;
		header = header.init;
	}

	alias self this;
}


interface INetworkBackend
{
	/**
	 *
	 * Params:
	 *   ip = The IP to connect
	 *   onConnect = Used for sending messages on the connect. WARNING: If you're using NetController, do not call `connect` from that interface.
	 *   id = ID of the address to connect to. Relevant when you're not using a P2P connection. Enforced when using websockets, since direct connection is unavailable.
	 * Returns: The connection status
	 */
	NetConnectStatus connect(NetIPAddress ip, void delegate() onConnect, uint id = NetID.server);
	/**
	 * Tries to reconnect to the same address on initial connect.
	 */
	void attemptReconnection();
	///Gets ID for that network connection. It can't change over its lifetime
	uint getConnectionSelfID() const;

	///Gets ID for the currently target network connection. Changed with the setter
	uint targetConnectionID() const;
	///Sets that network connection connected to the specified ID
	void targetConnectionID(uint id);

	bool isHost() const;

	///Sends the data by using a header
	bool sendData(ubyte[] data);

	void disconnect();

	size_t getData(ref ubyte[] tempBuffer);
	NetConnectStatus status() const;
}

final class HipNetwork : INetwork
{
	INetworkBackend netInterface;
	NetInterface itf;
	NetBufferStream currentStream;
	NetBufferStream[] completedStreams;
	NetBufferStream[] streamPool;

	private NetConnectInfo connInfo;
	private bool attemptedConnection;
	private void delegate() onConnect;

	this(NetInterface itf)
	{
		import hip.net.backend.initializer;
		this.itf = itf;
		netInterface = getNetworkImplementation(itf);
	}

	NetConnectStatus connect(NetIPAddress ip, void delegate(INetwork) onConnect, uint id = NetID.server)
	{
		if(!attemptedConnection)
			attemptedConnection = true;
		connInfo = NetConnectInfo(ip, id);
		this.onConnect = (){onConnect(this);};

		return netInterface.connect(ip, this.onConnect, id);
	}

	bool isHost() const { return netInterface.isHost; }
	uint getConnectionSelfID() const{return netInterface.getConnectionSelfID();}
	uint targetConnectionID() const {return netInterface.targetConnectionID();}
	void targetConnectionID(uint id){netInterface.targetConnectionID(id);}

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
			ret = NetBufferStream(NetBuffer(header));
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
		if(netInterface.status == NetConnectStatus.waiting)
			netInterface.connect(connInfo.ip, this.onConnect, connInfo.id);
		if(netInterface.status == NetConnectStatus.attemptingReconnect)
		{
			hiplog("Trying to reconnect.");
			netInterface.attemptReconnection();
		}

		if(netInterface.status != NetConnectStatus.connected)
			return false;
		if(completedStreams.length != 0)
			return true;

		ubyte[4096] tempBufferData = void;
		ubyte[] tempBuffer = tempBufferData;


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
	NetBuffer* getCompletedBuffer() const
	{
		if(completedStreams.length == 0)
			throw new Exception("No data has been received yet. Wait for getData() to return true before calling that function.");
		return cast(NetBuffer*)&completedStreams[0];
	}

	/**
	 * Make that buffer available inside the buffer pool and saves memory
	 * Params:
	 *   buffer = A buffer inside the completed list
	 */
	void freeBuffer(NetBuffer* b)
	{
		NetBufferStream* buffer = cast(NetBufferStream*)b;
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
		return interpretNetworkData(stream.header, data);
	}

	void sendDataRaw(ubyte[] data)
	{
		netInterface.sendData(data);
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

	void disconnect()
	{
		if(status == NetConnectStatus.connected)
		{
			send_disconnect(this);
			netInterface.disconnect();
		}
	}
	NetConnectStatus status() const { return netInterface.status; }
	NetInterface getNetInterfaceType() const { return itf; }
	NetConnectInfo getConnectInfo() const { return connInfo; }

}

private __gshared INetwork[] netConnections;

export extern(System) INetwork getNetworkInterface(NetInterface itf = NetInterface.automatic)
{
	netConnections~= new HipNetwork(itf);
	return netConnections[$-1];
}


/**
 * Disconnects every net connection that was loaded at the beginning.
 */
void disconnectNetwork()
{
	foreach(conn; netConnections)
		conn.disconnect();
	netConnections = null;
}