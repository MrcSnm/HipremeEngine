module hip.filesystem.systems.browser;

version(WebAssembly):

/**
*   directories.json is an auto generated file which saves a list of all directories for your game assets.
*   With that, it is possible to reproduce some commands such as exists or isDir.
*   It is also possible to get the file size upfront.
*/
immutable string directories = import("directories.json");

import hip.api.filesystem.hipfs;
import hip.filesystem.hipfs;

version(WebAssembly):
import hip.wasm;


private extern(C) void WasmRead(JSStringType str,
    JSDelegateType!(void delegate(void[])) onSuccess, 
    JSDelegateType!(void delegate(string)) onError
);

class HipBrowserFileSystemInteraction : IHipFileSystemInteraction
{
    import hip.data.json;
    JSONValue dirsJson;
    this()
    {
        dirsJson = parseJSON(directories);
        if(dirsJson.hasErrorOccurred)
        {
            import hip.error.handler;
            ErrorHandler.assertExit(false, "Could not parse directories.json, required for BrowserFS. Got `"~directories~"`\n\t Error: "~dirsJson.error);
        }
    }
    
    bool read(string path, void delegate(void[] data) onSuccess, void delegate(string err = "Corrupted File") onError)
    {
        JSONValue dummy = void;
        import hip.console.log;
        if(!getFromPath(path, dummy))
        {
            hiplog("Browser could not read ", path);
            return false;
        }
        hiplog("Browser read start on ", path);

        WasmRead(JSString(path).tupleof, sendJSDelegate!((ubyte[] wasmBin)
        {
            onSuccess(cast(void[])wasmBin);
        }).tupleof, sendJSDelegate!(onError).tupleof);
        
        return true;
    }
    bool write(string path, void[] data){return false;}

    private bool getFromPath(string path, out JSONValue output)
    {
        import hip.util.path:pathSplitterRange, normalizePath;
        output = dirsJson;
        import hip.console.log;
        hiplog("Testing ", path.normalizePath);
        foreach(p; pathSplitterRange(path.normalizePath))
        {
            JSONValue* currAddr = p in output;
            if(currAddr is null)
                return false;
            output = *currAddr;
        }
        return true;
    }
    bool exists(string path)
    {
        JSONValue dummy = void;
        return getFromPath(path, dummy);
    }
    bool remove(string path){return false;}

    bool isDir(string path)
    {
        JSONValue temp = void;
        if(!getFromPath(path, temp))
            return false;
        return temp.type == JSONType.object;
    }

    ~this()
    {
        dirsJson.dispose();       
    }

}