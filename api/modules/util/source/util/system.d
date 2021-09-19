
module util.system;
import std.conv : to;
import std.system : os;
import core.stdc.string;
import std.array : replace;
pure nothrow string sanitizePath(string path);
pure nothrow bool isPathUnixStyle(string path);
version (Windows)
{
	import core.sys.windows.dll;
	import core.sys.windows.windows;
	private HMODULE moduleHandle;
	extern (Windows) nothrow @system void* dll_import_var(string name);
	void dll_import_varS(alias varSymbol)()
	{
		varSymbol = cast(typeof(varSymbol))dll_import_var(varSymbol.stringof);
	}
}
string dynamicLibraryGetLibName(string libName);
bool dynamicLibraryIsLibNameValid(string libName);
void* dynamicLibraryLoad(string libName);
void* dynamicLibrarySymbolLink(void* dll, const(char)* symbolName);
version (Windows)
{
	private const(char)* err;
}
string dynamicLibraryError();
bool dynamicLibraryRelease(void* dll);
