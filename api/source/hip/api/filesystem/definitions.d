module hip.api.filesystem.definitions;
public import hip.api.filesystem.hipfs;
//FIXME: Workaround for the issue https://issues.dlang.org/show_bug.cgi?id=23455

version(Script)
{
    public import hip.api.filesystem.fs_binding : initFS,
        getPath,
        isPathValid,
        isPathValidExtra,
        setPath,
        write,
        exists,
        remove,
        getcwd,
        absoluteExists,
        absoluteIsDir,
        absoluteIsFile,
        isDir,
        isFile,
        writeCache;
}
else
{
    public import hip.api.filesystem.fs_binding;
}

version(Script)
{
    import hip.api.internal;
    import hip.api.filesystem.fs_binding;
    mixin OverloadsForFunctionPointers!(hip.api.filesystem.fs_binding);

}