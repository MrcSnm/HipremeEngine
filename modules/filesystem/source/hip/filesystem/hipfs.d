/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.filesystem.hipfs;

public import hip.api.filesystem.hipfs;
import hip.util.reflection;

private pure bool validatePath(string initial, string toAppend)
{
    import hip.util.array:lastIndexOf;
    import hip.util.string:split;
    import hip.util.system : sanitizePath;

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
            newPath = newPath[0..cast(uint)lastInd];
        }
        else
            newPath~= "/"~a;
    }
    for(int i = 0; i < initial.length; i++)
        if(initial[i] != newPath[i])
            return false;
    return true;
}


abstract class HipFile : IHipFileItf
{
    immutable FileMode mode;
    immutable string path;
    ulong size;
    ulong cursor;
    @disable this();
    this(string path, FileMode mode)
    {
        this.mode = mode;
        this.path = path;
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


private class HipFSPromise : IHipFSPromise
{
    string filename;
    bool finished = false;
    ubyte[] data;
    void delegate(in ubyte[] data)[] onSuccessList;
    void delegate(string err)[] onErrorList;
    this(string filename){this.filename = filename;}
    IHipFSPromise addOnSuccess(void delegate(in ubyte[] data) onSuccess)
    {
        if(finished)
            onSuccess(data);
        else
            onSuccessList~=onSuccess;
        return this;
    }
    IHipFSPromise addOnError(void delegate(string error) onError)
    {
        if(finished && !data.length)
            onError("No data");
        else
            onErrorList~= onError;
        return this;
    }
    void setFinished(ubyte[] data)
    {
        import std.stdio;
        this.data = data;
        this.finished = true;
        if(data) foreach(success; onSuccessList)
            success(data);
        else foreach(err; onErrorList)
            err("Could not read file");

    }
    bool resolved() const{return finished;}
}

/**
* FileSystem access for specific platforms.
*/
class HipFileSystem
{
    protected __gshared string defPath;
    protected __gshared string initialPath = "";
    protected __gshared string combinedPath;
    protected __gshared bool hasSetInitial;
    protected __gshared IHipFileSystemInteraction fs;
    protected __gshared size_t filesReadingCount = 0;

    protected __gshared bool function(string path, out string errMessage)[] extraValidations;

    version(Android){import hip.filesystem.systems.android;}
    else version(UWP){import hip.filesystem.systems.uwp;}
    else version(WebAssembly){import hip.filesystem.systems.browser;}
    else version(HipDStdFile){import hip.filesystem.systems.dstd;}
    else {import hip.filesystem.systems.cstd;}
 
    
    public static void install(string path)
    {
        import hip.util.system : sanitizePath;
        if(!hasSetInitial)
        {
            initialPath = path.sanitizePath;
            version(Android){fs = new HipAndroidFileSystemInteraction();}
            else version(UWP){fs = new HipUWPileSystemInteraction();}
            else version(PSVita){fs = new HipCStdioFileSystemInteraction();}
            else version(WebAssembly){fs = new HipBrowserFileSystemInteraction();}
            else
            {
                version(HipDStdFile){}else{static assert(false, "HipDStdFile should be marked to be used.");}
                fs = new HipStdFileSystemInteraction();
            }
            setPath("");
            hasSetInitial = true;
        }
    }

    
    public static void install(string path,
    bool function(string path, out string errMessage)[] validations ...)
    {
        import hip.util.system : sanitizePath;
        if(!hasSetInitial)
        {
            install(path);
            foreach (v; validations){extraValidations~=v;}
        }
    }
    @ExportD public static string getPath(string path)
    {
        import hip.util.path:joinPath;
        import hip.util.system : sanitizePath;
        if(combinedPath)
            return joinPath(combinedPath, path.sanitizePath);
        return path.sanitizePath;
    }
    @ExportD public static bool isPathValidExtra(string path)
    {
        import hip.error.handler;
        import hip.util.system : sanitizePath;
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
    
    @ExportD public static bool isPathValid(string path, bool expectsFile = true, bool shouldVerify = true)
    {
        import hip.error.handler;
        if(!validatePath(initialPath, defPath~path))
        {
            ErrorHandler.showErrorMessage("Path failed default validation: can't reference external path.", path);
            return false;
        }
        if(shouldVerify)
        {
            if((expectsFile && !HipFS.absoluteIsFile(path)) || (!expectsFile && !HipFS.absoluteIsDir(path)))
            {
                ErrorHandler.showErrorMessage("Path failed default validation: Expected '"~ (expectsFile ? "file" : "directory") ~ 
                "' but received "~ (expectsFile ? "'directory'" : "'file'"), path);
                return false;
            }
        }

        return isPathValidExtra(path);
    }

    @ExportD public static bool setPath(string path)
    {
        import hip.util.path:joinPath;
        import hip.util.system : sanitizePath;
        if(path)
        {
            defPath = path.sanitizePath;
            combinedPath = joinPath(initialPath, defPath);
        }
        else
            combinedPath = initialPath;
        return validatePath(initialPath, combinedPath);
    }

    private static void delegate(string err) defaultErrorHandler()
    {
        return (err)
        {
            import hip.error.handler;
            filesReadingCount--;
            ErrorHandler.assertExit(false, "HipFS Error: "~err);
        };
    }
    
    @ExportD public static IHipFSPromise read(string path)
    {
        import hip.console.log;
        hiplog("Required path ", path);
        path = getPath(path);
        if(!isPathValid(path))
            return null;
        hiplog("Path validated.");
        filesReadingCount++;

        HipFSPromise promise = new HipFSPromise(path);
        fs.read(path, (ubyte[] data)
        {
            filesReadingCount--;
            promise.setFinished(data);
        }, (string err)
        {
            promise.setFinished(null);
            defaultErrorHandler()(err);
        });
        
        return promise;
    }

    @ExportD public static IHipFSPromise readText(string path)
    {
        IHipFSPromise ret = read(path);
        // if(ret)
        // {
        //     import std.utf;
        //     output = toUTF8((cast(string)data));
        // }
        return ret;
    }
    

    version(HipDStdFile)
    {
        import std.stdio:File;
        public static bool getFile(string path, string opts, out File file)
        {
            if(!isPathValid(path))
                return false;
            file = File(getPath(path), opts);
            return true;
        }

    } 

    @ExportD public static bool write(string path, void[] data)
    {
        if(!isPathValid(path))
            return false;
        return fs.write(getPath(path), data);
    }
    @ExportD public static bool exists(string path){return isPathValid(path) && fs.exists(getPath(path));}
    @ExportD public static bool remove(string path)
    {
        if(!isPathValid(path))
            return false;
        return fs.remove(getPath(path));
    }

    @ExportD public static string getcwd()
    {
        return getPath("");
    }

    @ExportD public static bool absoluteExists(string path){return fs.exists(path);}
    @ExportD public static bool absoluteIsDir(string path){return fs.isDir(path);}
    @ExportD public static bool absoluteIsFile(string path){return fs.isFile(path);}
    @ExportD public static bool absoluteRemove(string path){return fs.remove(path);}

    @ExportD public static bool absoluteRead(string path, out void[] output)
    {
        return fs.read(path, (void[] data){output = data;}, defaultErrorHandler);
    }
    @ExportD("ubyte") public static bool absoluteRead(string path, out ubyte[] output)
    {
        void[] data;
        bool ret = absoluteRead(path, data);
        output = cast(ubyte[])data;
        return ret;
    }

    @ExportD public static bool absoluteReadText(string path, out string output)
    {
        void[] data;
        bool ret = absoluteRead(path, data);
        if(ret)
            output = cast(string)data;
        return ret;
    }


    @ExportD public static bool isDir(string path){return isPathValid(path, false, false) && fs.isDir(getPath(path));}
    @ExportD public static bool isFile(string path){return isPathValid(path, true, false) && fs.isFile(getPath(path));}

    @ExportD public static string writeCache(string cacheName, void[] data)
    {
        import hip.util.path:joinPath;
        string p = joinPath(initialPath, ".cache", cacheName);
        write(p, data);
        return p;
    }
}

alias HipFS = HipFileSystem;
