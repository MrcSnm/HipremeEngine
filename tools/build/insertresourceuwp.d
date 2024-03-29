/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
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
    ".tiff": "Image",
    ".jpeg": "Image",
    ".jpg" : "Image",
    ".bmp" : "Image",
    ".webp": "Image",
    ///Binary
    ".ttf" : "Document",
    ".dll" : "Document",
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
    ".wav" : "Media",
    ".mp3" : "Media",
    ".ogg" : "Media"
];


enum wordToFind = "</ItemGroup>";
enum copyInit = `
<ItemGroup Label="ResourceCopy">`;
enum copyEnd = "
</ItemGroup>";



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
    return stripProject(res, ".vcxproj", copyInit);
}

bool stripLastResFilter(ref string res)
{
    return stripProject(res, ".vcxproj.filters", copyInit);
}


bool stripProject(ref string res, string fileName, string stripInit, string stripEnd = copyEnd)
{
    long start = res.countUntil(stripInit);
    if(start == -1)
    {
        writeln("Nothing to strip on ",fileName);
        return true;
    }
    //Now advance the next </ItemGroup>
    long end = res[cast(uint)start..$].countUntil(stripEnd);
    if(end == -1)
    {
        writeln("Expected ", stripEnd, " while trying to strip ", fileName, " won't do anything");
        return false;
    }
    res = res[0..cast(uint)start]~res[cast(uint)(end+start+stripEnd.length)..$];
    return true;
}

string getResourceDescriptor(DirEntry e, string targetPath)
{
    string n = "$(ProjectDir)\\UWPResources"~e.name[targetPath.length..$];
    return ("<"~getType(e.name) ~" Include=\""~ n ~ "\"/>");
}

string getResourceFilterDescriptor(DirEntry e, string targetPath)
{
    string type = getType(e.name);
    string filterName = e.name[targetPath.length-"UWPResources\\".length..$];

    long ind = lastIndexOf(filterName, '\\');
    if(ind == -1)
    {
        writeln("Unexpected Error: Resource is a directory.");
        return "";
    }
    filterName = filterName[0..cast(uint)ind];
    if(filterName[0] == '\\')filterName = filterName[1..$];

    string n = "$(ProjectDir)\\UWPResources"~e.name[targetPath.length..$];
    return ("<"~type ~" Include=\""~ n ~ "\">\n\t<Filter>"~filterName~"</Filter>\n</"~type~">");
}

string getFilterName(DirEntry e, string targetPath)
{
    string descriptor = e.name[targetPath.length-"UWPResources\\".length..$];
    long ind = lastIndexOf(descriptor, '\\');
    descriptor = descriptor[0..cast(uint)ind];
    if(descriptor[0] == '\\')descriptor = descriptor[1..$];
    return descriptor;
}
string[] filters = [];

string generateFilterDefinition()
{
    string retVal = "";
    foreach(f; filters)
        retVal~="<Filter Include=\""~f~"\"/>\n";
    return retVal[0..$-1];
}

bool hasFilter(string filterName)
{
    bool has = false;
    for(int i = 0; i < filters.length && !has; i++)
        if(filters[i] == filterName)
            has = true;

    return has;
}


void generateFilters(string filterName)
{
    string[] paths = pathSplitter(filterName).array;


    for(int i =0; i < paths.length; i++)
    {
        string toGenerate = "";
        for(int z = i; z >= 0; z--)
            toGenerate = paths[z]~"\\"~toGenerate;
        if(toGenerate[$-1] == '\\')
            toGenerate = toGenerate[0..$-1];
        if(!hasFilter(toGenerate))
            filters~= toGenerate;
    }
    
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
    if(args[2] != "--strip-only" && !exists(args[2].asAbsolutePath.asNormalizedPath.array))
    {
        writeln(args[2].asAbsolutePath.asNormalizedPath.array, " does not exists.");
        return EXIT_FAILURE;
    }
    
    string vcx = to!string(read(vcxPath));
    string vcxfilter = to!string(read(vcxPath~".filters"));

    if(!stripLastRes(vcx))
        return EXIT_FAILURE;
    if(!stripLastResFilter(vcxfilter))
        return EXIT_FAILURE;

    if(args[2] != "--strip-only")
    {
        long startIndex       = cast(int)vcx.countUntil(wordToFind);
        long startIndexFilter = cast(int)vcxfilter.countUntil(wordToFind);
        if(startIndex == -1 || startIndexFilter == -1)
        {
            writeln("File format is not yet supported.");
            return EXIT_FAILURE;
        }
        startIndex      +=wordToFind.length;
        startIndexFilter+=wordToFind.length;

        string toAppend = copyInit~"\n";
        string toAppendFilter = "";

        string absRes = args[2].asNormalizedPath.array.asAbsolutePath.array.asNormalizedPath.array;
        string targetPath = args[1]~"\\UWPResources";
        if(!exists(targetPath))
            mkdir(targetPath);
        string command = "rdmd copyresources.d "~absRes~" "~targetPath;
        writeln(command);
        auto p = spawnShell(command);
        p.wait;

        foreach(DirEntry e; dirEntries(targetPath, SpanMode.depth).filter!((DirEntry entry) => entry.isFile))
        {
            string resource = getResourceDescriptor(e, targetPath);
            string filter = getResourceFilterDescriptor(e, targetPath);
            if(resource == "")
            {
                writeln("Fatal Error. Stopping resource insertion process.");
                return EXIT_FAILURE;
            }
            string filterDef = getFilterName(e, targetPath);

            if(!hasFilter(filterDef))
                generateFilters(filterDef);

            toAppend~= resource~"\n";
            toAppendFilter ~= filter~"\n";
        }
        toAppend~= copyEnd;
        toAppendFilter = copyInit~"\n"~generateFilterDefinition()~"\n"~toAppendFilter~copyEnd;

        long plusIndex = vcx.countUntil('<');
        if(plusIndex != 0) plusIndex--;

        long plusIndexFilter = vcxfilter.countUntil('<');
        if(plusIndexFilter != 0) plusIndexFilter-=1;

        //Add files to the project
        vcx = 
            vcx[plusIndex..cast(uint)startIndex+plusIndex]~
            toAppend~
            vcx[cast(uint)startIndex+plusIndex..$];

        //Add filters to the project
        vcxfilter = 
            vcxfilter[plusIndexFilter..cast(uint)startIndexFilter+plusIndexFilter]~
            toAppendFilter~
            vcxfilter[cast(uint)startIndexFilter+plusIndexFilter..$];        
    }
    writeln("Writing .vcxproj and .vcxproj.filters");
    std.file.write(vcxPath, vcx);
    std.file.write(vcxPath~".filters", vcxfilter);
    return EXIT_SUCCESS;
}