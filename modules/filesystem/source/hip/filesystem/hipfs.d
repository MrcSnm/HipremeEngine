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

public import hip.hipengine.api.filesystem.hipfs;

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


version(none) abstract class HipFile : IHipFileItf
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

version(Android)
{
    public import hip.jni.android.asset_manager;
    public import hip.jni.android.asset_manager_jni;
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
            ErrorHandler.assertErrorMessage(asset != null, "HipAndroidFile error",
            "Can't get size from null asset '"~path~"'");
            return cast(ulong)AAsset_getLength64(asset);
        }
        override bool open(string path, FileMode mode)
        {
            asset = AAssetManager_open(aaMgr, path.toStringz, AASSET_MODE_BUFFER);
            return asset != null;
        }
        override int read(void* buffer, ulong count)
        {
            ErrorHandler.assertErrorMessage(asset != null, "HipAndroidFile error", "Can't read null asset");
            return AAsset_read(asset, buffer, count);
        }
        override long seek(long count, int whence = SEEK_CUR)
        {
            ErrorHandler.assertErrorMessage(asset != null, "HipAndroidFile error", "Can't seek null asset");
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
            if(asset != null)
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
        
        bool isDir(string path)
        {
            return false; 
        }
        
    }
}


/**
*   All those string allocations should be removed or turnt into @nogc somehow. The better cached, the best.
*
*/
class HipCStdioFileSystemInteraction : IHipFileSystemInteraction
{
    version(Windows)
        pragma(lib, "Shlwapi.lib"); //PathIsDirectory
    bool read(string path, out void[] output)
    {
        import core.stdc.stdio;
        import hip.error.handler;
        if(ErrorHandler.assertErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
            return false;

        auto f = fopen((path~"\0").ptr, "r");
        fseek(f, 0, SEEK_END);
        auto size = ftell(f);

        if(size <= 0)
            return false;
        fseek(f, 0, SEEK_SET);
        output.length = cast(typeof(output.length))size;

        scope(exit)
            fclose(f);
        if(fread(output.ptr, cast(size_t)size, 1, f) != size)
            return false;

        return true;
    }
    bool write(string path, void[] data)
    {
        import core.stdc.stdio;
        if(exists(path))
        {
            auto file = fopen(cachedStringz(path), "w");
            scope(exit)
                fclose(file);
            if(fwrite(data.ptr, 1, data.length, file) != data.length)
            {
                return fflush(file) == 0;
            }
            return true;
        }
        return false;
    }
    bool exists(string path)
    {
        import core.stdc.stdio;
        if(auto file = fopen(cachedStringz(path), "r"))
        {
            fclose(file);
            return true;
        }
        return false;
    }
    bool remove(string path)
    {
        static import core.stdc.stdio;
        if(exists(path))
        {
            return core.stdc.stdio.remove(cachedStringz(path)) == 0;
        }

        return false;
    }
    version(Posix)
        import core.sys.posix.sys.stat;
    else version(Windows)
        import core.sys.windows.shlwapi : PathIsDirectoryA;
    bool isDir(string path)
    {
        version(Windows)
        {
            return PathIsDirectoryA(cachedStringz(path)) == 1;
        }
        else version(Posix)
        {
            stat_t st;
            stat(cachedStringz(path), &st);
            return S_ISDIR(st.st_mode);
        }
    }
    
}

version(HipDStdFile) class HipStdFileSystemInteraction : IHipFileSystemInteraction
{
    import std.stdio : File;
    bool read(string path, out void[] output)
    {
        import hip.error.handler;
        if(ErrorHandler.assertErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
            return false;

        auto f = File(path);
        output.length = f.size;
        f.rawRead(output);
        return true;
    }
    bool write(string path, void[] data)
    {
        static import std.file; 
        std.file.write(path, data);return true;
    }
    bool exists(string path)
    {
        static import std.file;
        return std.file.exists(path);
    }
    bool remove(string path)
    {
        static import std.file;
        std.file.remove(path);return true;
    }
    
    bool isDir(string path)
    {
        static import std.file;
        return std.file.isDir(path);
    }
    
}


version(UWP)
{
    import core.sys.windows.windef;
    import hip.bind.external : UWPCreateFileFromAppW,
                        UWPDeleteFileFromAppW,
                        UWPGetFileAttributesExFromAppW;
    class HipUWPFile : HipFile
    {
        HANDLE fp;
        import std.utf:toUTF16z;
        @disable this();
        this(string path, FileMode mode)
        {
            super(path, mode);
        }
        bool open(string path, FileMode mode)
        {
            DWORD desiredAcces;
            DWORD shareMode;
            DWORD createDisposition;
            switch(mode)
            {
                case FileMode.READ:
                    desiredAcces = GENERIC_READ;
                    shareMode = FILE_SHARE_READ;
                    createDisposition = OPEN_EXISTING;
                    break;
                case FileMode.WRITE:
                    desiredAcces = GENERIC_WRITE;
                    shareMode = FILE_SHARE_WRITE;
                    createDisposition = CREATE_ALWAYS;
                    break;
                case FileMode.READ_WRITE:
                    desiredAcces = GENERIC_READ | GENERIC_WRITE;
                    shareMode = FILE_SHARE_READ | FILE_SHARE_WRITE;
                    createDisposition = OPEN_ALWAYS;
                    break;
                case FileMode.APPEND:
                case FileMode.READ_APPEND:
                default:
                    shareMode = FILE_SHARE_VALID_FLAGS;
                    desiredAcces = GENERIC_ALL;
                    createDisposition = OPEN_EXISTING;
            }
            
            fp = UWPCreateFileFromAppW(path.toUTF16z, desiredAcces, shareMode, cast(SECURITY_ATTRIBUTES*)null, createDisposition, 
            FILE_ATTRIBUTE_NORMAL, cast(void*)null);

            return fp != null;
        }
        int read(void* buffer, ulong count)
        {
            if(fp == null) return 0;

            uint numRead;
            if(ReadFile(fp, buffer, cast(int)count, &numRead, cast(OVERLAPPED*)null))
                return numRead;
            return 0;
        }
        ///Whence is the same from stdio
        override long seek(long count, int whence)
        {
            super.seek(count, whence);
            if(fp == null) return 0;
            DWORD winWhence;
            switch(whence)
            {
                case SEEK_CUR:
                    winWhence = FILE_CURRENT;
                    break;
                case SEEK_END:
                    winWhence = FILE_END;
                    break;
                case SEEK_SET:
                    winWhence = FILE_BEGIN;
                    break;
                default:ErrorHandler.assertExit(false, "Unsupported whence");
            }
            LARGE_INTEGER ret;
            LARGE_INTEGER countTemp;
            countTemp.QuadPart = count;
            SetFilePointerEx(fp, countTemp, &ret, winWhence);
            return cast(int)ret.QuadPart;
        }
        ulong getSize()
        {
            LARGE_INTEGER lg;
            if(fp == null) return 0;

            if(GetFileSizeEx(fp,  &lg))
                return cast(ulong)lg.QuadPart;
            return 0;
        }
        void close()
        {
            if(fp != null)
                CloseHandle(fp);
        }
    }
    class HipUWPileSystemInteraction : IHipFileSystemInteraction
    {

        bool read(string path, out void[] output)
        {
            if(ErrorHandler.assertErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
                return false;
            HipUWPFile f = new HipUWPFile(path, FileMode.READ);
            import hip.console.log;
            logln(path, " " , f.getSize);
            if(f.fp == null) return false;
            output.length = f.size;
            f.read(output.ptr, f.size);
            f.close();
            destroy(f);
            return true;
        }
        bool write(string path, void[] data)
        {
            HipUWPFile f = new HipUWPFile(path, FileMode.WRITE);
            if(f.fp == null) return false;

            uint bytesWritten;
            bool ret = cast(bool)WriteFile(f.fp, data.ptr, cast(uint)data.length, &bytesWritten, cast(OVERLAPPED*)null);
            destroy(f);
            return ret;
        }
        bool exists(string path)
        {
            import std.utf:toUTF16z;
            WIN32_FILE_ATTRIBUTE_DATA info;
            UWPGetFileAttributesExFromAppW(path.toUTF16z, GET_FILEEX_INFO_LEVELS.GetFileExInfoStandard, &info);
            return info.dwFileAttributes != INVALID_FILE_ATTRIBUTES;
        }
        bool remove(string path)
        {
            import std.utf:toUTF16z;
            if(!exists(path)) return false;
            return cast(bool)DeleteFile(path.toUTF16z);
        }
        
        bool isDir(string path)
        {
            return false;
        }
        
    }
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
 
    
    public static void install(string path)
    {
        import hip.util.system : sanitizePath;
        if(!hasSetInitial)
        {
            initialPath = path.sanitizePath;
            version(Android){fs = new HipAndroidFileSystemInteraction();}
            // else version(UWP){fs = new HipUWPileSystemInteraction();}
            else version(PSVita){fs = new HipCStdioFileSystemInteraction();}
            else
            {
                version(HipDStdFile){}else{static assert(false, "HipDStdFile should be marked to be used.");}
                fs = new HipStdFileSystemInteraction();
            }
            setPath("");
            hasSetInitial = true;
        }
    }

    
    version(FunctionArrayAvailable)
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
    public static string getPath(string path)
    {
        import hip.util.path:joinPath;
        import hip.util.system : sanitizePath;
        return joinPath(combinedPath, path.sanitizePath);
    }
    public static bool isPathValid(string path){return validatePath(initialPath, defPath~path);}
    public static bool isPathValidExtra(string path)
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

    public static bool setPath(string path)
    {
        import hip.util.path:joinPath;
        import hip.util.system : sanitizePath;
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
        if(ret)
            output = cast(string)data;
        return ret;
    }

    version(HipDStdFile)
    {
        import std.stdio:File;
        public static bool getFile(string path, string opts, out File file)
        {
            if(!isPathValid(path) || !isPathValidExtra(path))
                return false;
            file = File(getPath(path), opts);
            return true;
        }

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

    public static bool isDir(string path){return fs.isDir(path);}
    public static bool isFile(string path){return fs.isFile(path);}

    public static string writeCache(string cacheName, void[] data)
    {
        import hip.util.path:joinPath;
        string p = joinPath(initialPath, ".cache", cacheName);
        write(p, data);
        return p;
    }
}

alias HipFS = HipFileSystem;