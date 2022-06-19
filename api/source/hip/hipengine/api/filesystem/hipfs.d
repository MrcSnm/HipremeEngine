module hip.hipengine.api.filesystem.hipfs;

version(HipFileAPI):

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

interface IHipFileItf
{
    bool open(string path, FileMode mode);
    int read(void* buffer, ulong count);
    ///Whence is the same from stdio
    int seek(long count, int whence);
    ulong getSize();
    void close();
}
interface IHipFileSystemInteraction
{
    bool read(string path, out void[] output);
    bool write(string path, void[] data);
    bool exists(string path);
    bool remove(string path);
}