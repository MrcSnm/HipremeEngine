module websocket_connection;
import core.sync.mutex;
import handy_httpd;

enum NetID : size_t
{
    server,
    broadcast,
    start,
    end = size_t.max
}

class WebSocketReloadServer: WebSocketMessageHandler
{
    // ctx.server.stop(); // Calling stop will gracefully shutdown the server.
    Connection* thisConnection;
    this()
    {
        wsMutex = new shared Mutex;
    }
    override void onConnectionEstablished(WebSocketConnection conn)
    {
        synchronized(wsMutex)
        {
            connections~= thisConnection = new Connection(conn);
        }
    }

    override void onCloseMessage(WebSocketCloseMessage msg)
    {
        import std.algorithm.searching;
        import std.stdio;
        synchronized
        {
            ptrdiff_t index = countUntil!((Connection* c) => c.socket == msg.conn)(connections);
            if(index != -1)
            {
                connections = connections[0..index]~ connections[index+1..$];
            }
            writeln("AutoReloading WebSocket[", index, "] closed.");
        }

        // infoF!"Closed: %d, %s"(msg.statusCode, msg.message);
    }
}
void pushWebsocketMessage(string message)
{
	synchronized(wsMutex)
	{
		foreach(ref conn; connections)
        {
            conn.socket.sendTextMessage(message);
        }
	}
}


struct Connection
{
    WebSocketConnection socket;
}
private __gshared Connection*[] connections;
private shared Mutex wsMutex;