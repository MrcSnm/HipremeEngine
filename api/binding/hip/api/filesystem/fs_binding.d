module hip.api.filesystem.fs_binding;
version(DirectCall){ public import hip.filesystem.hipfs; }
else version(ScriptAPI)
{
    public import hip.api.filesystem.hipfs;
    void initFS()
    {
        import hip.api.internal;
        alias fs = extern(C) IHipFS function();
        setIHipFS((cast(fs)_loadSymbol("HipFileSystemAPI"))());
        import hip.api.console;
        log("HipengineAPI: Initialized FS");
    }
}