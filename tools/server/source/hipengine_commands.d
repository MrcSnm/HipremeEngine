module hipengine_commands;
import hip.api.net.server;



/**
 * Reusable buffer to be returned by getConnectedClients
 */
private ConnectedClientsResponse respBuffer;

ConnectedClientsResponse getConnectedClients(uint fromSocketID)
{
    import websocket_connection;
    respBuffer.clients.length = connections.length > 0 ? connections.length - 1 : connections.length;
    uint index = 0;

    foreach(i; 0..connections.length)
    {
        if(connections[i].id != fromSocketID)
            respBuffer.clients[index++].connInfo = NetConnectInfo(NetIPAddress(null, 0, IPType.ipv4), connections[i].id + NetID.start);
    }

    return respBuffer;
}