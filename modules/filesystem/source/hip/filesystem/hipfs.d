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

/** 
 * Returns whether if the path attempts to exit the initial one.
 * Params:
 *   initial = 
 *   toAppend = 
 * Returns: 
 */
private pure bool validatePath(string initial, string toAppend)
{
    import hip.util.array:lastIndexOf;
    import hip.util.string:splitRange, PathString;
    import hip.util.system : sanitizePath;

    if(initial.length != 0 && initial[$-1] == '/')
        initial = initial[0..$-1];
    scope string appends = toAppend.sanitizePath;

    PathString newPath = PathString(initial.sanitizePath);

    foreach(a; splitRange(appends, "/"))
    {
        if(a == "" || a == ".")
            continue;
        if(a == "..")
        {
            long lastInd = newPath.toString.lastIndexOf('/');
            if(lastInd == -1)
                continue;
            newPath = newPath[0..cast(uint)lastInd];
        }
        else
        {
            newPath~= "/";
            newPath~= a;
        }
    }
    for(int i = 0; i < initial.length; i++)
        if(initial[i] != newPath[i])
            return false;
    return true;
}

///Function is implemented AppDelegate.m
version(AppleOS)
private extern(C) const(char*) hipGetResourcesPath();

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


class HipFSPromise : IHipFSPromise
{
    string filename;
    FileReadResult delegate(in ubyte[] data)[] onSuccessList;
    void delegate(string err)[] onErrorList;
    ubyte[] data;
    bool finished = false;
    FileReadResult result = FileReadResult.keep;
    this(string filename){this.filename = filename;}
    IHipFSPromise addOnSuccess(FileReadResult delegate(in ubyte[] data) onSuccess)
    {
        if(result != FileReadResult.keep)
            throw new Exception("HipFSPromise Error: "~filename~" data was already freed, but addOnSuccess is being called.");
        if(finished)
        {
            if(onSuccess(data) == FileReadResult.free)
            {
                result = FileReadResult.free;
                dispose();
            }
        }
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
    FileReadResult setFinished(ubyte[] data)
    {
        if(finished)
            assert(false, "HipFSPromise was already resolved.");
        this.data = data;
        this.finished = true;
        FileReadResult r = FileReadResult.keep;
        if(data) foreach(success; onSuccessList)
            r|= success(data);
        else foreach(err; onErrorList)
            err("Could not read file");

        if(r == FileReadResult.free)
            dispose();
        return result = r;
    }
    bool resolved() const{return finished;}

    void dispose()
    {
        version(WebAssembly) {}
        else
        {
            import core.memory;
            GC.free(data.ptr);
            data = null;
        }
    }
}

/**
* FileSystem access for specific platforms.
*/
class HipFileSystemImplementation : IHipFS
{
    protected string defPath;
    protected string initialPath = "";
    protected string combinedPath;
    protected bool isInstalled;
    protected IHipFileSystemInteraction fs;
    protected size_t filesReadingCount = 0;

    protected bool function(string path, out string errMessage)[] extraValidations;

    version(Android){import hip.filesystem.systems.android;}
    else version(UWP){import hip.filesystem.systems.uwp;}
    else version(WebAssembly){import hip.filesystem.systems.browser;}
    else version(PSVita){import hip.filesystem.systems.cstd;}
    else version(CustomRuntimeTest){import hip.filesystem.systems.cstd;}
    else version(HipDStdFile){import hip.filesystem.systems.dstd;}
    else {import hip.filesystem.systems.cstd;}

    public void initializeAbsolute()
    {
        if(fs is null)
        {
            version(Android){fs = new HipAndroidFileSystemInteraction();}
            else version(UWP){fs = new HipUWPileSystemInteraction();}
            else version(PSVita){fs = new HipCStdioFileSystemInteraction();}
            else version(CustomRuntimeTest){fs = new HipCStdioFileSystemInteraction();}
            else version(WebAssembly){fs = new HipBrowserFileSystemInteraction();}
            else
            {
                version(HipDStdFile){}else{static assert(false, "HipDStdFile should be marked to be used.");}
                fs = new HipStdFileSystemInteraction();
            }
        }
    }
 
    
    public void install(string path)
    {
        import hip.util.system : sanitizePath;
        if(!isInstalled)
        {
            initialPath = path.sanitizePath;
            setPath("");
            isInstalled = true;
        }
    }
    /**
    *   This function may be refactored in future since having different
    *   directories to resources to writeable paths is becoming more common
    */
    version(AppleOS)
    public string getResourcesPath()
    {
        import core.stdc.string;
        auto str = hipGetResourcesPath;
        return cast(string)str[0..strlen(str)];
    }

    
    public void install(string path,
    bool function(string path, out string errMessage)[] validations ...)
    {
        import hip.util.system : sanitizePath;
        if(!isInstalled)
        {
            install(path);
            foreach (v; validations){extraValidations~=v;}
        }
    }
    public string getPath(string path)
    {
        import hip.util.path:joinPath;
        import hip.util.system : sanitizePath;
        import hip.console.log;

        if(combinedPath)
            return joinPath(combinedPath, path.sanitizePath);
        return path.sanitizePath;
    }
    public bool isPathValidExtra(string path)
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
    
    public bool isPathValid(string path, bool expectsFile = true, bool shouldVerify = true)
    {
        import hip.error.handler;
        import hip.util.string;
        if(!isInstalled) return false;
        PathString s = PathString(defPath, path);
        if(!validatePath(initialPath, s.toString))
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

    public bool setPath(string path)
    {
        import hip.util.path:joinPath;
        import hip.util.system : sanitizePath;
        import hip.console.log;
        if(path)
        {
            defPath = path.sanitizePath;
            combinedPath = joinPath(initialPath, defPath);
        }
        else
            combinedPath = initialPath;
        return validatePath(initialPath, combinedPath);
    }

    private void defaultErrorHandler(string err = "")
    {
        import hip.error.handler;
        filesReadingCount--;
        ErrorHandler.assertExit(false, "HipFS Error: "~err);
    }

    ///TODO: Fix API. It currently does not work with sync and async at the same way.
    /// It needs to specify both onSuccess and onError before being able to establish if it is possible to keep or not the memory.
    public IHipFSPromise read(string path)
    {
        import hip.console.log;
        hiplog("Required path ", path);
        path = getPath(path);
        if(!isPathValid(path))
        {
            hiplog("Invalid path ",path," received.");
            return null;
        }
        filesReadingCount++;

        HipFSPromise promise = new HipFSPromise(path);

        fs.read(path, (ubyte[] data)
        {
            filesReadingCount--;
            return promise.setFinished(data);
        }, (string err)
        {
            promise.setFinished(null);
            defaultErrorHandler(err);
        });
        
        return promise;
    }

    public IHipFSPromise readText(string path)
    {
        IHipFSPromise ret = read(path);
        // if(ret)
        // {
        //     import std.utf;
        //     output = toUTF8((cast(string)data));
        // }
        return ret;
    }
    
    public bool write(string path, const(void)[] data)
    {
        if(!isPathValid(path))
            return false;
        return fs.write(getPath(path), data);
    }


    public bool exists(string path){return isPathValid(path) && fs.exists(getPath(path));}
    public bool remove(string path)
    {
        if(!isPathValid(path))
            return false;
        return fs.remove(getPath(path));
    }

    public string getcwd()
    {
        return getPath("");
    }

    public bool absoluteExists(string path){return fs.exists(path);}
    public bool absoluteIsDir(string path){return fs.isDir(path);}
    public bool absoluteIsFile(string path){return fs.isFile(path);}
    public bool absoluteRemove(string path){return fs.remove(path);}
    public bool absoluteWrite(string path, const(void)[] data){return fs.write(path, data);}
    public bool absoluteRead(string path, out void[] output)
    {
        ///This may need to be refactored in the future.
        // import std.functional:toDelegate;
        return fs.read(path, (void[] data){output = data; return FileReadResult.keep;}, (err) => defaultErrorHandler(err));
    }
    @ExportD("ubyte") public bool absoluteRead(string path, out ubyte[] output)
    {
        void[] data;
        bool ret = absoluteRead(path, data);
        output = cast(ubyte[])data;
        return ret;
    }

    public bool absoluteReadText(string path, out string output)
    {
        void[] data;
        bool ret = absoluteRead(path, data);
        if(ret)
            output = cast(string)data;
        return ret;
    }


    public bool isDir(string path){return isPathValid(path, false, false) && fs.isDir(getPath(path));}
    public bool isFile(string path){return isPathValid(path, true, false) && fs.isFile(getPath(path));}

    public string writeCache(string cacheName, void[] data)
    {
        import hip.util.path:joinPath;
        string p = joinPath(initialPath, ".cache", cacheName);
        write(p, data);
        return p;
    }
}

HipFileSystemImplementation HipFileSystem()
{
    __gshared HipFileSystemImplementation fs;
    if(!fs)
        fs = new HipFileSystemImplementation();
    return fs;
}

export extern(C) IHipFS HipFileSystemAPI()
{
    return HipFileSystem();
}

alias HipFS = HipFileSystem;