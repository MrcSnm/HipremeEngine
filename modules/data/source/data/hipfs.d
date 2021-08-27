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
import std.string:lastIndexOf, toStringz;
import std.array:split;
import util.system;
static import std.file;
///Less dependencies
enum
{
    /// Offset is relative to the beginning
    SEEK_SET,
    /// Offset is relative to the current position
    SEEK_CUR,
    /// Offset is relative to the end
    SEEK_END
}

private pure bool validatePath(string initial, string toAppend)
{
    if(initial.length != 0 && initial[$-1] == '/')
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

enum FileMode
{
    READ,
    WRITE,
    APPEND,
    READ_WRITE,
    READ_APPEND
}


interface IHipFileItf
{
    bool open(string path, FileMode mode);
    int read(void* buffer, ulong count);
    ///Whence is the same from stdio
    int seek(long count, int whence);
    ulong getSize();
    void close();
}
interface IHipFileSystemInteraction
{
    bool read(string path, out void[] output);
    bool write(string path, void[] data);
    bool exists(string path);
    bool remove(string path);
}

abstract class HipFile : IHipFileItf
{
    immutable FileMode mode;
    ulong size;
    ulong cursor;
    @disable this();
    this(string path, FileMode mode)
    {
        this.mode = mode;
        open(path, mode);
        this.size = getSize();
    }
    ///Whence is the same from libc
    long seek(long count, int whence = SEEK_CUR)
    {
        switch(whence)
        {
            default:
            case SEEK_CUR:
                cursor+= count;
                break;
            case SEEK_END:
                cursor = size + count;
                break;
            case SEEK_SET:
                cursor = count;
                break;
        }
        return cast(long)cursor;
    }

    T[] rawRead(T)(T[] buffer)
    {
        read(cast(void*)buffer.ptr,buffer.length);
        return buffer;
    }
}

version(Android)
{
    public import jni.android.asset_manager;
    public import jni.android.asset_manager_jni;
    AAssetManager* aaMgr;
    class HipAndroidFile : HipFile
    {
        import core.stdc.stdio;
        AAsset* asset;
        @disable this();
        this(string path, FileMode mode)
        {
            super(path, mode);
        }
        override ulong getSize()
        {
            return cast(ulong)AAsset_getLength64(asset);
        }
        override bool open(string path, FileMode mode)
        {
            asset = AAssetManager_open(aaMgr, path.toStringz, AASSET_MODE_BUFFER);
            return asset != null;
        }
        override int read(void* buffer, ulong count)
        {
            return AAsset_read(asset, buffer, count);
        }
        override long seek(long count, int whence = SEEK_CUR)
        {
            super.seek(count, whence);
            version(offset64)
                return AAsset_seek64(asset, count, SEEK_CUR);
            else
                return AAsset_seek(asset, cast(int)count, SEEK_CUR);
        }
        bool write(string path, void[] data)
        {
            std.file.write(path, data);
            return true;
        }
        void close()
        {
            AAsset_close(asset);
        }
    }

    class HipAndroidFileSystemInteraction : IHipFileSystemInteraction
    {
        bool read(string path, out void[] output)
        {
            HipAndroidFile f = new HipAndroidFile(path, FileMode.READ);
            output.length = f.size;
            bool ret = f.read(output.ptr, f.size) >= 0;
            f.close();
            destroy(f);
            return ret;
        }
        bool write(string path, void[] data)
        {
            HipAndroidFile f = new HipAndroidFile(path, FileMode.WRITE);
            bool ret = f.write(path, data);
            f.close();
            destroy(f);
            return ret;
        }
        bool exists(string path)
        {
            HipAndroidFile f = new HipAndroidFile(path, FileMode.WRITE);
            bool x = f.asset != null;
            f.close();
            destroy(f);
            return x;
        }
        bool remove(string path)
        {
            std.file.remove(path);
            return true;
        }
    }
}

class HipStdFileSystemInteraction : IHipFileSystemInteraction
{
    bool read(string path, out void[] output){output = std.file.read(path);return true;}
    bool write(string path, void[] data){std.file.write(path, data);return true;}
    bool exists(string path){return std.file.exists(path);}
    bool remove(string path){std.file.remove(path);return true;}
}

/**
* FileSystem access for specific platforms.
*/
class HipFileSystem
{
    protected static string defPath;
    protected static string initialPath = "";
    protected static string combinedPath;
    protected static bool hasSetInitial;
    protected static IHipFileSystemInteraction fs;

    protected static bool function(string path, out string errMessage)[] extraValidations;
 
    public static void install(string path,
    bool function(string path, out string errMessage)[] validations ...)
    {
        if(!hasSetInitial)
        {
            initialPath = path.sanitizePath;
            version(Android){fs = new HipAndroidFileSystemInteraction();}
            else{fs = new HipStdFileSystemInteraction();}
            setPath("");
            foreach (v; validations){extraValidations~=v;}
            hasSetInitial = true;
        }
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
        return fs.read(path, output);
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
        return fs.write(getPath(path), data);
    }
    public static bool exists(string path){return isPathValid(path) && fs.exists(getPath(path));}
    public static bool remove(string path)
    {
        if(!isPathValid(path) || !isPathValidExtra(path))
            return false;
        return fs.remove(getPath(path));
    }
    public static string getcwd()
    {
        return getPath("");
    }



    public static string writeCache(string cacheName, void[] data)
    {
        string p = joinPath(initialPath, ".cache", cacheName);
        write(p, data);
        return p;
    }
}

alias HipFS = HipFileSystem;