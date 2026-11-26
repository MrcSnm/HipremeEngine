module hip.filesystem.systems.dstd;
import hip.api.filesystem.hipfs;

version(HipDStdFile) class HipStdFileSystemInteraction : IHipFileSystemInteraction
{
    bool read(string path, FileReadResult delegate(ubyte[] data) onSuccess, void delegate(string err) onError)
    {
        import std.stdio : File;
        import hip.error.handler;
        if(ErrorHandler.assertLazyErrorMessage(exists(path), "FileSystem Error:", "File named '"~path~"' does not exist"))
            return false;

        ubyte[] output;
        try
        {
            auto f = File(path);
            import hip.util.array;
            output = uninitializedArray!(ubyte[])(f.size);
            f.rawRead(output);
            f.close();
        }
        catch (Exception e)
        {
            ErrorHandler.showErrorMessage("FileSystem Error", "Could not read '"~path~"': "~e.msg);
            return false;
        }
        onSuccess(output);
        return true;
    }
    bool write(string path, const void[] data)
    {
        static import std.file;
        import hip.error.handler;
        try
        {
            std.file.write(path, data);
            return true;
        }
        catch (Exception e)
        {
            ErrorHandler.showErrorMessage("FileSystem Error", "Could not write '"~path~"': "~e.msg);
            return false;
        }
    }
    bool exists(string path)
    {
        static import std.file;
        return std.file.exists(path);
    }
    bool remove(string path)
    {
        static import std.file;
        import hip.error.handler;
        if(!std.file.exists(path))
            return false;
        try
        {
            std.file.remove(path);
            return true;
        }
        catch (Exception e)
        {
            ErrorHandler.showErrorMessage("FileSystem Error", "Could not remove '"~path~"': "~e.msg);
            return false;
        }
    }
    
    bool isDir(string path)
    {
        static import std.file;
        import hip.error.handler;
        try
        {
            return std.file.exists(path) && std.file.isDir(path);
        }
        catch (Exception e)
        {
            ErrorHandler.showErrorMessage("FileSystem Error", "Could not stat '"~path~"': "~e.msg);
            return false;
        }
    }
    
}
