module hip.api.filesystem.fs_binding;
public import hip.api.filesystem.hipfs;
void initFS()
{
    import hip.api.internal;
    alias fs = extern(C) IHipFS function();
    setIHipFS((cast(fs)_loadSymbol(_dll, "HipFileSystemAPI"))());
    import hip.api.console;
    log("HipengineAPI: Initialized FS");
}