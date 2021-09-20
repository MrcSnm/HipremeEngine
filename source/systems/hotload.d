module systems.hotload;
import std.path;
import std.file;
import util.system;

class HotloadableDLL
{
    void* lib;

    immutable string trueLibPath;
    void delegate (void* libPointer) onDllLoad;
    string tempPath;
    this(string path, void delegate (void* libPointer) onDllLoad)
    {
        assert(path, "DLL path should not be null");
        if(!dynamicLibraryIsLibNameValid(path))
            path = dynamicLibraryGetLibName(path);
        trueLibPath = path;
        this.onDllLoad = onDllLoad;
        load(path);
    }
    protected bool load(string path)
    {
        if(!exists(path))
            return false;
        tempPath = getTempName(path);
        copy(path, tempPath);
        lib = dynamicLibraryLoad(tempPath);
        if(onDllLoad && lib != null)
            onDllLoad(lib);
        return lib != null;
    }

    string getTempName(string path)
    {
        string d = dirName(path);
        string n = baseName(path);
        string ext = extension(path);
        return buildNormalizedPath(d, n~"_hiptemp"~ext);
    }
    void reload()
    {
        if(lib != null)
            dynamicLibraryRelease(lib);
        load(trueLibPath);
        if(onDllLoad)
            onDllLoad(lib);
    }

    void dispose()
    {
        if(lib != null)
            dynamicLibraryRelease(lib);
        if(tempPath)
            remove(tempPath);
    }
}