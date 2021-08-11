module data.hipfs;
import std.stdio : File;
import std.string:lastIndexOf;
import std.array:split;
import util.system;
static import std.file;


private bool validatePath(string initial, string toAppend)
{
    if(initial[$-1] == '/')
        initial = initial[0..$-1];
    string newPath = initial.sanitizePath;
    toAppend = toAppend.sanitizePath;

    string[] appends = toAppend.split("/");

    foreach(a; appends)
    {
        if(a == "" || a == ".")
            continue;
        if(a == "..")
        {
            long lastInd = newPath.lastIndexOf('/');
            if(lastInd == -1)
                continue;
            newPath = newPath[0..lastInd];
        }
        else
            newPath~= "/"~a;
    }
    for(int i = 0; i < initial.length; i++)
        if(initial[i] != newPath[i])
            return false;
    return true;
}

/**
* FileSystem access for specific platforms.
*/
class HipFileSystem
{
    protected static string defPath;
    protected static string initialPath = "";

    public static void init(string path)
    {
        if(initialPath == "" && path != "")
            initialPath = path.sanitizePath;
    }
    public static string getPath(string path){return initialPath~defPath~path.sanitizePath;}
    public static bool isPathValid(string path){return validatePath(initialPath, defPath~path);}

    public static bool setPath(string path)
    {
        path = path.sanitizePath;
        defPath = path;
        return validatePath(initialPath, path);
    }

    public static void[] read(string path)
    {
        path = initialPath~defPath~path.sanitizePath;
        return std.file.read(path);
    }

    public static bool getFile(string path, string opts, out File file)
    {
        if(!isPathValid(path))
            return false;
        file = File(getPath(path), opts);
        return true;
    }

    public static bool write(string path, void[] data)
    {
        if(!isPathValid(path))
            return false;
        std.file.write(getPath(path), data);
        return true;
    }
}

alias HipFS = HipFileSystem;