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
string joinPath(string[] paths ...){return joinPath(paths);}
string joinPath(string[] paths)
{
    if(paths.length == 1)
        return paths[0];
    string output;
    char charType = isPathUnixStyle(paths[0]) ? '/' : '\\';
    for(int i = 0; i < paths.length; i++)
    {
        if(paths[i] == "")
            continue;
        output~=paths[i];
        if(i+1 != paths.length &&
        paths[i+1].length != 0 &&
        paths[i+1][0] != charType &&
        paths[i][$-1] != charType)
            output~=charType;
    }
    return output;
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

import std.stdio;

class FileProgression
{
    protected ulong progress;
    protected uint stepSize;
    protected ulong fileSize;
    protected void delegate(ref ubyte[] data) onFinish;
    protected void delegate(float progress) onUpdate;
    ubyte[] fileData;
    ubyte[] buffer;
    File target;

    /**
    *   If bytes == 0, it will use readsteps.
    *
    *   Readsteps default is by progressing from 0 to 100, which makes great for percentage. Also notice that with 100 readsteps there's almost
    *   no loss compared to reading the file in one go, so it is the recommended value.
    *
    *   The greater the readsteps, the more time it will take to read the file and the more precision the percentage will have. Usually 100 should be enough.
    *
    *   If the readsteps are greater than the filesize, it will clamp to fileSize as readsteps.
    *   That means it will update at every byte
    */
    this(string filePath, uint readSteps = 100, uint bytes = 0)
    {
        assert(readSteps != 0 || bytes != 0, "Can't have readSteps and bytes both == 0");
        progress = 0;
        target = File(filePath, "r");
        ulong fSize = fileSize = target.size;
        assert(cast(uint)fSize < uint.max, "Filesize is greater than uint.max, contact the FileProgression mantainer");
        fileData.reserve(cast(uint)fSize);
        
        if(readSteps > fSize)
            readSteps = cast(uint)fSize;
        if(bytes != 0)
            readSteps = cast(uint)fSize/bytes;

        real sz =cast(real)fSize/readSteps;
        if(sz != fSize/readSteps) //Odd
        {
            ulong remaining = cast(ulong)((sz-(fSize/readSteps))*readSteps);
            buffer = new ubyte[remaining];
            target.rawRead(buffer);
            fileData~= buffer[];
            progress+= remaining;
            stepSize = cast(uint)(fSize-remaining)/readSteps;
        }
        else
            stepSize = cast(uint)fSize/readSteps;
        buffer.length = stepSize;
    }

    void setOnFinish(void delegate(ref ubyte[] data) onFinish){this.onFinish = onFinish;}
    void setOnUpdate(void delegate(float progress) onUpdate){this.onUpdate = onUpdate;}

    bool update()
    {
        target.rawRead(buffer);
        fileData~= buffer[];
        progress+=stepSize;
        if(onUpdate)
            onUpdate(getProgress());
        bool finished = progress >= fileSize;
        if(finished)
        {
            target.close();
            if(onFinish)
                onFinish(this.fileData);
        }

        return !finished;
    }
    

    float getProgress(){return progress/cast(float)fileSize;}
    @property ulong readSize(){return fileData.length;}
    @property ulong size(){return fileSize;}


    override string toString(){return cast(string)fileData;}
}