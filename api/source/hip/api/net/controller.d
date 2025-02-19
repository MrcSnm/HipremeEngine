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
    protected void delegate() connectHandler;
    protected void delegate() disconnectHandler;

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
            NetData.sendConnect(net);
        }, id);
    }



    void registerConnect(void delegate() fn){ connectHandler = fn; }
    void registerDisconnect(void delegate() fn){ disconnectHandler = fn; }

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


            import hip.api;
            logg("Received data of type ", typeID);


            switch(typeID) with(NetControllerResult.Types)
            {
                static foreach(i, t; NetData.RegisteredTypes)
                {
                    case mixin(t):
                        mixin("if(",t,"Handler !is null) ", t,"Handler(interpretNetworkData!(t)(buffer.header, data));");
                        goto default;
                }
                case connect:
                    if(connectHandler !is null) connectHandler();
                    break;
                case disconnect:
                    if(disconnectHandler !is null) disconnectHandler();
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
    assert(data.length >= 4, "Data received is not an actual array since it is smaller than a length element.");
    uint length = *(cast(uint*)data.ptr);
    assert(data.length >= 4 + length * E.sizeof, "Data received is not valid.Not enough space available for type "~E.stringof);
    return (cast(E*)(data.ptr + uint.sizeof))[0..length].dup;
}


T getNetworkStruct(T)(NetHeader header, ubyte[] data)
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
            {
                static if(hasDynamicArray!((typeof(v.init[0]))))
                {
                    v = getNetworkStruct(header, data[offset..$]);
                    offset+= getSendTypeSize(v);
                }
                else ///Dynamic arrays for types of constant size.
                {
                    v = getNetworkArray!(typeof(v))(data[offset..$]);
                    offset+= typeof(v).sizeof+v.length;
                }
            }
            else
            {
                v = *cast(typeof(v)*)(data.ptr + offset);
                offset+= typeof(v).sizeof;
            }
        }
        return ret;
    }
    else
        return *cast(T*)data.ptr;
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
        return getNetworkStruct!T(header, data);
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