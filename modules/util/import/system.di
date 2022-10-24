// D import file generated from 'source\hip\util\system.d'
module hip.util.system;
import hip.util.conv;
import core.stdc.string;
import hip.util.string : fromStringz;
import hip.util.path : pathSeparator;
enum debugger = "asm {int 3;}";
pure nothrow @safe string sanitizePath(string path);
pure nothrow @safe bool isPathUnixStyle(string path);
pure nothrow @safe string buildPath(string[] args...);
version (Windows)
{
	import hip.util.windows;
	private HMODULE moduleHandle;
	extern (Windows) nothrow @system void* dll_import_var(string name);
	void dll_import_varS(alias varSymbol, string s = "")()
	{
		static if (s == "")
		{
			varSymbol = cast(typeof(varSymbol))dll_import_var(varSymbol.stringof);
		}
		else
		{
			varSymbol = cast(typeof(varSymbol))dll_import_var(s);
		}
	}
	string getWindowsErrorMessage(HRESULT hr);
}
string dynamicLibraryGetLibName(string libName);
bool dynamicLibraryIsLibNameValid(string libName);
void* dynamicLibraryLoad(string libName);
version (Windows)
{
	private const(char)* err;
}
void* dynamicLibrarySymbolLink(void* dll, const(char)* symbolName);
string dynamicLibraryError();
bool dynamicLibraryRelease(void* dll);
