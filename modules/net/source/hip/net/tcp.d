module hip.net.tcp;
import hip.network;

version(WebAssembly){}
else:
import std.socket;

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
		s.setOption(SocketOptionLevel.SOCKET, SocketOption.LINGER, 1);
		s.setOption(SocketOptionLevel.SOCKET, SocketOption.DEBUG, 1);

		try
		{
			s.bind(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));
			s.listen(1);
			client = s.accept();
			return _status = client.isAlive ?  NetConnectionStatus.connected : NetConnectionStatus.waiting;
		}
		catch (Exception e)
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

		if(isHost && !client.isAlive)
		{
			client = hostSocket.accept();
			return _status = client.isAlive ? NetConnectionStatus.connected : NetConnectionStatus.waiting;
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
			ptrdiff_t res = getSocketToSendData.send(data, SocketFlags.DONTROUTE);
			if(res ==  0|| res == SOCKET_ERROR) //Socket closed
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
			// 	throw new Exception("Network Error: "~s.getErrorText);
			return received;
		}
		return 0;
	}




	NetConnectionStatus status() const { return _status; }



}