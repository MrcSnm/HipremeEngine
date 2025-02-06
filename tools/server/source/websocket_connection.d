module websocket_connection;
import std.stdio;
import network;
import core.sync.mutex;
import handy_httpd;

class HipremeEngineWebSocketServer: WebSocketMessageHandler
{
    // ctx.server.stop(); // Calling stop will gracefully shutdown the server.
    this()
    {
        wsMutex = new shared Mutex;
    }

    private uint wsID;

    override void onConnectionEstablished(WebSocketConnection conn)
    {
        // synchronized(wsMutex)
        {
            import std.socket:htonl;
            Connection* c;
            if(freeIdsList.length)
            {
                uint last = freeIdsList[$-1];
                freeIdsList = freeIdsList[0..$-1];
                c = connections[last];
                c.socket = conn;
                writeln("Socket ID ", NetID.start + c.id, " reacquired");
            }
            else
            {
                connections~= c = new Connection(id, conn);
                wsID = id++;
            }
            uint data = NetID.start + c.id;
            conn.sendBinaryMessage(toBytes(data));
            writeln("Socket ID ", data, " connected");
        }
    }

    override void onTextMessage(WebSocketTextMessage msg)
    {
        import std.stdio;
        import std.algorithm.searching;

        string text = msg.payload; //Irrelevant here

        // infoF!"Got TEXT: %s"(msg.payload);
    }

    /**
     * Specification:
     * 4 bytes is the from socket ID
     * 4 bytes is the to socket ID
     *
     * Remaining bytes are the data frame
     *
     * Params:
     *   msg =
     */
    override void onBinaryMessage(WebSocketBinaryMessage msg)
    {
        import std.stdio;
        import std.socket;

        uint fromSocketID = *cast(uint*)msg.payload[0..4];
        uint toSocketID = *cast(uint*)msg.payload[4..8];
        ubyte[] data = msg.payload[8..$];

        writeln("Socket ", fromSocketID, " is sending ", data, " to socket ", toSocketID);

    }

    override void onCloseMessage(WebSocketCloseMessage msg)
    {
        import std.algorithm.searching;
        import std.conv:to;
        synchronized
        {
            ptrdiff_t index = countUntil!((Connection* c) => c.socket == msg.conn)(connections);
            if(index != -1)
            {
                writeln("Socket ", NetID.start + connections[index].id, " closed");
                connections[index].socket = null;
                freeIdsList~= index.to!uint;
            }
        }
    }
}


struct Connection
{
	uint id;
    WebSocketConnection socket;
}
private __gshared uint id;
private __gshared Connection*[] connections;

private __gshared uint[] freeIdsList;
private shared Mutex wsMutex;