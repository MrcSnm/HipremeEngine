module data.assetpacker;
import util.file;
import std.algorithm : countUntil, map, min, sort;
import core.stdc.stdio;
import std.array : split, array;
import std.conv:to;
import core.stdc.string;
import std.stdio;
import std.path;
import std.file;

enum HapHeaderStart = "1HZ00ZH9";
enum HapHeaderEnd   = "9HZ00ZH1";
enum HapHeaderSize = HapHeaderEnd.length + HapHeaderStart.length;

enum HapHeaderStatus
{
    SUCCESS = 0, 
    DOES_NOT_EXIST,
    NOT_HAP
}


struct HapFile
{
    string fileName;
    ulong startPosition;
    ubyte[] bin;
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
*   Writes an asset pack in the .hap format (hipreme asset pack),
*   it is only sequential binary chunk containing its headers on
*   the file end.
*
*   Returns if the file writing was a success.
*/
bool writeAssetPack(string outputFileName, string[] assetPaths, string basePath = "")
{
    if(exists(outputFileName~".hap"))
    {
        writeln(outputFileName~".hap already exists");
        return false;
    }
    ubyte[] plainData;
    ulong dataLength = 0;

    string toAppend = HapHeaderEnd;

    foreach(p; assetPaths)
    {
        string path = p;
        if(basePath != "")
            path = relativePath(path, basePath);

        if(exists(path))
        {
            void[] fileData = read(path);
            dataLength+= fileData.length;
            plainData.length = dataLength;
            toAppend~= path~", "~to!string(dataLength-fileData.length)~"\n";
            memcpy((plainData.ptr+dataLength-fileData.length), fileData.ptr, dataLength);
        }
        else
            writeln("Archive at path '"~path~"' does not exists, it will be skipped");
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
    if(!exists(hapFile))
        return HapHeaderStatus.DOES_NOT_EXIST;

    File f = File(hapFile, "r+");
    ubyte[] rawData = new ubyte[f.size];
    f.rawRead(rawData);

    ulong headerStart = getHeaderStart(rawData);
    if(headerStart == 0)
        return HapHeaderStatus.NOT_HAP;

    string files = "";
    for(ulong i = headerStart; i < rawData.length - HapHeaderEnd.length; i++)
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
            writeln("File named '"~finalPath~"' does not exists, it will not be appended");
    }

    f.rawWrite(dataToAppend);
    f.rawWrite(HapHeaderEnd);
    f.rawWrite(files);
    f.rawWrite(toAppend);
    f.rawWrite(HapHeaderStart);
    f.close();
    
    return HapHeaderStatus.SUCCESS;
    
}

HapHeaderStatus updateAssetInPack(string hapFile, string[] assetPaths, string basePath = "")
{
    if(!exists(hapFile))
        return HapHeaderStatus.DOES_NOT_EXIST;
    File target = File(hapFile, "r+");
    ubyte[] hapData = new ubyte[target.size];
    target.rawRead(hapData);
    
    const ulong headerStart = getHeaderStart(hapData);
    if(headerStart == 0)
        return HapHeaderStatus.NOT_HAP;

    string[] toAppend;
    HapFile[] files = getHapFiles(hapData, headerStart);

    string[] fileNames = files.map!"a.fileName".array();

    ulong lowestStartPosition = ulong.max;

    foreach(p; assetPaths)
    {
        string path = p;
        if(basePath != "")  
            path = relativePath(path, basePath);
        if(!exists(path))
        {
            writeln("File '"~path~"' does not exists");
            continue;
        }
        long pathIndex = countUntil(fileNames, path);
        if(pathIndex != -1)
        {
            HapFile* f = &files[pathIndex];
            lowestStartPosition = min(lowestStartPosition, f.startPosition);
            ubyte[] fileData = cast(ubyte[])read(path);
            f.bin = fileData;
        }
        else
            toAppend~= path;
    }
    files = files.sort!"a.startPosition < b.startPosition".array();

    target.seek(lowestStartPosition);

    ulong nextStartPosition = lowestStartPosition;
    for(int i = 0; i < files.length; i++)
    {
        if(files[i].startPosition >= lowestStartPosition)
        {
            writeln("Updating "~files[i].fileName);
            target.rawWrite(files[i].bin);
            files[i].startPosition = nextStartPosition;
            nextStartPosition+= files[i].bin.length;
        }
    }

    fileTruncate(target, nextStartPosition);
    target.rawWrite(HapHeaderEnd);
    foreach(_f; files)
        target.rawWrite(_f.fileName~", "~to!string(_f.startPosition)~"\n");
    target.rawWrite(HapHeaderStart);
    target.close();

    if(toAppend.length != 0)
        return appendAssetInPack(hapFile, toAppend,  basePath);
    return HapHeaderStatus.SUCCESS;
}

ulong getHeaderStart (string hapFile)
{
    if(exists(hapFile))
    {
        ubyte[] hapData = cast(ubyte[])read(hapFile);
        getHeaderStart(hapData);
    }
    return 0;
}
ulong getHeaderStart (ref ubyte[] fileData)
{
    string header = "";
    ulong i;
    for(i = 0; i != HapHeaderEnd.length; i++)
        header~= fileData[$-1-i];

    if(header != HapHeaderEnd)
        return 0;
    
    long z = 0;
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

HapFile[] getHapFiles(ubyte[] hapFile, ulong headerStart)
{
    HapFile[] ret;
    string hap = "";
    for(ulong i = headerStart; i < hapFile.length-HapHeaderStart.length; i++)
        hap~= hapFile[i];
    string[] infos = split(hap,  '\n');

    foreach(info; infos)
    {
        HapFile h;
        string[] temp = split(info, ", ");
        if(temp.length == 0)
            continue;
        h.fileName = temp[0];
        h.startPosition = to!ulong(temp[1]);
        ret~= h;
    }

    for(int i = 0; i < cast(int)ret.length-1; i++)
    {
        const ulong fileLength = ret[i+1].startPosition - ret[i].startPosition;
        ret[i].bin = new ubyte[fileLength];
        memcpy(ret[i].bin.ptr, hapFile.ptr+ret[i].startPosition, fileLength);
    }

    //File length - headerLength
    const ulong headerLength = (hapFile.length - headerStart);
    ret[$-1].bin = new ubyte[hapFile.length - ret[$-1].startPosition - headerLength - HapHeaderEnd.length];
    memcpy(ret[$-1].bin.ptr, hapFile.ptr+ret[$-1].startPosition, ret[$-1].bin.length);

    return ret;

}