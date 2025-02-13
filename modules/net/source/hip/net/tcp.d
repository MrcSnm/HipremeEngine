module hip.net.tcp;
import hip.network;

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

class TCPNetwork : INetwork
{

	Socket hostSocket;
	NetConnectionStatus _status;
	Socket connectSocket;
	Socket client;

	int connectedSockets;

	Socket getSocketToSendData()
	{
		if(hostSocket !is null)
			return client;
		return connectSocket;
	}


	NetConnectionStatus host(NetIPAddress ip)
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
			client = s.accept2();
			return _status = client !is null ?  NetConnectionStatus.connected : NetConnectionStatus.waiting;
		}
		catch (SocketOSException e) //Error when multiple bindings. Make it a client
		{
			hostSocket = null;
			return _status = NetConnectionStatus.disconnected;
		}
	}


	bool isHost() const
	{
		return hostSocket !is null;
	}
	uint getConnectionID() const { return 0; }
	void setConnectedTo(uint ID) { }

	NetConnectionStatus connect(NetIPAddress ip, uint id = NetID.server)
	{
		import std.socket;
		if(hostSocket is null && connectSocket is null)
		{
			if(host(ip) == NetConnectionStatus.disconnected)
			{
				Socket s = new TcpSocket();
				connectSocket = s;
				s.blocking = false;
				s.connect(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));
				_status = !wouldHaveBlocked() ?  NetConnectionStatus.connected : NetConnectionStatus.waiting;
			}
		}

		if(isHost && (client is null || !client.isAlive))
		{
			client = hostSocket.accept2();
			return _status = client !is null ? NetConnectionStatus.connected : NetConnectionStatus.waiting;
		}

		if(connectSocket !is null)
		{
			_status = !wouldHaveBlocked() ?  NetConnectionStatus.connected : NetConnectionStatus.waiting;
		}


		return status;

	}


	bool sendData(ubyte[] data)
	{
		import std.stdio;
		if(status == NetConnectionStatus.connected)
		{
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

	size_t getData(ref ubyte[] buffer)
	{

		if(status == NetConnectionStatus.connected)
		{
			Socket s = getSocketToSendData;
			ptrdiff_t received = s.receive(buffer);
			if(received == -1)
				return 0;
			return received;
		}
		return 0;
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
	}




	NetConnectionStatus status() const { return _status; }



}