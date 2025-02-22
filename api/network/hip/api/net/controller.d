module hip.api.net.controller;
public import hip.api.net.hipnet;

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
c.registerConnect(()
{
    c.sendData([BoardState()]);
});
c.registerDisconnect(()
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
    protected void delegate(ConnectedClientsResponse) getConnectedClientsFn;

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

    NetConnectStatus connect(NetIPAddress ip, uint id = NetID.server)
    {
        return network.connect(ip, (INetwork net)
        {
            net.sendConnect();
            // getConnectedClients();
        }, id);
    }


    void getConnectedClients()
    {
        network.requestConnectedClients();
    }



    void onConnect(void delegate() fn){ connectFn = fn; }
    void onDisconnect(void delegate() fn){ disconnectFn = fn; }
    void onGetConnectedClients(void delegate(ConnectedClientsResponse) fn){ getConnectedClientsFn = fn; }

    pragma(inline, true)
    final uint getConnectionID() const{return network.getConnectionID();}

    pragma(inline, true)
	final void setConnectedTo(uint id){network.setConnectedTo(id);}

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
                case connect:
                    if(connectFn !is null) connectFn();
                    break;
                case disconnect:
                    if(disconnectFn !is null) disconnectFn();
                    break;
                case get_connected_clients:
                    if(getConnectedClientsFn !is null) getConnectedClientsFn(interpretNetworkData!(ConnectedClientsResponse)(buffer.header, data));
                    break;
                default:
                    break;
            }
            return NetControllerResult(typeID, data, buffer, network);
        }

        return NetControllerResult(NetData.Types.invalid);
    }
}

T getNetworkArray(T, E = typeof(T.init[0]))(ubyte[] data)
{
    import hip.api.net.utils;
    assert(data.length >= 4, "Data received is not an actual array since it is smaller than a length element.");
    uint length = *(cast(uint*)data.ptr);
    static if(hasDynamicArray!E) //Dynamic arrays for type of dynamic size
    {
        T temp;
        temp.length = length;
        size_t offset = uint.sizeof;
        foreach(i; 0..length)
        {
            temp[i] = getNetworkStruct!(E)(data[offset..$]);
            offset+= getSendTypeSize(temp[i]);
        }
        return temp;
    }
    else //Static size
    {
        assert(data.length >= 4 + length * E.sizeof, "Data received is not valid.Not enough space available for type "~E.stringof);
        return (cast(E*)(data.ptr + uint.sizeof))[0..length].dup;
    }
}


T getNetworkStruct(T)(ubyte[] data)
{
    import hip.api.net.utils;
    import std.traits:isDynamicArray;

    static if(hasDynamicArray!T)
    {
        T ret;
        size_t offset;
        foreach(ref v; ret.tupleof)
        {
            static if(isDynamicArray!(typeof(v)))
                v = getNetworkArray!(typeof(v))(data[offset..$]);
            else
                v = getNetworkStruct!(typeof(v))(data[offset..$]);
            offset+= getSendTypeSize(v);
        }
        return ret;
    }
    else
    {
        assert(data.length >= T.sizeof, "Data length is not enough to be interpreted as "~T.stringof);
        return *cast(T*)data.ptr;
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

		static if(isArray!T)
		{
			size_t arraySize = header.length / T.init[0].sizeof;
			static if(isStaticArray!T)
			{
				if(arraySize != T.init.length)
					throw new Exception("Received more data than the static array size of "~T.init.length.stringof);
				return (cast(T)data)[0..T.init.length];
			}
			else
			{
				return cast(T)data;
			}
		}
		else
		{
			return *cast(T*)data.ptr;
		}
	}
}