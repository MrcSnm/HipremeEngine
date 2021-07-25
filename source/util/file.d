module util.file;
import std.conv:to;
import std.path;
import std.file;
import util.system;
import util.string;

string getFileContent(string path, bool noCarriageReturn = true)
{
    path = sanitizePath(path);
    if(!exists(path))
        return "";
    string content = readText(path);
    return (noCarriageReturn) ? content.replaceAll('\r') : content;
}

string getFileContentFromBasePath(string path, string basePath, bool noCarriageReturn = true)
{
    string finalPath = relativePath(sanitizePath(path), sanitizePath(basePath));
    return getFileContent(finalPath, noCarriageReturn);
}


import std.stdio: File;

void fileTruncate(File file, long offset) 
{
    version (Windows) 
    {
        import core.sys.windows.windows: SetEndOfFile;
        file.seek(offset);
        if(!SetEndOfFile(file.windowsHandle()))
            throw new FileException(file.name, "SetEndOfFile error");
    }

    version (Posix) 
    {
        import core.sys.posix.unistd: ftruncate;
        int res = ftruncate(file.fileno(), offset);
        if(res != 0)
            throw new FileException(file.name, "ftruncate error with code "~to!string(res));
    }
}