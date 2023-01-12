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
    bool read(string path, out void[] output){return false;}
    bool write(string path, void[] data){return false;}
    bool exists(string path){return false;}
    bool remove(string path){return false;}

    bool isDir(string path){return false;}

    ~this()
    {
        dirsJson.dispose();       
    }

}