module hip.filesystem.systems.cstd;
import hip.api.filesystem.hipfs;


/**
*   All those string allocations should be removed or turnt into @nogc somehow. The better cached, the best.
*
*/
class HipCStdioFileSystemInteraction : IHipFileSystemInteraction
{
    version(Windows)
        pragma(lib, "Shlwapi.lib"); //PathIsDirectory
    bool read(string path, void delegate(void[] data) onSuccess, void delegate(string err) onError)
    {
        import core.stdc.stdio;
        import hip.error.handler;
        if(ErrorHandler.assertLazyErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
            return false;

        auto f = fopen((path~"\0").ptr, "r");
        fseek(f, 0, SEEK_END);
        auto size = ftell(f);

        if(size <= 0)
        {
            fclose(f);
            onError("Size <= 0");
            return false;
        }
        fseek(f, 0, SEEK_SET);
        void[] output;
        output.length = cast(size_t)size;

        if(fread(output.ptr, cast(size_t)size, 1, f) != size)
        {
            fclose(f);
            onError("File is corrupted. Coult not read file entirely");
            return false;
        }
        fclose(f);
        onSuccess(output);
        return true;
    }
    bool write(string path, void[] data)
    {
        import core.stdc.stdio;
        if(exists(path))
        {
            auto file = fopen(cachedStringz(path), "w");
            scope(exit)
                fclose(file);
            if(fwrite(data.ptr, 1, data.length, file) != data.length)
            {
                return fflush(file) == 0;
            }
            return true;
        }
        return false;
    }
    bool exists(string path)
    {
        import core.stdc.stdio;
        if(auto file = fopen(cachedStringz(path), "r"))
        {
            fclose(file);
            return true;
        }
        return false;
    }
    bool remove(string path)
    {
        static import core.stdc.stdio;
        if(exists(path))
        {
            return core.stdc.stdio.remove(cachedStringz(path)) == 0;
        }

        return false;
    }
    version(Posix)
        import core.sys.posix.sys.stat;
    else version(Windows)
        import core.sys.windows.shlwapi : PathIsDirectoryA;
    bool isDir(string path)
    {
        version(Windows)
        {
            return PathIsDirectoryA(cachedStringz(path)) == 1;
        }
        else version(Posix)
        {
            stat_t st;
            stat(cachedStringz(path), &st);
            return S_ISDIR(st.st_mode);
        }
        else return path[$-1] == '/';
    }
    
}