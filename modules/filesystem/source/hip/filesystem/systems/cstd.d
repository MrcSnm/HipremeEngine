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
    bool read(string path, void delegate(ubyte[] data) onSuccess, void delegate(string err) onError)
    {
        import core.stdc.stdio;
        import hip.error.handler;
        import hip.util.conv;
        if(ErrorHandler.assertLazyErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
            return false;

        auto f = fopen((path~"\0").ptr, "rb");
        if(f is null)
        {
            onError("File not found.");
            return false;
        }
        if(fseek(f, 0, SEEK_END))
        {
            fclose(f);
            onError("Could not seek to file end.");
            return false;
        }
        auto size = ftell(f);

        if(size <= 0)
        {
            fclose(f);
            onError("Size <= 0 on file "~path);
            return false;
        }
        if(fseek(f, 0, SEEK_SET))
        {
            fclose(f);
            onError("Could not seek to file beginning");
            return false;
        }
        ubyte[] output = new ubyte[size];

        if(size_t readed = fread(cast(void*)output.ptr, 1, cast(size_t)size, f) != size)
        {
            fclose(f);
            onError("File is corrupted. Could not read file entirely (Readed "~to!string(readed)~") Expected "~to!string(size));
            return false;
        }
        fclose(f);
        onSuccess(output);
        return true;
    }
    bool write(string path, const(void)[] data)
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

    version(Windows)
    {
        private alias BOOL = int;
        private alias LPCSTR = const(char)*;
        extern(Windows) BOOL PathIsDirectoryA(LPCSTR);
    }

    bool isDir(string path)
    {
        version(Windows)
        {
            return PathIsDirectoryA(cachedStringz(path)) == 1;
        }
        else version(Posix)
        {
            import core.sys.posix.sys.stat;
            stat_t st;
            stat(cachedStringz(path), &st);
            return S_ISDIR(st.st_mode);
        }
        else return path[$-1] == '/';
    }
    
}