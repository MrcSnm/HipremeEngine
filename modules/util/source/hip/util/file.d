/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.file;
import hip.util.conv:to;
import hip.util.array:join, array;
import hip.util.system;
import hip.util.path;
import hip.util.string;


string getFileContent(string path, bool noCarriageReturn = true)
{
    import core.stdc.stdio;
    path = sanitizePath(path);
    FILE* file = fopen((path~"\0").ptr, "r");
    if(!file)
        return "";
    char[] buffer;

    fseek(file, 0, SEEK_END);
    auto size = ftell(file);
    fseek(file, 0, SEEK_SET);

    buffer.length = cast(typeof(buffer.length))size;
    size_t readSize = fread(buffer.ptr, cast(size_t)size, 1, file);
    if(readSize != buffer.length)
        buffer.length = readSize;
    fclose(file);

    string content = cast(string)buffer;
    return (noCarriageReturn) ? content.replaceAll('\r') : content;
}

version(Windows)
{
    string getcwd()
    {
        import core.sys.windows.winnt:MAX_PATH;
        import core.sys.windows.winbase;
        char[MAX_PATH] buffer;

        uint length = GetCurrentDirectoryA(MAX_PATH, buffer.ptr);

        char[] ret = new char[](length);
        ret[] = buffer[0..length];

        return cast(string)ret;
    }
}
else
{
    string getcwd()
    {
        import std.file;
        return std.file.getcwd();
    }
}



string stripLineBreaks(string content)
{
    content = content.replaceAll('\r');
    content = content.replaceAll('\n');
    return content;
}

// string getFileContentFromBasePath(string path, string basePath, bool noCarriageReturn = true)
// {
//     string finalPath = relativePath(sanitizePath(path), sanitizePath(basePath));
//     return getFileContent(finalPath, noCarriageReturn);
// }



version(none)
{
    import std.stdio:File;

    version(CustomRuntimeTest) version = CustomRuntime;
    version(WebAssembly) version = CustomRuntime;
    version(PSVita) version = CustomRuntime;

    version(CustomRuntimeTest) {void fileTruncate(File file, ptrdiff_t offset){}}
    else
    {
        import std.file;
        void fileTruncate(File file, ptrdiff_t offset) 
        {
            version (Windows) 
            {
                import hip.util.windows;
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
    }
}

version(none) class FileProgression
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
            size_t remaining = cast(size_t)((sz-(fSize/readSteps))*readSteps);
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
