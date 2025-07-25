module hip.assets.csv;
public import hip.api.data.csv;
public import hip.data.csv;
import hip.api.data.asset;

class HipCSV : HipAsset, IHipCSV
{
    CSV csv;
    this()
    {
        super("HipCSV");
        _typeID = assetTypeID!(HipCSV);
    }

    bool loadFromMemory(string data, const char fieldDelimiter = ',', const char textDelimiter = '"', string path = "")
    {
        this.csv = parseCSV(data, fieldDelimiter, textDelimiter, path);
        return csv.data.length > 0;
    }
    bool loadFromFile(string file, const char fieldDelimiter = ',', const char textDelimiter = '"')
    {
        import hip.error.handler;
        import hip.api.filesystem.hipfs;
        HipFS.readText(file).addOnError((string err)
        {
            ErrorHandler.showErrorMessage("Could not load CSV File", file);
        }).addOnSuccess((in ubyte[] data)
        {
            loadFromMemory(cast(string)data, fieldDelimiter, textDelimiter, file);
            return FileReadResult.free;
        });

        return true;
    }

    string opIndex(size_t x, size_t y) const{return csv.data[y][x];}
    
    override void onFinishLoading(){}
    override void onDispose(){}
    override bool isReady() const {return csv.data.length > 0;}
    size_t rows() const {return csv.data.length;}
    size_t columns() const {return csv.data[0].length;}
    string path() const {return csv.path;}
    const(string[]) getRow(size_t row) const @nogc{return csv.data[row];}
    
}