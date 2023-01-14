module hip.filesystem.systems.dstd;
import hip.api.filesystem.hipfs;

version(HipDStdFile) class HipStdFileSystemInteraction : IHipFileSystemInteraction
{
    import std.stdio : File;
    bool read(string path, void delegate(void[] data) onSuccess, void delegate(string err) onError)
    {
        import hip.error.handler;
        if(ErrorHandler.assertLazyErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
            return false;
        void[] output;
        auto f = File(path);
        output.length = f.size;
        f.rawRead(output); //TODO: onError should be on try/catch
        f.close();
        onSuccess(output);
        return true;
    }
    bool write(string path, void[] data)
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
