
module bind.external;
version (UWP)
{
	import core.sys.windows.windows;
	extern (Windows) nothrow @system 
	{
		HWND function() getCoreWindowHWND;
		void function(wchar* wcstr) OutputUWP;
	}
	void uwpPrint(string str);
}
extern (Windows) alias myFunPtr = nothrow @system int function();
void importExternal();
