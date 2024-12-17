module websocket_connection;
import handy_httpd;

class WebSocketReloadServer: WebSocketMessageHandler
{
    // ctx.server.stop(); // Calling stop will gracefully shutdown the server.

    private size_t wsID;

    override void onConnectionEstablished(WebSocketConnection conn)
    {
        synchronized
        {
            connections~= Connection(id);
            wsID = id++;
        }
    }

    override void onTextMessage(WebSocketTextMessage msg)
    {
        import std.stdio;
        import std.algorithm.searching;

        Connection conn = Connection(wsID);
        string text = msg.payload; //Irrelevant here

        synchronized
        {
            foreach(socketMsg; conn.messages)
                msg.conn.sendTextMessage(socketMsg);
            conn.messages.length = 0;
        }

        // infoF!"Got TEXT: %s"(msg.payload);
    }

    override void onCloseMessage(WebSocketCloseMessage msg)
    {
        import std.algorithm.searching;
        import std.stdio;
        synchronized
        {
            ptrdiff_t index = countUntil!((Connection c) => c.id == wsID)(connections);
            if(index != -1)
            {
                connections = connections[0..index]~ connections[index+1..$];
            }
        }
        writeln("AutoReloading WebSocket[", wsID, "] closed.");

        // infoF!"Closed: %d, %s"(msg.statusCode, msg.message);
    }
}
void pushWebsocketMessage(string message)
{
	synchronized
	{
		foreach(ref conn; connections)
			conn.messages~= message;
	}
}


struct Connection
{
	size_t id;
	string[] messages;
}
private __gshared size_t id;
private __gshared Connection[] connections;