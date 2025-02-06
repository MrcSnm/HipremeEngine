module hip.net.tcp;
import hip.network;

version(WebAssembly){}
else:

class TCPNetwork : INetwork
{
	import std.socket;

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
		s.blocking = true;
		s.setOption(SocketOptionLevel.SOCKET, SocketOption.LINGER, 1);
		s.setOption(SocketOptionLevel.SOCKET, SocketOption.DEBUG, 1);

		try
		{
			s.bind(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));
			s.listen(1);
			client = s.accept();
			return _status = NetConnectionStatus.connected;
		}
		catch (Exception e)
		{
			hostSocket = null;
			return _status = NetConnectionStatus.disconnected;
		}

		// writeln = getData(client).get!string;

	}
	size_t getConnectionID() const { return 0; }
	void setConnectedTo(size_t ID) { }

	NetConnectionStatus connect(NetIPAddress ip, size_t id = NetID.server)
	{
		import std.socket;

		if(host(ip) == NetConnectionStatus.disconnected)
		{
			Socket s = new TcpSocket();
			connectSocket = s;
			s.blocking = true;
			s.connect(ip.type == IPType.ipv4 ? new InternetAddress(ip.ip, ip.port) : new Internet6Address(ip.ip, ip.port));
		}

		return _status = NetConnectionStatus.connected;

	}


	bool sendData(ubyte[] data)
	{
		import std.stdio;

		if(getSocketToSendData == client)
			writeln("Sending ", data, " to client. ");
		else if(getSocketToSendData == connectSocket)
			writeln("Sending data to host ");
		ptrdiff_t res = getSocketToSendData.send(data, SocketFlags.DONTROUTE);
		if(res ==  0|| res == SOCKET_ERROR) //Socket closed
			return false;
		return true;
	}

	ubyte[] getData()
	{
		ubyte[4096] buffer;
		ubyte[] ret;
		Socket s = getSocketToSendData;
		ptrdiff_t received = s.receive(buffer, SocketFlags.PEEK);
		if(received == 0)
			return null;
		else if(received == -1)
			throw new Exception("Network Error: "~s.getErrorText);
		else
		{
			ret.length = received;
			s.receive(ret);
		}
		return ret;
	}




	NetConnectionStatus status() const { return _status; }



}