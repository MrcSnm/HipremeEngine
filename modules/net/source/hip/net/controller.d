module hip.net.controller;
import std.traits:isInstanceOf;
import hip.network;

/**
Example usage
```d
struct Action
{
    ubyte fromX, fromY, toX, toY;
}
struct AssignColor
{
    black,
    white
}
alias NetData = MarkNetData!(
    Action,
    AssignColor
);

alias ChessNetController = NetController!(MarkNetData!(
    Action,
    AssignColor
));

HipNetwork socket = new HipNetwork();
ChessNetController c = new ChessNetController(socket);
socket.connect(NetIPAddress("127.0.0.1", 10_000));

with(c.poll)
{
    switch(typeID)
    {
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
    static assert(isInstanceOf!(MarkNetData, NetData), "NetController only accepts NetData as an input.");

    struct NetControllerResult
    {
        NetData.idType typeID;
        ubyte[] data;

        static alias Types = NetData.Types;

        ///Reserved for the destructor freeing buffer
        private NetBufferStream* bufferStream;
        ///Reserved for the destructor freeing buffer.
        private HipNetwork net;

        static foreach(t; NetData.RegisteredTypes)
        {
            mixin("t get",t.stringof,"(){return convertNetworkData!(t)(bufferStream.header, data);}");
        }

        ~this()
        {
            if(net !is null && bufferStream !is null)
            {
                net.freeBuffer(bufferStream);
                net = null;
                bufferStream = null;
                data = null;
                typeID = 0;
            }
        }
    }

    HipNetwork network;

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

    this(HipNetwork network)
    {
        this.network = network;
    }




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
            NetBufferStream* buffer = network.getCompletedBuffer();
            ubyte[] data = buffer.getFinishedBuffer();
            NetData.idType typeID = NetData.getDataFromBuffer(data);


            switch(typeID) with(NetControllerResult.Types)
            {
                static foreach(i, t; NetData.RegisteredTypes)
                {
                    case mixin(t):
                        mixin("if(",t,"Handler !is null) ", t,"Handler(convertNetworkData!(t)(buffer.header, data));");
                        goto default;
                }
                default:
                    break;
            }
            return NetControllerResult(typeID, data, buffer, network);
        }

        return NetControllerResult(NetData.Types.invalid);
    }

}