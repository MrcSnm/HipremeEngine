module hip.api.filesystem.fs_binding;
public import hip.api.filesystem.hipfs;

version(DirectCall){ public import hip.filesystem.hipfs; }
else version(ScriptAPI)
{
    void initFS()
    {
        import hip.api.internal;
        loadClassFunctionPointers!(HipFSBinding, UseExportedClass.Yes, "HipFileSystem");

        import hip.api.console;
        log("HipengineAPI: Initialized FS");
    }
    import hip.api.internal;
    class HipFSBinding
    {
        @disable this();
        extern(System) __gshared
        {
            string function (string path) getPath;
            bool function (string path, bool expectsFile = true, bool shouldVerify = true) isPathValid;
            bool function (string path) isPathValidExtra;
            bool function (string path) setPath;
            IHipFSPromise function (string path, out ubyte[] output) read;
            IHipFSPromise function (string path, out string output) readText;
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
    mixin ExpandClassFunctionPointers!(HipFSBinding);
}



