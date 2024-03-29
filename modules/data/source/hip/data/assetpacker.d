/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.data.assetpacker;

import hip.util.file;

enum HapHeaderStart = "1HZ00ZH9";
enum HapHeaderEnd   = "9HZ00ZH1";
enum HapHeaderSize = HapHeaderEnd.length + HapHeaderStart.length;

enum HapHeaderStatus
{
    SUCCESS = 0, 
    DOES_NOT_EXIST,
    NOT_HAP
}


struct HapChunk
{
    string fileName;
    size_t startPosition;
    ubyte[] bin;

    alias bin this;
}

private extern(C) int sortChunk(const(void*) a, const(void*) b)
{
    long startPosA = (cast(HapChunk*)a).startPosition;
    long startPosB = (cast(HapChunk*)b).startPosition;
    return cast(int)(startPosA - startPosB);
}


version(HipDStdFile):

__EOF__

class HapFile
{
    HapChunk[string] chunks;
    immutable string path;
    uint fileSteps;
    protected FileProgression fp;

    /**
    *   Reads the entire hapfile and get its chunks synchronously
    */
    static HapFile get(string filePath)
    {
        HapFile f = new HapFile(filePath, 1);
        f.update();
        return f;
    }


    this(string filePath, uint fileSteps = 10)
    {
        this.path = filePath;
        this.fileSteps = fileSteps;
    }

    bool loadFromMemory(in ubyte[] data)
    {
        HapChunk[] ch = getHapChunks(data, getHeaderStart(data));
        foreach(c;ch)
            chunks[c.fileName] = c;
        return ch.length != 0;
    }

    string getText(string chunkName, bool removeCarriageReturn = true)
    {
        import hip.util.string : replaceAll;
        HapChunk* ch = (chunkName in chunks);
        if(ch is null)
            return "";
        if(!removeCarriageReturn)
            return cast(string)ch.bin;
        return replaceAll(cast(string)ch.bin, '\r');
    }

    string[] getChunksList()
    {
        string[] ret;
        foreach(k, v; chunks)
            ret~=k;
        return ret;
    }
    bool update(){return fp.update();}
    float getProgress(){return fp.getProgress();}


    alias chunks this;
}

private string reverse(string s)
{
    string ret = "";
    foreach_reverse(c; s)
        ret~= c;
    return ret;
}

/**
*
*   Writes an asset pack in the .hap format (Hipreme Asset Pack),
*   it is only sequential binary chunk containing its headers on
*   the file end.
*
*   Returns if the file writing was a success.
*/
bool writeAssetPack(string outputFileName, string[] assetPaths, string basePath = "")
{
    import hip.console.log;
    import hip.util.conv:to;
    import hip.util.path : relativePath;
    import core.stdc.string : memcpy;
    import std.file;
    import std.stdio : File;
    if(exists(outputFileName~".hap"))
    {
        rawlog(outputFileName~".hap already exists");
        return false;
    }
    ubyte[] plainData;
    size_t dataLength = 0;

    string toAppend = HapHeaderEnd;

    foreach(p; assetPaths)
    {
        string path = p;
        if(basePath != "")
            path = relativePath(path, basePath);

        if(exists(path))
        {
            auto _f = File(path);
            void[] fileData = new void[](_f.size);
            _f.rawRead(fileData);
            dataLength+= fileData.length;
            plainData.length = dataLength;
            toAppend~= path~", "~to!string(dataLength-fileData.length)~"\n";
            memcpy((plainData.ptr+dataLength-fileData.length), fileData.ptr, fileData.length);
        }
        else
            rawlog("Archive at path '"~path~"' does not exists, it will be skipped");
    }
    toAppend~= HapHeaderStart;

    plainData.length+= toAppend.length;
    memcpy(plainData.ptr+dataLength, toAppend.ptr, toAppend.length);
    std.file.write(outputFileName~".hap", plainData);

    return false;
}

/**
*   Appends the file to the asset pack. It does not check if the file is already present.
*   
*   Returns the operation status, 0 = success
*/
HapHeaderStatus appendAssetInPack(string hapFile, string[] assetPaths, string basePath = "")
{
    import hip.console.log;
    import hip.util.conv:to;
    import hip.util.path : relativePath;
    import core.stdc.string : memcpy;
    import std.file : exists, read;
    import std.stdio : File;

    if(!exists(hapFile))
        return HapHeaderStatus.DOES_NOT_EXIST;

    File f = File(hapFile, "r+");
    ubyte[] rawData = new ubyte[f.size];
    f.rawRead(rawData);

    size_t headerStart = getHeaderStart(rawData);
    if(headerStart == 0)
        return HapHeaderStatus.NOT_HAP;

    string files = "";
    for(size_t i = headerStart; i < rawData.length - HapHeaderEnd.length; i++)
        files~= rawData[i];

    headerStart-= HapHeaderStart.length;
    f.seek(headerStart);

    ubyte[] dataToAppend;

    string toAppend = "";
    foreach(p; assetPaths)
    {
        string finalPath = p;
        if(basePath != "")
            finalPath = relativePath(finalPath, basePath);
        if(exists(finalPath))
        {
            ubyte[] data = cast(ubyte[])read(finalPath);
            dataToAppend.length+= data.length;
            memcpy(dataToAppend.ptr+(dataToAppend.length - data.length), data.ptr, data.length);
            toAppend~= finalPath~", "~to!string(headerStart)~"\n";
            headerStart+= data.length;
        }
        else
            rawlog("File named '"~finalPath~"' does not exists, it will not be appended");
    }

    f.rawWrite(dataToAppend);
    f.rawWrite(HapHeaderEnd);
    f.rawWrite(files);
    f.rawWrite(toAppend);
    f.rawWrite(HapHeaderStart);
    f.close();
    
    return HapHeaderStatus.SUCCESS;
    
}

/**
*       Updates files in the assetpack, mantains the order and won't overwrite every single data,
*   unless the data to be updated is at the top. 
*   
*       Mantaining an intelligent system that will let the less changing files at the 
*   top is the way to go.
*/
HapHeaderStatus updateAssetInPack(string hapFile, string[] assetPaths, string basePath = "")
{
    import hip.console.log;
    import hip.util.conv:to;
    import hip.util.array : indexOf;
    import hip.util.path : relativePath;
    import std.file : exists, read;
    import std.stdio : File;

    if(!exists(hapFile))
        return HapHeaderStatus.DOES_NOT_EXIST;
    File target = File(hapFile, "r+");
    ubyte[] hapData = new ubyte[target.size];
    target.rawRead(hapData);
    
    const size_t headerStart = getHeaderStart(hapData);
    if(headerStart == 0)
        return HapHeaderStatus.NOT_HAP;

    string[] toAppend;
    HapChunk[] chunks = getHapChunks(hapData, headerStart);


    string[] fileNames;
    foreach(a; chunks) 
        fileNames~= a.fileName;

    size_t lowestStartPosition = size_t.max;

    foreach(p; assetPaths)
    {
        string path = p;
        if(basePath != "")  
            path = relativePath(path, basePath);
        if(!exists(path))
        {
            rawlog("File '"~path~"' does not exists");
            continue;
        }
        long pathIndex = indexOf(fileNames, path);
        if(pathIndex != -1)
        {
            HapChunk* f = &chunks[cast(size_t)pathIndex];
            if(f.startPosition < lowestStartPosition)
                lowestStartPosition = f.startPosition;
            ubyte[] fileData = cast(ubyte[])read(path);
            f.bin = fileData;
        }
        else
            toAppend~= path;
    }

    import core.stdc.stdlib:qsort;
    qsort(cast(void*)chunks.ptr, chunks.length, chunks[0].sizeof, &sortChunk);

    target.seek(lowestStartPosition);

    size_t nextStartPosition = lowestStartPosition;
    for(int i = 0; i < chunks.length; i++)
    {
        if(chunks[i].startPosition >= lowestStartPosition)
        {
            //rawlog("Updating "~chunks[i].fileName);
            target.rawWrite(chunks[i].bin);
            chunks[i].startPosition = nextStartPosition;
            nextStartPosition+= chunks[i].bin.length;
        }
    }

    fileTruncate(target, nextStartPosition);
    target.rawWrite(HapHeaderEnd);
    foreach(_f; chunks)
        target.rawWrite(_f.fileName~", "~to!string(_f.startPosition)~"\n");
    target.rawWrite(HapHeaderStart);
    target.close();

    if(toAppend.length != 0)
        return appendAssetInPack(hapFile, toAppend,  basePath);
    return HapHeaderStatus.SUCCESS;
}

size_t getHeaderStart (string hapFile)
{
    import std.file : exists, read;
    if(exists(hapFile))
    {
        ubyte[] hapData = cast(ubyte[])read(hapFile);
        getHeaderStart(hapData);
    }
    return 0;
}
size_t getHeaderStart (in ubyte[] fileData)
{
    string header = "";
    size_t i;
    for(i = 0; i != HapHeaderEnd.length; i++)
        header~= fileData[$-1-i];

    if(header != HapHeaderEnd)
        return 0;
    
    ptrdiff_t z = 0;
    i = fileData.length - i;
    fileCapture: for(; i != 0; i--)
    {
        while(fileData[i-z] == HapHeaderStart[z])
        {
            z++;
            if(z == HapHeaderStart.length)
                break fileCapture;
        }
        z = 0;
    }
    return i+1;
}

HapChunk[] getHapChunks(in ubyte[] hapFile, size_t headerStart)
{
    import hip.util.string : split;
    import hip.util.conv : to;
    import core.stdc.string : memcpy;
    HapChunk[] ret;
    string hap = "";
    for(size_t i = headerStart; i < hapFile.length-HapHeaderStart.length; i++)
        hap~= hapFile[i];
    string[] infos = split(hap,  '\n');

    foreach(info; infos)
    {
        HapChunk h;
        string[] temp = split(info, ", ");
        if(temp.length == 0)
            continue;
        h.fileName = temp[0];
        h.startPosition = to!size_t(temp[1]);
        ret~= h;
    }

    for(int i = 0; i < cast(int)ret.length-1; i++)
    {
        const size_t fileLength = ret[i+1].startPosition - ret[i].startPosition;
        ret[i].bin = new ubyte[fileLength];
        memcpy(ret[i].bin.ptr, hapFile.ptr+ret[i].startPosition, fileLength);
    }

    //File length - headerLength
    const size_t headerLength = (hapFile.length - headerStart);
    ret[$-1].bin = new ubyte[hapFile.length - ret[$-1].startPosition - headerLength - HapHeaderEnd.length];
    memcpy(ret[$-1].bin.ptr, hapFile.ptr+ret[$-1].startPosition, ret[$-1].bin.length);

    return ret;

}

HapChunk[] getHapChunks(string hapFilePath)
{
    import std.stdio : File;
    File f = File(hapFilePath);
    ubyte[] hapFile = new ubyte[f.size];
    f.rawRead(hapFile);
    return getHapChunks(hapFile, getHeaderStart(hapFile));
}