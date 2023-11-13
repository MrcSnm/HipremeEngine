module hip.filesystem.hipfs;
public import hip.api.filesystem.hipfs;

extern class HipFileSystem
{
    static
    {
        string getPath (string path);
        bool isPathValid (string path, bool expectsFile = true, bool shouldVerify = true);
        bool isPathValidExtra (string path);
        bool setPath (string path);
        void initializeAbsolute();
        void install(string path);
        void install(string path, bool function(string path, out string errMessage)[] validations ...);
        IHipFSPromise read(string path);
        IHipFSPromise read (string path, out ubyte[] output);
        IHipFSPromise readText(string path);
        IHipFSPromise readText (string path, out string output);
        bool write (string path, void[] data);
        bool exists (string path);
        bool remove (string path);
        string getcwd ();
        bool absoluteExists (string path);
        bool absoluteIsDir (string path);
        bool absoluteIsFile (string path);
        bool isDir (string path);
        bool isFile (string path);
        string writeCache (string cacheName, void[] data);
    }
}

alias HipFS = HipFileSystem;