module hip.assets.ini;
import hip.asset;
public import hip.data.ini;
import hip.util.reflection;

class HipINI : HipAsset, IHipIniFile
{
    IniFile f;
    this()
    {
        super("HipINI");
        _typeID = assetTypeID!HipINI;
    }

    bool loadFromMemory(string data, string path)
    {
        f = IniFile.parse(data, path);
        return f !is null;
    }

    bool loadFromFile(string path)
    {
        import hip.filesystem.hipfs;
        HipFS.readText(path).addOnError((err)
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not load INI file ", path);
        }).addOnSuccess((in ubyte[] data)
        {
            loadFromMemory(cast(string)data, path);
            return FileReadResult.keep;
        });
        return true;
    }

    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return f !is null;}
    mixin(ForwardInterface!("f", IHipIniFile));
}