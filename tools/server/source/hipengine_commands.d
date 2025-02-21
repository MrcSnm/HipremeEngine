module hipengine_commands;
import hip.api.net.server;


ConnectedClientsResponse getConnectedClients()
{
    import websocket_connection;
    ConnectedClientsResponse resp;
    resp.clients.length = connections.length;

    foreach(i; 0..connections.length)
    {
        resp.clients[i].connInfo = NetConnectInfo(NetIPAddress(null, 0, IPType.ipv4), connections[i].id);
    }

    return resp;
}