module serve;

import arsd.cgi;
import std.stdio;
import std.file;
import std.string;
import std.process;

// -Wl,--export=__heap_base

// https://github.com/skoppe/wasm-sourcemaps

enum DEFAULT_PATH="build";
private __gshared string startPath;

string extendedContentTypeFromFileExtension(string thing)
{
	string ret = contentTypeFromFileExtension(thing);
	if(ret != null)
		return ret;

	if(ret.endsWith(".ogg"))
		return "application/ogg";
	if(ret.endsWith(".mp4"))
		return "application/mp4";

	return "application/octet-stream";
}

import core.thread;
import core.sync.mutex;
void pushWebsocketMessage(string message)
{
	synchronized
	{
		foreach(ref conn; connections)
			conn.messages~= message;
	}
	// socket.send(message);
	// synchronized websocketMessages~= message;
}

struct Connection
{
	size_t id;
	string[] messages;
}
private __gshared size_t id;
private __gshared Connection*[] connections;

void serveGameFiles(Cgi cgi) 
{
    import std.path;
    string targetPath = buildNormalizedPath(startPath, DEFAULT_PATH);
	string contentType = extendedContentTypeFromFileExtension(cgi.pathInfo);
	string file = buildNormalizedPath(targetPath, cgi.pathInfo[1..$]);

	if(cgi.websocketRequested())
	{
		auto socket = cgi.acceptWebsocket();
		Connection conn = Connection(id);
		synchronized
		{
			connections~= &conn;
			id++;
		}
		enum __updateMsg = 0xff;
		auto msg = socket.recv();
		while(msg.opcode != WebSocketOpcode.close) 
		{
			synchronized
			{
				foreach(socketMsg; conn.messages)
					socket.send(socketMsg);
				conn.messages.length = 0;
			}
			msg = socket.recv();
		}

		synchronized
		{
			socket.close();
			import std.algorithm;
			ptrdiff_t index = countUntil!((Connection* c) => c.id == conn.id)(connections);
			if(index != -1)
			{
				connections = connections[0..index]~ connections[index+1..$];
			}
		}
		writeln("AutoReloading WebSocket[", conn.id, "] closed.");
	}
	else if(cgi.pathInfo == "/") 
	{
		string indexHTML = buildNormalizedPath(targetPath, "index.html");
		if(exists(indexHTML))
		{
			cgi.write(readText(indexHTML)~"<script> "~import("reload_server.js")~"</script>", true);
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
				cgi.write(html, true);

		}
	}
	else if(contentType)
	{
		if(!exists(file))
		{
			cgi.setResponseStatus("404 file not found");
		}
		else
		{
			cgi.setResponseContentType(contentType);
			cgi.setResponseStatus(200);
			if(contentType[0.."text".length] == "text")
				cgi.write(readText(file));
			else
				cgi.write(read(file));
			writeln("GET ", file, " 200");
		}
	}

}

private RequestServer server;
/++
	This is the function [GenericMain] calls. View its source for some simple boilerplate you can copy/paste and modify, or you can call it yourself from your `main`.
	Params:
		fun = Your request handler
		CustomCgi = a subclass of Cgi, if you wise to customize it further
		maxContentLength = max POST size you want to allow
		args = command-line arguments
	History:
	Documented Sept 26, 2020.
+/



void hipengineCgiMain(alias fun, CustomCgi = Cgi, long maxContentLength = defaultMaxContentLength)
(string[] args, string servePath)  if(is(CustomCgi : Cgi)) 
{
    startPath = servePath;
	if(tryAddonServers(args))
		return;
	if(trySimulatedRequest!(fun, CustomCgi)(args))
		return;

	// you can change the port here if you like
	server.listeningPort = 9000;

	string host = server.listeningHost;
	if(host == "") host = "localhost";
	writeln("HipremeEngine Dev Server listening from ", host,":",server.listeningPort);

	// then call this to let the command line args override your default
	server.configureFromCommandLine(args);


	// and serve the request(s).
	server.serve!(fun, CustomCgi, maxContentLength)();

}

void stopServer()
{
    import core.stdc.stdlib;
	pushWebsocketMessage("close");
    exit(0);
}