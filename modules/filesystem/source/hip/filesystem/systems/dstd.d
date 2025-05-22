module hip.filesystem.systems.dstd;
import hip.api.filesystem.hipfs;

version(HipDStdFile) class HipStdFileSystemInteraction : IHipFileSystemInteraction
{
    bool read(string path, FileReadResult delegate(ubyte[] data) onSuccess, void delegate(string err) onError)
    {
        import std.stdio : File;
        import hip.error.handler;
        if(ErrorHandler.assertLazyErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
            return false;
        auto f = File(path);
        import hip.util.array;
        ubyte[] output = uninitializedArray!(ubyte[])(f.size);
        f.rawRead(output); //TODO: onError should be on try/catch
        f.close();
        onSuccess(output);
        return true;
    }
    bool write(string path, const void[] data)
    {
        static import std.file; 
        std.file.write(path, data);return true;
    }
    bool exists(string path)
    {
        static import std.file;
        return std.file.exists(path);
    }
    bool remove(string path)
    {
        static import std.file;
        std.file.remove(path);return true;
    }
    
    bool isDir(string path)
    {
        static import std.file;
        return std.file.isDir(path);
    }
    
}
