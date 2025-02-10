module hip.net.websocket;
import hip.wasm;
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
class WASMWebsocketNetwork : INetwork
{
    WasmWebsocket socket;
    NetConnectionStatus _status;
    uint socketID = NetID.server; //That is same as invalid since a socket can't be the server.
    uint connectedTo;


    ///Buffer used if programmer tried to send data before assigning to its socket id
    private ubyte[][] scheduledDataSend;

    bool isHost() const { return false; }

    NetConnectionStatus connect(NetIPAddress ip, size_t id = NetID.server)
    {
        import hip.util.string;
        if(_status == NetConnectionStatus.waiting)
            return _status;
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
                this._status = NetConnectionStatus.connected;

            }).tupleof,
            sendJSDelegate!(()
            {
                this._status = NetConnectionStatus.disconnected;
            }).tupleof,
            sendJSDelegate!((size_t id)
            {
                socketID = id;
                foreach(data; scheduledDataSend)
                    websocketSendData(socket, socketID, connectedTo, data.length, data.ptr);
                scheduledDataSend = null;
            }).tupleof
        );

        return _status = NetConnectionStatus.waiting;
    }

    void setConnectedTo(size_t id){ connectedTo = id; }
    size_t getConnectionID() const { return socketID; }

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

    NetConnectionStatus status() const { return _status; }
}