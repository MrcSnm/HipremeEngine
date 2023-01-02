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
        string data;
        if(!HipFS.readText(path, data))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not load INI file ", path);
            return false;
        }
        return loadFromMemory(data, path);
    }

    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return f !is null;}
    mixin(ForwardInterface!("f", IHipIniFile));
}