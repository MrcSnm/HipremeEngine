module hip.net.controller;
import std.traits:isInstanceOf;
import hip.network;

class NetController(alias NetData)
{
    static assert(isInstanceOf!(MarkNetData, NetData), "NetController only accepts NetData as an input.");

    HipNetwork network;

    static foreach(t; NetData.RegisteredTypes)
    {
        mixin("protected void function(t) ", t.stringof, "Handler;");
    }

    void registerHandler(T)(void function(T) handler)
    {
        static assert(!NetData.isUnknown!T, "Can't register handler for unknown type. ("~T.stringof~")");

        mixin(T.stringof, "Handler = handler;");
    }
    this(HipNetwork network)
    {
        this.network = network;
    }

    uint poll(out ubyte[] data)
    {
        data = network.getData();
        if(data !is null)
            return *cast(uint*)data.ptr; //Return type id
        return NetData.invalid;
    }

}