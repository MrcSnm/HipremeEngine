module hip.filesystem.systems.dstd;
import hip.api.filesystem.hipfs;

version(HipDStdFile) class HipStdFileSystemInteraction : IHipFileSystemInteraction
{
    import std.stdio : File;
    bool read(string path, out void[] output)
    {
        import hip.error.handler;
        if(ErrorHandler.assertErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
            return false;

        auto f = File(path);
        output.length = f.size;
        f.rawRead(output);
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
