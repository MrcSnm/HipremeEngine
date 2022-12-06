module hip.api.data.jsonc;
/**
*   As the JSON is a lot more heavyweight than everything that can be found in API, it will be a bit worse to use.
*   One must call 
*/

interface IHipJSONC
{
    string getData();
    string getPath();
    /**
    *   This function is templated for not generating dependency on std.json.
    *   It is not optimized to hold the JSON. Call it only once or it will parse again.
    */
    T getJSON(T)()
    {
        import std.json;
        return parseJSON(getData);
    }
}