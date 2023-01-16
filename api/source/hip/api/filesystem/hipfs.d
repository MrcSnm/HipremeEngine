module hip.api.filesystem.hipfs;

///Less dependencies
enum
{
    /// Offset is relative to the beginning
    SEEK_SET,
    /// Offset is relative to the current position
    SEEK_CUR,
    /// Offset is relative to the end
    SEEK_END
}

enum FileMode
{
    READ,
    WRITE,
    APPEND,
    READ_WRITE,
    READ_APPEND
}

///Unused yet, but planned
interface IHipDirectoryItf
{
    bool open();
    bool close();
    string[] getFileNames();
    size_t count();
    int opApply(scope int delegate(in string fileName) dg);
}

interface IHipFileItf
{
    bool open(string path, FileMode mode);
    int read(void* buffer, ulong count);
    ///Whence is the same from stdio
    int seek(long count, int whence);
    ulong getSize();
    void close();
}
interface IHipFSPromise
{
  IHipFSPromise addOnSuccess(void delegate(in void[] data) onSuccess);
  IHipFSPromise addOnError(void delegate(string error) onError);
  bool resolved() const;
  final bool opCast() const {return resolved;}
}

interface IHipFileSystemInteraction
{
    protected final const(wchar*) cachedWStringz(wstring path)
    {
        static wchar[] cache;
        if(path.length > cache.length)
            cache.length = path.length + 1;
        cache[0..path.length] = path[];
        cache[path.length] = '\0';

        return cache.ptr;
    }

    protected final const(char*) cachedStringz(string path)
    {
        static char[] cache;
        if(path.length > cache.length)
            cache.length = path.length + 1;
        cache[0..path.length] = path[];
        cache[path.length] = '\0';

        return cache.ptr;
    }

    /**
    *   onSuccess: Maybe be executed before the function returns (on sync platforms).
    *
    *   onError: Error is reserved for when the file exists but can't be read.
    Not being able to read because it doesn't exists is not an error. 
    *   
    *
    *   Returns:
    *       - Sync Platforms: File does not exists, can't read.
    *       - Async platforms: File does not exists
    */
    bool read(string path, void delegate(void[] data) onSuccess, void delegate(string err = "Corrupted File") onError);
    bool write(string path, void[] data);
    bool exists(string path);
    bool remove(string path);

    bool isDir(string path);
    final bool isFile(string path){return !isDir(path);}
}
