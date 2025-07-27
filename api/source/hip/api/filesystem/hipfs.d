module hip.api.filesystem.hipfs;

///Less dependencies
enum : ubyte
{
    /// Offset is relative to the beginning
    SEEK_SET,
    /// Offset is relative to the current position
    SEEK_CUR,
    /// Offset is relative to the end
    SEEK_END
}

enum FileMode : ubyte
{
    READ,
    WRITE,
    APPEND,
    READ_WRITE,
    READ_APPEND
}

/**
 * Result used for memory management after delegate is executed.
 * The result is free if and only if every delegates returns that it should free the result.
 */
enum FileReadResult : bool
{
    ///Don't do anything.
    keep = false,
    ///Frees the file data
    free = true,
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
    /**
     *
     * Params:
     *   onSuccess = A delegate containing the file data as an input
     * Returns:The promise itself
     */
    IHipFSPromise addOnSuccess(FileReadResult delegate(in ubyte[] data) onSuccess);
    IHipFSPromise addOnError(void delegate(string error) onError);
    bool resolved() const;
    void dispose();
}

interface IHipFileSystemInteraction
{
    protected final const(wchar*) cachedWStringz(wstring path)
    {
        __gshared wchar[] cache;
        if(path.length > cache.length)
            cache.length = path.length + 1;
        cache[0..path.length] = path[];
        cache[path.length] = '\0';

        return cache.ptr;
    }

    protected final const(char*) cachedStringz(string path)
    {
        __gshared char[] cache;
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
    bool read(string path, FileReadResult delegate(ubyte[] data) onSuccess, void delegate(string err = "Corrupted File") onError);
    bool write(string path, const(void)[] data);
    bool exists(string path);
    bool remove(string path);

    bool isDir(string path);
    final bool isFile(string path){return !isDir(path);}
}

/** 
 * Provides the interface for the filesystem singleton
 */
interface IHipFS
{
    ///Gets a path from the installed path
    string getPath(string path);

    ///Uses the only extra verifications to check if the path is valid
    bool isPathValidExtra(string path);

    /** 
     * Does some default validations in the path then it executes the extra ones.
     * Params:
     *   path = The path to validate
     *   expectsFile = Checks whether that path is a file or a directory.
     *   shouldVerify = Flags for executing extra validations
     * Returns: Whether the path is valid
     */
    bool isPathValid(string path, bool expectsFile = true, bool shouldVerify = true);

    /** 
     * Sets the initial path. It can't be a path with higher access than install path.
     * You may reset it to the install path by using `setPath("")`
     * Params:
     *   path = The path to set as base
     * Returns: If it is a valid path
     */
    bool setPath(string path);

    /** 
     * Encapsulates both the sync and async in the same API for reading a file
     * Params:
     *   path = The path to read
     * Returns: A task/promise which will output the file data. It returns null if the path is invalid
     */
    IHipFSPromise read(string path);

    /** 
     * Same as .read
     * Params:
     *   path = The path to read
     * Returns: A task/promise which will output the text data
     */
    IHipFSPromise readText(string path);
    
    /** 
     * Currently there is no way to know if the writing has finished. Uses the sync API.
     * Params:
     *   path = The path to write
     *   data = The data to write
     * Returns: If it was possible to write. May return false if path is invalid.
     */
    bool write(string path, const(void)[] data);

    /** 
     * Currently it is a sync operation.
     * Params:
     *   path = Path to check
     * Returns: If it exists
     */
    bool exists(string path);

    /** 
     * Removes from the current path
     * Params:
     *   path = The path to remove
     * Returns: Whether the operation has succeeded
     */
    bool remove(string path);

    /** 
     * Returns: The current working directory, form the last setPath() call.
     */
    string getcwd();

    /** 
     * Same as exists. But doesn't use install path. Limited and sync.
     */
    bool absoluteExists(string path);
    /** 
     * Same as isDir. But doesn't use install path. Limited and sync.
     */
    bool absoluteIsDir(string path);
    /** 
     * Same as isFile. But doesn't use install path. Limited and sync.
     */
    bool absoluteIsFile(string path);
    /** 
     * Same as remove. But doesn't use install path. Limited and sync.
     */
    bool absoluteRemove(string path);
    /** 
     * Same as write. But doesn't use install path. Limited and sync.
     */
    bool absoluteWrite(string path, const(void)[] data);
    /** 
     * Same as read. But doesn't use install path. Limited and sync.
     */
    bool absoluteRead(string path, out void[] output);
    bool absoluteRead(string path, out ubyte[] output);
    /** 
     * Same as readText. But doesn't use install path. Limited and sync.
     */
    bool absoluteReadText(string path, out string output);
    /** 
     * Checks whether the path is a file
     */
    bool isFile(string path);
    /** 
     * Checks whether the path is a directory
     */
    bool isDir(string path);
    /** 
     * Uses a key/value pair for writing cache values. 
     */
    string writeCache(string cacheName, void[] data);
}

///Dependency injection interface for HipFS
private __gshared IHipFS _fs;
void setIHipFS(IHipFS fsInstance)
{
    _fs = fsInstance;
}
IHipFS HipFileSystem()
{
    return _fs;
}
alias HipFS = .HipFileSystem;