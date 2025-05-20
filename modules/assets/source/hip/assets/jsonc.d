module hip.assets.jsonc;
public import hip.data.jsonc;
public import hip.api.data.jsonc;
import hip.api.data.asset;


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

        HipFS.readText(filePath).addOnError((err)
        {
            ErrorHandler.showWarningMessage("Could not load JSONC file", filePath);

        }).addOnSuccess((in ubyte[] data)
        {
            loadFromMemory(cast(string)data, filePath);
            return FileReadResult.free;
        });
        return true;
    }
    override void onFinishLoading(){}
    override void onDispose(){}
    override bool isReady() const {return data.length > 0;}
    string getData(){return data;}
}