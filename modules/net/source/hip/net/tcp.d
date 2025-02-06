module hip.net.tcp;
import hip.network;

version(WebAssembly){}
else:

class TCPNetwork : INetwork
{
	import std.socket;
	Socket hostSocket;
	Socket connectSocket;
	Socket client;
	int connectedSockets;

	Socket getSocketToSendData()
	{
		if(hostSocket)
			return client;
		return connectSocket;
	}


	NetConnectionStatus host(NetIPAddress ip)
	{
		Socket s = new TcpSocket();
		hostSocket = s;
		s.blocking = true;
		s.setOption(SocketOptionLevel.SOCKET, SocketOption.LINGER, 1);
		s.setOption(SocketOptionLevel.SOCKET, SocketOption.DEBUG, 1);


		s.bind(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));
		s.listen(1);
		client = s.accept();


		// writeln = getData(client).get!string;

		return NetConnectionStatus.connected;
	}
	size_t getConnectionID() const { return 0; }
	void setConnectedTo(size_t ID) { }

	NetConnectionStatus connect(NetIPAddress ip, size_t id = NetID.server)
	{
		import std.socket;
		Socket s = new TcpSocket();
		connectSocket = s;
		s.blocking = true;
		s.connect(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));


		return NetConnectionStatus.connected;

	}


	bool sendData(ubyte[] data)
	{
		ptrdiff_t res = getSocketToSendData.send(data, SocketFlags.DONTROUTE);
		if(res ==  0|| res == SOCKET_ERROR) //Socket closed
			return false;
		return true;
	}

	ubyte[] getData()
	{
		ubyte[] buffer;
		Socket s = getSocketToSendData;
		ptrdiff_t received = s.receive(buffer, SocketFlags.PEEK);
		if(received == 0)
			throw new Exception("Closed Connection.");
		else if(received == -1)
			throw new Exception("Network Error: "~s.getErrorText);
		else
		{
			buffer.length = received;
			if(s.receive(buffer) != buffer.length)
				throw new Exception("Data size changed after peeking?");
		}
		return buffer;
	}




	NetConnectionStatus status() const { return NetConnectionStatus.connected; }



}