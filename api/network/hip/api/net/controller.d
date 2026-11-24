module hip.api.net.controller;
public import hip.api.net.hipnet;
import hip.util.binary : fromPackedBytes, getStructFromPackedBytes, getArrayFromPackedBytes;

alias getNetworkStruct = getStructFromPackedBytes;
alias getNetworkArray = getArrayFromPackedBytes;

/**
Example usage
```d
struct Action
{
    ubyte fromX, fromY, toX, toY;
}

struct BoardState
{
    Action[] actions;
}
struct AssignColor
{
    black,
    white
}

alias ChessNetController = NetController!(MarkNetData!(
    Action,
    AssignColor,
    BoardState
));

ChessNetController c = new ChessNetController(getNetworkInterface);
c.connect(NetIPAddress("127.0.0.1", 10_000));
c.on_connect(()
{
    c.sendData([BoardState()]);
});
c.on_disconnect(()
{
    logg("Waiting for other player to connect...");
});

with(c.poll)
{
    switch(typeID)
    {
        case Types.disconnect: //Disconnect event has no data
            break;
        case Types.Action:
            Action act = getAction();
            break;
        case Types.AssignColor:
            AssignColor c = getAssignColor();
            break;
        default: //Received an invalid typeID.
            break;
    }
}
```
*/
class NetController(alias NetData)
{
    import std.traits:isInstanceOf;
    import hip.api.net.server;
    import hip.util.reflection;
    static assert(isInstanceOf!(MarkNetData, NetData), "NetController only accepts NetData as an input.");

    struct NetControllerResult
    {
        NetData.idType typeID;
        ubyte[] data;

        static alias Types = NetData.Types;

        ///Reserved for the destructor freeing buffer
        private NetBuffer* buffer;
        ///Reserved for the destructor freeing buffer.
        private INetwork net;

        static foreach(t; NetData.RegisteredTypes)
        {
            mixin("t get",t.stringof,"(){return interpretNetworkData!(t)(buffer.header, data);}");
        }

        ~this()
        {
            if(net !is null && buffer !is null)
            {
                net.freeBuffer(buffer);
                net = null;
                buffer = null;
                data = null;
                typeID = 0;
            }
        }
    }

    INetwork network;
    protected void delegate() connectFn;
    protected void delegate() disconnectFn;

    static foreach(m; __traits(allMembers, MarkedNetReservedTypes))
    {
        static if(Attributes!(MarkedNetReservedTypes, m).length)
        {
            static if(is(Attributes!(MarkedNetReservedTypes, m)[0].Response == void))
            {
                mixin("protected void delegate() on_",m,"_fn;\n",
                      "void on_",m,"(void delegate() v){ on_",m,"_fn = v;}"
                );
            }
            else
            {
                mixin("protected void delegate(Attributes!(MarkedNetReservedTypes, m)[0].Response) on_",m,"_fn;\n",
                      "void on_",m,"(void delegate(Attributes!(MarkedNetReservedTypes, m)[0].Response) v){ on_",m,"_fn = v;}"
                );
            }
        }
    }

    static foreach(t; NetData.RegisteredTypes)
    {
        mixin("protected void delegate(t) ", t.stringof, "Handler;");
        void registerHandler(void delegate(t) handler)
        {
            mixin(t.stringof, "Handler = handler;");
        }

        /**
         * Send the data. It can only send data via this NetController if it is part of one of the
         * registered types from the MarkNetData
         *
         * Params:
         *   data = Data that will be sent with a type information
         */
        void sendData(t data)
        {
            NetData.sendData(network, data);
        }
    }

    /**
     * Use `targetConnectionID` if you wish to change the ID after connection.
     *
     * Params:
     *   ip = The IPAddress to connect
     *   id = The ID within the IP
     * Returns: Status. Almost always will be pending
     */
    NetConnectStatus connect(NetIPAddress ip, uint id = NetID.server)
    {
        return network.connect(ip, (INetwork net)
        {
            net.send_connect();
            // getConnectedClients();
        }, id);
    }


    void getConnectedClients()
    {
        network.send_get_connected_clients();
    }

    pragma(inline, true)
    final uint getConnectionSelfID() const{return network.getConnectionSelfID();}

    pragma(inline, true)
	final void targetConnectionID(uint id){network.targetConnectionID(id);}

    pragma(inline, true)
	final uint targetConnectionID() const {return network.targetConnectionID();}

    pragma(inline, true)
	final bool isHost() const { return network.isHost; }

    this(INetwork network){this.network = network;}

    /**
     * Polls the result from the socket/network data.
     *
     * WARNING: For getting correct data type, you MUST send the data using either NetData.sendData or
     * NetController.sendData
     *
     * If you send through the socket, no type info will be sent together.
     *
     * Returns: A result that includes the typeID, sliced data and managed net buffer.
     */
    NetControllerResult poll()
    {
        if(network.getData())
        {
            NetBuffer* buffer = network.getCompletedBuffer();
            ubyte[] data = buffer.getFinishedBuffer();
            NetData.idType typeID = NetData.getDataFromBuffer(data);

            switch(typeID) with(NetControllerResult.Types)
            {
                static foreach(i, t; NetData.RegisteredTypes)
                {
                    case mixin(t):
                        mixin("if(",t,"Handler !is null) ", t,"Handler(interpretNetworkData!(t)(buffer.header, data));");
                        goto default;
                }
                static foreach(m; __traits(allMembers, MarkedNetReservedTypes))
                {
                    static if(Attributes!(MarkedNetReservedTypes, m).length)
                    {
                        case mixin(m):
                            alias fn = mixin("on_",m,"_fn");
                            static if(is(Attributes!(MarkedNetReservedTypes, m)[0].Response == void))
                            {
                                if(fn) fn();
                            }
                            else
                            {
                                if(fn) fn(interpretNetworkData!(Parameters!(fn)[0])(buffer.header, data));
                            }
                            goto default;
                    }
                }
                default:
                    break;
            }
            return NetControllerResult(typeID, data, buffer, network);
        }

        return NetControllerResult(NetData.Types.invalid);
    }
}

T interpretNetworkData(T)(NetHeader header, ubyte[] data)
{
	import std.traits;
	static if(is(T == string))
	{
		if(header.type != NetDataType.text)
			throw new Exception("Unmatched data type when trying to get a string.");
		return cast(string)data;
	}
    else static if(is(T == struct))
    {
        return getNetworkStruct!T(data);
    }
	else
	{
		if(header.type != NetDataType.binary)
			throw new Exception("Unmatched data type when trying to get a binary.");

		static if(isDynamicArray!T)
			return getArrayFromPackedBytes!T(data);
		else
			return fromPackedBytes!T(data);
	}
}