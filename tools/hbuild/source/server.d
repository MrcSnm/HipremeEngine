module server;
import handy_httpd;
import websocket_connection;
public import websocket_connection: pushWebsocketMessage;
import core.sync.semaphore;

enum DEFAULT_PATH="build";
private __gshared string startPath;
private __gshared ushort port = 9000;


int hipengineStartServer(string[] args, shared ushort* serverPort, string servePath, shared Semaphore sem)
{
    import std.stdio;
	import handy_httpd.handlers.path_handler;
	import core.thread;

	import slf4d.default_provider;
	import slf4d;
	auto provider = new DefaultProvider(false, Levels.ERROR);
	configureLoggingProvider(provider);
	ServerConfig cfg;
	cfg.port = port;
	cfg.workerPoolSize = 3;
	cfg.enableWebSockets = true; // Important! Websockets won't work unless `enableWebSockets` is set to true!
	WebSocketHandler ws = new WebSocketHandler(new WebSocketReloadServer());
	PathHandler pathHandler = new PathHandler()
		.addMapping(Method.GET, "/ws", ws)
		.addMapping("/**", &serveGameFiles);

	*serverPort = port;
	startPath = servePath;
	writeln("HipremeEngine Dev Server listening from localhost:", port, " path ", startPath);
	(cast()sem).notify;

	new HttpServer(pathHandler, cfg).start();

	return 0;
}


private __gshared HttpRequestContext* context;

void serveGameFiles(ref HttpRequestContext ctx)
{
	synchronized
	{
		if(context is null)
			context = &ctx;
	}
    import std.path;
    import std.stdio;
	import std.file;
	import std.string;
	import std.conv;

	if(ctx.request.method != Method.GET)
		return;

	string path = ctx.request.url.length > 0 ? ctx.request.url : "/";
    string targetPath = buildNormalizedPath(startPath, DEFAULT_PATH);
	string contentType = contentTypeFromFileExtension(path);
	string file = buildNormalizedPath(targetPath, path[1..$]);


	string result;

	if(path == "/")
	{
		string indexHTML = buildNormalizedPath(targetPath, "index.html");
		contentType = "text/html; charset=utf8";
		if(exists(indexHTML))
		{
			import std.string;
			string reloadServer = replace(import("reload_server.js"), "$WEBSOCKET_SERVER$", "ws://localhost:"~port.to!string~"/ws");
			result = readText(indexHTML)~"<script> "~reloadServer~"</script>";
		}
		else
		{
			// index
			string html = "<html><head><title>Hipreme Engine Webassembly Server</title></head><body><ul>";
			foreach(string name; dirEntries(targetPath, SpanMode.shallow))
			{
				name = name[targetPath.length..$];
				html ~= "<li><a href=\"" ~ name ~ "\">" ~ name ~"</a></li>";
			}
			html~= "</body></html>";
			result = html;
		}
	}
	else if(contentType)
	{
		if(!exists(file))
		{
			ctx.response.status = HttpStatus.NOT_FOUND;
			result = "404 file not found";
		}
		else
		{
			ctx.response.addHeader("Access-Control-Expose-Headers", "Content-Length");
			ctx.response.status = HttpStatus.OK;
			if(contentType.startsWith("text"))
				result = readText(file);
			else
				result = cast(string)read(file);
			writeln("GET ", file, " 200");
		}
	}


	ctx.response.writeBodyString(result, contentType);

}

string contentTypeFromFileExtension(string filename)
{
	import std.path;
	string ext = filename.extension;
	switch(ext)
	{
		case ".png":
			return "image/png";
		case ".apng":
			return "image/apng";
		case ".svg":
			return "image/svg+xml";
		case ".jpg":
			return "image/jpeg";
		case ".html":
			return "text/html";
		case ".css":
			return "text/css";
		case ".js":
			return "application/javascript";
		case ".wasm":
			return "application/wasm";
		case ".mp3":
			return "audio/mpeg";
		case ".pdf":
			return "application/pdf";
		case ".ogg":
			return "application/ogg";
		case ".mp4":
			return "application/mp4";
		default:
			return "application/octet-stream";
	}
}

void stopServer()
{
	pushWebsocketMessage("close");
	context.server.stop();
}