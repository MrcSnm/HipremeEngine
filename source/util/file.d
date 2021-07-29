module util.file;
import std.stdio: File;
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



class FileProgression
{
    protected ulong progress;
    protected uint stepSize;
    protected ulong fileSize;
    ubyte[] fileData;
    ubyte[] buffer;
    File target;

    /**
    *   If readsteps == 0, it will automatically decide how it will progress
    *   through the file. Actually it will use 10 powered to x, x is defined by
    *   the first power of 10 that makes the file size goes decimal
    */
    this(string filePath, uint readSteps = 0)
    {
        progress = 0;
        target = File(filePath, "r");
        ulong fSize = target.size;
        fileSize = fSize;
        fileData.reserve(cast(uint)fSize);
        real sz = fSize;

        if(readSteps == 0)
        {
            uint i = 10;
            while((sz/=10) == cast(uint)sz)
                i*= 10;
            stepSize = i;
        }
        else
            stepSize = readSteps;

        if(fSize % 2 == 1) //Odd
        {
            buffer = new ubyte[1];
            target.rawRead(buffer);
            fileData~= buffer[];
            progress+= 1;
        }
        stepSize = cast(uint)fSize/stepSize;
        buffer.length = stepSize;
    }

    bool update()
    {
        target.rawRead(buffer);
        fileData~= buffer[];
        progress+=stepSize;
        import std.stdio;
        writeln(fileSize, " ", progress);
        bool finished = progress >= fileSize;
        if(finished)
            target.close();

        return !finished;
    }
    

    float getProgress(){return progress/cast(float)fileSize;}
    @property ulong readSize(){return fileData.length;}
    @property ulong size(){return fileSize;}


    override string toString(){return cast(string)fileData;};
}