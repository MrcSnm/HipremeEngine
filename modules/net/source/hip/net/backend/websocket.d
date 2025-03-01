module hip.net.backend.websocket;
import hip.wasm;
import hip.api.net.hipnet;
public import hip.network;

version(WebAssembly):
import hip.util.sumtype;

alias WasmWebsocket = size_t;
extern(C) WasmWebsocket connectWebsocket(
    JSStringType url,
    JSDelegateType!(void delegate()) onConnected,
    JSDelegateType!(void delegate()) onClose,
    JSDelegateType!(void delegate(size_t id)) onFirstMessage
);
extern(C) void closeWebsocket(WasmWebsocket);
extern(C) void websocketSendData(WasmWebsocket, uint from, uint to, size_t length, ubyte* dataPtr);
extern(C) ubyte* websocketGetData(WasmWebsocket);


/**
 * Specification:
 *  - The first message received by a Hipreme Engine websocket must always be its own connection ID.
 */
class WASMWebsocketNetwork : INetworkBackend
{
    WasmWebsocket socket;
    NetConnectStatus _status;
    uint socketID = NetID.server; //That is same as invalid since a socket can't be the server.
    uint connectedTo = NetID.server;
    void delegate() onConnect;


    ///Buffer used if programmer tried to send data before assigning to its socket id
    private ubyte[][] scheduledDataSend;

    bool isHost() const { return false; }

    NetConnectStatus connect(NetIPAddress ip, void delegate() onConnect, size_t id = NetID.server)
    {
        import hip.util.string;
        if(_status == NetConnectStatus.waiting)
            return _status;
        this.onConnect = onConnect;
        connectedTo = id;
        String s;
        if(!ip.ip.startsWith("ws://"))
            s = String("ws://", ip.ip);
        else
            s = String(ip.ip);

        if(ip.port != 0)
            s = String(s, ":", ip.port, "/ws");

        socket = connectWebsocket(
            JSString(s.toString).tupleof,
            sendJSDelegate!(()
            {
                this._status = NetConnectStatus.connected;
            }).tupleof,
            sendJSDelegate!(()
            {
                this._status = NetConnectStatus.disconnected;
            }).tupleof,
            sendJSDelegate!((size_t id)
            {
                import hip.console.log;
                socketID = id;
                this.onConnect();
                logln("Connection Established. Socket ID: ", id, " connected to ", connectedTo);
                foreach(data; scheduledDataSend)
                    websocketSendData(socket, socketID, connectedTo, data.length, data.ptr);
                scheduledDataSend = null;
            }).tupleof
        );

        return _status = NetConnectStatus.waiting;
    }

    void targetConnectionID(size_t id)
    {
        connectedTo = id;
        if(connectedTo == socketID)
        {
            import hip.util.string;
            throw new Exception(String("Tried to connect socket ", connectedTo, " to its same ID.").toString);
        }
    }
    size_t getConnectionSelfID() const { return socketID; }
    size_t targetConnectionID() const { return connectedTo; }

    bool sendData(ubyte[] data)
    {
        if(socketID < NetID.start)
            scheduledDataSend~= data;
        else
            websocketSendData(socket, socketID, connectedTo, data.length, data.ptr);
        return true;
    }

    uint getData(ref ubyte[] tempBuffer)
    {
        tempBuffer = getWasmArray(websocketGetData(socket));
        return tempBuffer.length;
    }

    void disconnect()
    {
        if(socket != 0)
        {
            closeWebsocket(socket);
            socket = 0;
        }
    }

    void attemptReconnection()
    {

    }

    NetConnectStatus status() const { return _status; }
}