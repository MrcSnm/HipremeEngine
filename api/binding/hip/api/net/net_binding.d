module hip.api.net.net_binding;
public import hip.api.net;

version(DirectCall)
{
    public import hip.network;
}
else version(ScriptAPI)
{
    import hip.api.internal;
    void initNet()
    {
        import hip.api.internal;
        import hip.api.console;
        log("HipengineAPI: Initialized Network");
        loadClassFunctionPointers!HipNetworkBinding;
    }

    class HipNetworkBinding
    {
        extern(System) __gshared
        {
            INetwork function(NetInterface itf = NetInterface.automatic) getNetworkInterface;
        }
    }

    mixin ExpandClassFunctionPointers!HipNetworkBinding;
}