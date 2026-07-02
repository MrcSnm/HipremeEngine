module hip.api.filesystem.fs_binding;
public import hip.api.filesystem.hipfs;
void initFS(string projectPath)
{
    import hip.api.internal;
    alias fs = extern(C) IHipFS function();
    import hip.util.path;
    projectPath = buildNormalizedPath(projectPath, "..", "..", ".."); //source/gamescript/entry.d
    setIHipFS((cast(fs)_loadSymbol(_dll, "HipFileSystemAPI"))(), projectPath);
    import hip.api.console;
    log("HipEngine API: Initialized FS for project: "~projectPath);
}