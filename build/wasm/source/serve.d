import arsd.cgi;
import std.stdio;
import std.file;
import std.string;
import std.process;

// -Wl,--export=__heap_base

// https://github.com/skoppe/wasm-sourcemaps

enum DEFAULT_PATH="build/";

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

void handler(Cgi cgi) 
{
	string contentType = extendedContentTypeFromFileExtension(cgi.pathInfo);
	string file = DEFAULT_PATH~cgi.pathInfo[1..$];
	
	if(cgi.pathInfo == "/") 
	{
		string indexHTML = DEFAULT_PATH~"/index.html";
		if(exists(indexHTML))
		{
			cgi.write(readText(indexHTML), true);
		}
		else
		{
			// index
			string html = "<html><head><title>Hipreme Engine Webassembly Server</title></head><body><ul>";
			foreach(string name; dirEntries(DEFAULT_PATH, SpanMode.shallow)) 
			{
				name = name[DEFAULT_PATH.length..$];
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
void hipengineCgiMain(alias fun, CustomCgi = Cgi, long maxContentLength = defaultMaxContentLength)(string[] args) if(is(CustomCgi : Cgi)) 
{
	if(tryAddonServers(args))
		return;

	if(trySimulatedRequest!(fun, CustomCgi)(args))
		return;

	RequestServer server;
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

void main(string[] args)
{
	hipengineCgiMain!(handler)(args);
}