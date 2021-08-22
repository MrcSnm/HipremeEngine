import core.stdc.stdlib;
import std.string;
import std.conv:to;
import std.json;
import std.array;
import std.stdio;
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
    string temp = (workingDir~from~toWhere);
    temp = to!string(hashOf(temp));
    return ".cache/"~temp~".json";
}
bool cacheExists(string workingDir, string from, string toWhere)
{
    return exists(getCachePath(workingDir,from,toWhere));
}

string getCacheName(string fileName)
{
    string ret;
    for(int i= 0; i < fileName.length;i++)
    {
        if(fileName[i] == '\\' || fileName[i] == '/')
            ret~= "$_$";
        else
            ret~=fileName[i];
    }
    return ret;
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

bool willClear;

/**
*   Receives from and where
*/
int main(string[] args)
{
    string workingDir = getcwd();
    if(args.length < 3)
    {
        writeln(`Usage: rdmd copyresources.d <from> <where> [option]
Options:
    --clean -> Clears the target folder and copy everything again`);
        return EXIT_SUCCESS;
    }
    if(args.length > 3) willClear = args[3] == "--clean";

    //Populate cache with current content
    readCacheFile(workingDir, args[1], args[2]);
    string from, toWhere;
    //Normalize from
    if(isAbsolute(args[1]))
        from = asNormalizedPath(args[1]).array;
    else
        from = asNormalizedPath(workingDir~"/"~args[1]).array;
    //Normalize to where
    if(isAbsolute(args[2]))
        toWhere = asNormalizedPath(args[2]).array;
    else
        toWhere = asNormalizedPath(workingDir~"/"~args[2]).array;

    if(!exists(from))
    {
        writeln("Source path does not exists");
        return EXIT_FAILURE;
    }
    if(!exists(toWhere))
    {
        writeln("Target path does not exists");
        return EXIT_FAILURE;
    }
    if(!isDir(from))
    {
        writeln("Source path is not a directory");
        return EXIT_FAILURE;
    }
    if(!isDir(toWhere))
    {
        writeln("Target path is not a directory");
        return EXIT_FAILURE;
    }

    //Check cache validity
    Cache[] mainEntries;
    foreach(DirEntry e; dirEntries(from, SpanMode.depth))
    {
        Cache c;
        if(e.isDir)
            continue;
        c = Cache(e, isUpToDate(e));
        mainEntries~=c;
    }
    if(willClear)
    {
        writeln("Cleaning target path: ", toWhere);
        if(exists(toWhere))
            rmdirRecurse(toWhere);
        mkdir(toWhere);
    }
    //Copy loop
    uint copyQuant = 0;
    foreach(c; mainEntries)
    {
        //Make path relative to where it is started, so it is possible to create same folder structure
        string relative = c.entry.name[from.length..$];
        
        //Join target path with the source name
        string name = asNormalizedPath(toWhere~"/"~relative).array;
        bool willCopy = false;

        AssetCache* temp = (getCacheName(c.entry.name) in cache);
        if(temp is null)
        {
            cache[getCacheName(c.entry.name)] = AssetCache(c.entry.timeLastModified.toSimpleString, "");
            temp = (getCacheName(c.entry.name) in cache);
        }
        else
        {
            willCopy = temp.timeModified != c.entry.timeLastModified.toSimpleString;
            temp.timeModified = c.entry.timeLastModified.toSimpleString;
        }

        //If the target exists, check its time copied, if it is the same on the cache, willCopy = false
        if(exists(name))
        {
            DirEntry e = DirEntry(name);
            if(!willCopy)
                willCopy = (temp.timeCopied == "" || temp.timeCopied != e.timeLastModified.toSimpleString);
        }
        //Check if the path where the name is exists, for creating a folder for it
        else
        {
            int ind = lastIndexOf(name, '/');
            if(ind == -1)
                ind = lastIndexOf(name, '\\');
            string namePath = name[0..ind];
            if(!exists(namePath))
                mkdirRecurse(namePath);
            willCopy = true;
        }
        
        if(willCopy)
        {
            copyQuant++;
            writeln(c.entry.name, " -> ", name);
            copy(c.entry.name, name);
            cache[getCacheName(c.entry.name)].timeCopied = DirEntry(name).timeLastModified.toSimpleString;
        }
    }
    if(copyQuant != 0)
    {
        writeCacheFile(workingDir, args[1], args[2]);
        writeln("CopyResources: Copied ", copyQuant, " files");
    }
    else
    {
        writeln("CopyResources: Target folder '"~toWhere~"' is up to date");
    }

    return EXIT_SUCCESS;
}