/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module data.hipfs;
import error.handler;
import util.file:joinPath;
import std.stdio : File;
import std.string:lastIndexOf;
import std.array:split;
import util.system;
static import std.file;

public import std.file : getcwd;

private pure bool validatePath(string initial, string toAppend)
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
    protected static string combinedPath;

    protected static bool function(string path, out string errMessage)[] extraValidations;
 
    public static void install(string path, bool function(string path, out string errMessage)[] validations ...)
    {
        if(initialPath == "" && path != "")
            initialPath = path.sanitizePath;
        setPath("");
        foreach (v; validations){extraValidations~=v;}
    }
    public static string getPath(string path){return joinPath(combinedPath, path.sanitizePath);}
    public static bool isPathValid(string path){return validatePath(initialPath, defPath~path);}
    public static bool isPathValidExtra(string path)
    {
        path = path.sanitizePath;
        string err;
        foreach (bool function(string, out string) validation; extraValidations)
        {
            if(!validation(path, err))
            {
                ErrorHandler.showErrorMessage("HipFileSystem validation error",
                "Path '"~path~"' failed at validation with error: '"~err~"'.");
                return false;
            }
        }
        return true;
    }

    public static bool setPath(string path)
    {
        defPath = path.sanitizePath;
        combinedPath = joinPath(initialPath, defPath);
        return validatePath(initialPath, combinedPath);
    }

    public static bool read(string path, out void[] output)
    {
        if(!isPathValid(path) || !isPathValidExtra(path))
            return false;
        path = getPath(path);
        output = std.file.read(path);
        return true;
    }
    public static bool read(string path, out ubyte[] output)
    {
        void[] data;
        bool ret = read(path, data);
        output = cast(ubyte[])data;
        return ret;
    }
    public static bool readText(string path, out string output)
    {
        void[] data;
        bool ret = read(path, data);
        import std.conv:to;
        if(ret)
            output = to!string(data);
        return ret;
    }

    public static bool getFile(string path, string opts, out File file)
    {
        if(!isPathValid(path) || !isPathValidExtra(path))
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
    public static bool exists(string path){return isPathValid(path) && std.file.exists(getPath(path));}
    public static bool remove(string path)
    {
        if(!isPathValid(path) || !isPathValidExtra(path))
            return false;
        std.file.remove(getPath(path));
        return true;
    } 



    public static string writeCache(string cacheName, void[] data)
    {
        string p = joinPath(initialPath, ".cache", cacheName);
        write(p, data);
        return p;
    }
}

alias HipFS = HipFileSystem;