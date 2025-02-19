module hip.net.backend.initializer;
import hip.api.net.hipnet;
import hip.network;


/**
 *
 * Params:
 *   itf = Currently Unused. In the future, systems may support other interfaces and as such, this function will use the required information
 * for getting the correct interface.
 * Returns:
 */
INetworkBackend getNetworkImplementation(NetInterface itf)
{
    version(WebAssembly)
    {
        import hip.net.backend.websocket;
		return new WASMWebsocketNetwork();
    }
    else
    {
        import hip.net.backend.tcp;
		return new TCPNetwork();
    }
}