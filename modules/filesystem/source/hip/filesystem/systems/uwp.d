module hip.filesystem.systems.uwp;
import hip.api.filesystem.hipfs;
import hip.filesystem.hipfs : HipFile;
import hip.error.handler;

version(UWP)
{
    import core.sys.windows.windef;
    import core.sys.windows.winbase;
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
            if(ErrorHandler.assertLazyErrorMessage(exists(path), "FileSystem Error:", "Filed named '"~path~"' does not exists"))
                return false;
            HipUWPFile f = new HipUWPFile(path, FileMode.READ);
            import hip.console.log;
            logln(path, " " , f.getSize);
            if(f.fp == null || f.getSize == 0) return false;
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
            WIN32_FILE_ATTRIBUTE_DATA info = void;
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