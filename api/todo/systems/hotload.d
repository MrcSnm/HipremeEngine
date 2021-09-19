
module systems.hotload;
import std.path;
import std.file;
import util.system;
class HotloadableDLL
{
	void* lib;
	immutable string trueLibPath;
	void delegate(void* libPointer) onDllLoad;
	string tempPath;
	this(string path, void delegate(void* libPointer) onDllLoad)
	{
		assert(path, "DLL path should not be null");
		if (!dynamicLibraryIsLibNameValid(path))
			path = dynamicLibraryGetLibName(path);
		trueLibPath = path;
		this.onDllLoad = onDllLoad;
		load(path);
	}
	protected bool load(string path);
	string getTempName(string path);
	void reload();
	void dispose();
}
