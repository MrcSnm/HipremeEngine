import std.stdio;
import std.conv:to;
import std.process;
import std.string;
import std.algorithm:countUntil, filter;
import std.file;
import std.path;
import std.array;
import core.stdc.stdlib;

enum vcxItemTypes = 
[
    ///Images
    ".png" : "Image",
    ".jpeg": "Image",
    ".jpg" : "Image",
    ".bmp" : "Image",
    ".webp": "Image",
    ///Binary
    ".ttf" : "None",
    ".dll" : "None",
    ///Text
    ".txt" : "Text",
    ".fnt" : "Text",
    ".conf": "Text",
    ".ini" : "Text",
    ".json": "Text",
    ".tsx" : "Text",
    ".tmx" : "Text",
    ".xml" : "Text",
    ///Audio
    ".wav" : "Audio",
    ".mp3" : "Audio",
    ".ogg" : "Audio"
];


enum wordToFind = "</ItemGroup>";

enum copyInit = "<ItemGroup Label=\"ResourceCopyInit\">";
enum copyEnd  = "</ItemGroup><ItemGroup Label=\"ResourceCopyEnd\"></ItemGroup>";

string getType(string fileName)
{
    string type = fileName[fileName.lastIndexOf(".")..$];
    string* uwpType = (type in vcxItemTypes);
    if(uwpType == null)
    {
        writeln("File named ", fileName, " is an unrecognized type, returning as None");
        return "None";
    }
    return *uwpType;
}

bool stripLastRes(ref string res)
{
    long start = res.countUntil(copyInit);
    if(start == -1)
    {
        writeln("Nothing to strip");
        return true;
    }
    long end = res[cast(uint)start..$].countUntil(copyEnd);
    if(end == -1)
    {
        writeln("Malformed input. Won't do anything with vcxproj");
        return false;
    }

    end+=start + copyEnd.length;
    writeln("Stripping last ResourceCopy...");
    res = res[0..cast(uint)start]~res[cast(uint)end..$];
    return true;
}

int main(string[] args)
{
    if(args.length < 3)
    {
        writeln("Usage:
<uwp_vcxproj_path> <assets_to_import> : Adds resources to the target vcxproj
<uwp_vcxproj_path> --strip-only : Remove everything that was added by resource insert");
        return EXIT_SUCCESS;
    }
    string[] path = pathSplitter(args[1]).array;
    string vcxPath = args[1] ~ "\\" ~ path[$-1]~".vcxproj";
    if(!exists(vcxPath))
    {
        writeln(vcxPath~" does not exists.");
        return EXIT_FAILURE;
    }
    
    string vcx = to!string(read(vcxPath));
    if(!stripLastRes(vcx))
        return EXIT_FAILURE;
    if(args[2] != "--strip-only")
    {
        long startIndex = vcx.countUntil(wordToFind);
        if(startIndex == -1)
        {
            writeln("File format is not yet supported.");
            return EXIT_FAILURE;
        }
        startIndex+=wordToFind.length;
        string toAppend = copyInit~"\n";

        string absRes = args[2].asNormalizedPath.array.asAbsolutePath.array.asNormalizedPath.array;
        string targetPath = args[1]~"\\..\\UWPResources";
        if(!exists(targetPath))
            mkdir(targetPath);
        string command = "rdmd copyresources.d "~absRes~" "~targetPath;
        writeln(command);
        auto p = spawnShell(command);
        p.wait;

        foreach(DirEntry e; dirEntries(targetPath, SpanMode.depth).filter!((DirEntry entry) => entry.isFile))
        {
            string n = "$(ProjectPath)..\\UWPResources"~e.name[targetPath.length..$];
            toAppend~=("<"~getType(e.name) ~" Include=\""~ n ~ "\"/>"~"\n");
        }
        toAppend~= copyEnd;

        int plusIndex = 0;
        while(vcx[plusIndex++] != '<'){}
        plusIndex-=1;
        vcx = vcx[plusIndex..cast(uint)startIndex+plusIndex]~toAppend~vcx[cast(uint)startIndex+plusIndex..$];
    }

    std.file.write(vcxPath, vcx);
    return EXIT_SUCCESS;
}