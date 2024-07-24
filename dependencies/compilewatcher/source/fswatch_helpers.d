module fswatch_helpers;

version(Windows)
{
    size_t timeLastModified(const(wchar)* filePath)
    {
        import core.sys.windows.winbase;
        import core.sys.windows.winnt;
        import core.sys.windows.basetsd;

        HANDLE hFile = CreateFile(filePath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
        if(hFile == INVALID_HANDLE_VALUE)
            return 0;

        FILETIME ftCreate, ftAccess, ftWrite;

        scope(exit) CloseHandle(hFile);


        if(!GetFileTime(hFile, &ftCreate, &ftAccess, &ftWrite))
            return 0;

        ULARGE_INTEGER lastModTime;

        lastModTime.LowPart = ftWrite.dwLowDateTime;
        lastModTime.HighPart = ftWrite.dwHighDateTime;

        return lastModTime.QuadPart;
    }

    string winGetCwd()
    {
        import core.sys.windows.winnt:MAX_PATH;
        import core.sys.windows.winbase;
        char[MAX_PATH] buffer;

        uint length = GetCurrentDirectoryA(MAX_PATH, buffer.ptr);

        char[] ret = new char[](length);
        ret[] = buffer[0..length];

        return cast(string)ret;
    }

    bool winExists(const(wchar)* filePath)
    {
        import core.sys.windows.winnt;
        import core.sys.windows.winbase;

        DWORD fileAttr = GetFileAttributes(filePath);

        return fileAttr != INVALID_FILE_ATTRIBUTES;
    }

    bool winIsDir(const(wchar)* path)
    {
        import core.sys.windows.winnt;
        import core.sys.windows.winbase;
        DWORD fileAttr = GetFileAttributes(path);
        if (fileAttr == INVALID_FILE_ATTRIBUTES)
            return false;

        return (fileAttr & FILE_ATTRIBUTE_DIRECTORY) != 0;
    }


}