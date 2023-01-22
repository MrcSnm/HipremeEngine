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

mixin GenericMain!handler;
