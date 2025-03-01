module tools.copyresources;
import commons;
import std.string;
import std.conv:to;
import std.json;
import std.file;
import std.path;


struct Cache
{
    DirEntry entry;
    bool valid;
}
struct AssetCache
{
    string timeModified;
    string timeCopied;
}

string getCachePath(string workingDir, string from, string toWhere)
{
    string temp = buildNormalizedPath(workingDir, from, toWhere);
    temp = to!string(hashOf(temp));
    return ".cache/"~temp~".json";
}
bool cacheExists(string workingDir, string from, string toWhere)
{
    return exists(getCachePath(workingDir,from,toWhere));
}

string getCacheName(string fileName)
{
    char[] ret = fileName.dup;
    for(int i= 0; i < ret.length;i++)
    {
        if(fileName[i] == '\\')
            ret[i] = '/';
    }
    return cast(string)ret;
}

bool isCacheValid = true;

AssetCache[string] cache;
void readCacheFile(string workingDir, string from, string toWhere)
{
    if(!cacheExists(workingDir, from, toWhere))
        return;
    JSONValue json = parseJSON(readText(getCachePath(workingDir, from, toWhere)));
    
    foreach (string k, JSONValue v; json.object)
    {
        JSONValue arr = v.array;
        cache[k] = AssetCache(arr[0].str, arr[1].str);
    }
}

void writeCacheFile(string workingDir, string from, string toWhere)
{
    string toWrite = "{";
    foreach(k, v; cache)
    {
        toWrite~= "\""~k~"\": [\""~ v.timeModified~"\", \""~v.timeCopied~"\"],";
    }
    if(!exists(".cache"))
        mkdir(".cache");

    std.file.write(getCachePath(workingDir,from,toWhere), toWrite[0..$-1]~"}");
}

bool isUpToDate(DirEntry which)
{
    string* time = cast(string*)(which.name in cache);
    if(time is null)
        return false;
    return *time == which.timeLastModified().toSimpleString();
}


/**
*   Receives from and where
*/
void copyResources(ref Terminal t, string inputPath, string outputPath, bool clean)
{
    string workingDir = getcwd();
    //Populate cache with current content
    readCacheFile(workingDir, inputPath, outputPath);
    if(clean)
    {
        t.writeln("Cleaning target path: ", outputPath);
        if(exists(outputPath))
            rmdirRecurse(outputPath);
    }
    if(!exists(outputPath))
        mkdirRecurse(outputPath);

    //Copy loop
    uint copyCount = 0;
    foreach(DirEntry e; dirEntries(inputPath, SpanMode.depth))
    {
        if(e.isDir)
            continue;
        Cache c = Cache(e, isUpToDate(e));
        //Check cache validity
        //Make path relative to where it is started, so it is possible to create same folder structure
        string relative = relativePath(c.entry.name, inputPath);
        
        //Join target path with the source name
        string name = buildNormalizedPath(outputPath, relative);

        bool willCopy = false;

        auto cacheName = getCacheName(relative);
        AssetCache* temp = (cacheName in cache);
        if(temp is null)
        {
            cache[cacheName] = AssetCache(c.entry.timeLastModified.toSimpleString, "");
            temp = (cacheName in cache);
        }
        else
        {
            willCopy = temp.timeModified != c.entry.timeLastModified.toSimpleString;
            temp.timeModified = c.entry.timeLastModified.toSimpleString;
        }

        //If the target exists, check its time copied, if it is the same on the cache, willCopy = false
        if(exists(name))
        {
            if(!willCopy)
                willCopy = (temp.timeCopied == "" || temp.timeCopied != e.timeLastModified.toSimpleString);
        }
        //Check if the path where the name is exists, for creating a folder for it
        else
        {
            long ind = lastIndexOf(name, dirSeparator);
            string namePath = name[0..ind];
            if(!exists(namePath))
                mkdirRecurse(namePath);
            willCopy = true;
        }
        
        if(willCopy)
        {
            copyCount++;
            t.writeln(c.entry.name, " -> ", name);
            copy(c.entry.name, name);
            cache[cacheName].timeCopied = DirEntry(name).timeLastModified.toSimpleString;
        }
    }
    if(copyCount != 0)
    {
        writeCacheFile(workingDir, inputPath, outputPath);
        t.writeln("CopyResources: Copied ", copyCount, " files");
    }
    else
    {
        t.writeln("CopyResources: Target folder '"~outputPath~"' is up to date");
    }
}