module hip.assets.csv;
import hip.asset;
public import hip.api.data.csv;
public import hip.data.csv;

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
        import hip.filesystem.hipfs;
        string data;
        if(!HipFS.readText(file, data))
        {
            ErrorHandler.showErrorMessage("Could not load CSV File", file);
            return false;
        }
        return loadFromMemory(data, fieldDelimiter, textDelimiter, file);
    }

    string opIndex(size_t x, size_t y) const{return csv.data[y][x];}
    
    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return csv.data.length > 0;}
    size_t rows() const {return csv.data.length;}
    size_t columns() const {return csv.data[0].length;}
    string path() const {return csv.path;}
    const(string[]) getRow(size_t row) const @nogc{return csv.data[row];}
    
}