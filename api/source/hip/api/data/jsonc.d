module hip.api.data.jsonc;
/**
*   Usage:
```d
//Must import hip.data.json for actually using it.
import hip.data.json;
JSONValue json = hipJSON.getJSON!JSONValue;
json["myProperty"].str//or other types
```
*/
interface IHipJSONC
{
    string getData();
    string getPath();
    /**
    *   This function is templated for not generating dependency on std.json.
    *   It is not optimized to hold the JSON. Call it only once or it will parse again.
    */
    auto getJSON()()
    {
        import hip.data.json;
        return parseJSON(getData());
    }
}