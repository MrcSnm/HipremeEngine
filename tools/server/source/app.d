import core.sync.mutex;
import websocket_connection;
import handy_httpd;

int hipengineStartServer(string[] args, ushort port)
{
    import std.stdio;
	import handy_httpd.handlers.path_handler;
	import core.thread;

	import slf4d.default_provider;
	import slf4d;
	auto provider = new DefaultProvider(false, Levels.ERROR);
	configureLoggingProvider(provider);
	ServerConfig cfg;
	cfg.hostname = "0.0.0.0";
	cfg.port = port;
	cfg.workerPoolSize = 3;
	cfg.enableWebSockets = true; // Important! Websockets won't work unless `enableWebSockets` is set to true!
	WebSocketHandler ws = new WebSocketHandler(new HipremeEngineWebSocketServer());
	PathHandler pathHandler = new PathHandler()
		.addMapping(Method.GET, "/ws", ws);

	writeln("Hipreme Engine Net Server is at localhost:", port,"/ws");

	new HttpServer(pathHandler, cfg).start();

	return 0;
}



int main(string[] args)
{
    hipengineStartServer(args, 10000);
    return 0;
}