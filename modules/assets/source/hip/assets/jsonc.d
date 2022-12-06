module hip.assets.jsonc;
import hip.asset;
public import hip.data.jsonc;
public import hip.api.data.jsonc;


class HipJSONC : HipAsset, IHipJSONC
{
    string data;
    string _path;
    this()
    {
        super("HipJSONC");
        _typeID = assetTypeID!HipJSONC;
    }
    string getPath() => _path;
    bool loadFromMemory(string jsonData, string path = "")
    {
        this.data = stripComments(jsonData);
        _path = path;
        return data.length > 0;
    }

    bool loadFromFile(string filePath)
    {
        import hip.filesystem.hipfs;
        import hip.error.handler;
        string tempData;
        if(!HipFS.readText(filePath, tempData))
        {
            ErrorHandler.showWarningMessage("Could not load JSONC file", filePath);
            return false;
        }
        return loadFromMemory(tempData, filePath);
    }
    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return data.length > 0;}
    string getData(){return data;}
}