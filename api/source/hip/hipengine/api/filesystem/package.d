module hip.hipengine.api.filesystem;
public import hip.hipengine.api.filesystem.hipfs;

void initFS()
{
    version(Script)
    {
        import hip.hipengine.internal;
        enum InputMapClass = "HipFileSystem";
        mixin(loadSymbolsFromExportD!(InputMapClass,
            getPath,
            isPathValid,
            isPathValidExtra,
            setPath,
            read,
            readText,
            write,
            exists,
            remove,
            getcwd,
            absoluteExists,
            absoluteIsDir,
            absoluteIsFile,
            isDir,
            isFile,
            writeCache
        ));

    }
}

version(Have_hipreme_engine)
{
    public import hip.filesystem.hipfs;
}
else
{
    extern(System)
    {
        string function (string path) getPath;
        bool function (string path) isPathValid;
        bool function (string path) isPathValidExtra;
        bool function (string path) setPath;
        // bool read(string path, out void[] output)
        // {
            // return ret(path, cast(ubyte[])output);
        // }
        bool function (string path, out ubyte[] output) read;
        bool function (string path, out string output) readText;
        bool function (string path, void[] data) write;
        bool function (string path) exists;
        bool function (string path) remove;
        string function () getcwd;
        bool function (string path) absoluteExists;
        bool function (string path) absoluteIsDir;
        bool function (string path) absoluteIsFile;
        bool function (string path) isDir;
        bool function (string path) isFile;
        string function (string cacheName, void[] data) writeCache;
    }
}
