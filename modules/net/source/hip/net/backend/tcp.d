module hip.net.backend.tcp;
import hip.network;
import hip.api.net.hipnet;

version(WebAssembly){}
else:
import std.socket;

/**
 * Abstracts away different behaviors from Windows - Posix.
 * Posix throws an exception, while Windows return a client which is not alive.
 * Params:
 *   host = The socket which will accept
 * Returns: Accepted socket or null.
 */
Socket accept2(Socket host)
{
	Socket ret;
	try
	{
		ret = host.accept();
		if(ret is null || !ret.isAlive)
			return null;
		ret.blocking = false;
	}
	catch (SocketAcceptException e) ///This error is always thrown by Linux if it is not blocking
		return null;
	return ret;
}

class TCPNetwork : INetworkBackend
{

	Socket hostSocket;
	NetConnectStatus _status;
	Socket connectSocket;
	Socket client;
	SocketSet readSet, writeSet, errSet;
	void delegate() onConnect;

	/**
	 * It is useful to send some messages right after connecting the socket.
	 * The problem is that sometimes, this data can't be sent.
	 * To solve that issue, this data is accumulated, and thus, is sent in either
	 * getData or sendData, the one which is called first.
	 * After that, accumulated data becomes unused.
	 */
	ubyte[] accumulatedData;

	int connectedSockets;

	this()
	{
		readSet = new SocketSet();
		writeSet = new SocketSet();
		errSet = new SocketSet();
	}

	protected ptrdiff_t getEventCount()
	{
		import hip.util.data_structures:staticArray;

		foreach(set; [readSet, writeSet, errSet].staticArray)
		{
			set.reset();
			foreach(sock; [hostSocket, connectSocket, client].staticArray)
			{
				if(sock !is null)
					set.add(sock);
			}
		}
		TimeVal zero;
		return Socket.select(readSet, writeSet, null, &zero);
	}

	Socket getSocketToSendData()
	{
		if(hostSocket !is null)
			return client;
		return connectSocket;
	}


	NetConnectStatus host(NetIPAddress ip)
	{
		Socket s = new TcpSocket();
		hostSocket = s;
		s.blocking = false;
		// s.setOption(SocketOptionLevel.SOCKET, SocketOption.LINGER, 1);
		// s.setOption(SocketOptionLevel.SOCKET, SocketOption.DEBUG, 1);

		try
		{
			s.bind(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));
			s.listen(1);
			if(getEventCount() > 0  && readSet.isSet(s))
				client = s.accept2();
			return setStatus(client !is null ?  NetConnectStatus.connected : NetConnectStatus.waiting);
		}
		catch (SocketOSException e) //Error when multiple bindings. Make it a client
		{
			hostSocket = null;
			return _status = NetConnectStatus.disconnected;
		}
	}


	bool isHost() const
	{
		return hostSocket !is null;
	}
	uint getConnectionSelfID() const { return 0; }
	void targetConnectionID(uint ID) { }
	uint targetConnectionID() const { return 0;}

	NetConnectStatus connect(NetIPAddress ip, void delegate() onConnect, uint id = NetID.server)
	{
		import std.socket;
		this.onConnect = onConnect;
		if(hostSocket is null && connectSocket is null)
		{
			if(host(ip) == NetConnectStatus.disconnected)
			{
				Socket s = new TcpSocket();
				connectSocket = s;
				s.blocking = false;
				s.connect(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));
				setStatus(!wouldHaveBlocked() ?  NetConnectStatus.connected : NetConnectStatus.waiting);
			}
		}

		if(isHost && (client is null || !client.isAlive))
		{
			if(getEventCount() > 0 && readSet.isSet(hostSocket))
				client = hostSocket.accept2();
			return setStatus(client !is null ? NetConnectStatus.connected : NetConnectStatus.waiting);
		}

		if(connectSocket !is null)
		{
			setStatus(!wouldHaveBlocked() ?  NetConnectStatus.connected : NetConnectStatus.waiting);
		}

		return status;
	}

	NetConnectStatus setStatus(NetConnectStatus stat)
	{
		_status = stat;
		switch(stat)
		{
			case NetConnectStatus.connected:
				if(onConnect !is null) onConnect();
				break;
			default:
				break;
		}
		return stat;
	}


	bool sendData(ubyte[] data)
	{
		import std.stdio;
		if(status == NetConnectStatus.connected)
		{
			if(getEventCount() == 0 || !writeSet.isSet(getSocketToSendData))
			{
				///Accumulates the data if it can't be sent.
				accumulatedData~= data.dup;
				return false;
			}
			else
				unfillBuffer();
			if(getSocketToSendData == client)
				writeln("Sending ", data, " to client. ");
			else if(getSocketToSendData == connectSocket)
				writeln("Sending data to host ");
			ptrdiff_t res = getSocketToSendData.send(data);
			if(res ==  0|| res == -1) //Socket closed
				return false;
			return true;
		}
		return false;
	}

	/**
	 * This function was designed to avoid calling getEventCount().
	 * Be sure to only call that function after a getEventCount() function call.
	 */
	private void unfillBuffer()
	{
		if(accumulatedData.length == 0)
			return;
		if(writeSet.isSet(getSocketToSendData))
		{
			import core.memory;
			ubyte[] dataToSend = accumulatedData;
			accumulatedData = null;
			sendData(dataToSend);
			GC.free(dataToSend.ptr);
		}
	}

	size_t getData(ref ubyte[] buffer)
	{
		if(status == NetConnectStatus.connected)
		{
			Socket s = getSocketToSendData;
			bool canRead = getEventCount() > 0 && readSet.isSet(s);
			unfillBuffer();
			if(canRead)
			{
				ptrdiff_t received = s.receive(buffer);
				if(received == 0)
				{
					_status = NetConnectStatus.attemptingReconnect;
				}
				if(received == -1)
					return 0;
				return received;
			}
		}
		return 0;
	}

	void attemptReconnection()
	{
		if(status == NetConnectStatus.attemptingReconnect)
		{
			Socket s = getSocketToSendData();
			if(s !is null)
			{
				s.shutdown(SocketShutdown.BOTH);
				s.close();
			}
			if(hostSocket !is null)
				client = null;

			_status = NetConnectStatus.waiting;
		}
	}

	void disconnect()
	{
		Socket s = getSocketToSendData;
		if(s is null)
			return;
		s.shutdown(SocketShutdown.BOTH);
		s.close();
		hostSocket = null;
		client = null;
		connectSocket = null;
		_status = NetConnectStatus.disconnected;
	}

	NetConnectStatus status() const { return _status; }
}