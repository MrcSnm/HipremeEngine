/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module tools.insert_resources_uwp;
import std.conv:to;
import std.process;
import std.string;
import std.algorithm:countUntil, filter;
import std.file;
import std.array;
import commons;

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


enum specialLabel = "<ItemGroup Label=\"ResourceCopy\">";
enum wordToFind = "</ItemGroup>";


/**
 *
 * Params:
 *   t = Terminal for printing
 *   fileName = The file name
 * Returns: The type from the vcxItemTypes
 */
string getType(ref Terminal t, string fileName)
{
    string type = fileName.extension;
    string* uwpType = (type in vcxItemTypes);
    if(uwpType == null)
    {
        t.writelnHighlighted("File named ", fileName, " is an unrecognized type, returning as None");
        return "None";
    }
    return *uwpType;
}


bool stripProject(ref Terminal t, ref string res, string fileName)
{
    long start = res.countUntil(specialLabel);
    if(start == -1)
        return true;

    size_t itemGroupDepth = 0;
    for(size_t i = start+specialLabel.length; i < res.length; i++)
    {
        size_t nextItemGroup = res[i..$].countUntil("<ItemGroup>");
        size_t nextItemGroupEnd = res[i..$].countUntil("</ItemGroup>");


        if(nextItemGroupEnd == -1 || nextItemGroup == -1)
            throw new Exception("Could not find tokens on file "~fileName);

        if(nextItemGroupEnd < nextItemGroup)
        {
            i+= nextItemGroupEnd + "</ItemGroup>".length;
            if(itemGroupDepth == 0)
            {
                res = res[0..cast(size_t)start] ~ res[i..$];
                return true;
            }
            itemGroupDepth--;
        }
        else if(nextItemGroup < nextItemGroupEnd)
        {
            i+= nextItemGroup + "<ItemGroup>".length;
            itemGroupDepth++;
        }
    }
    return false;
}

string getResourceDescriptor(ref Terminal t, DirEntry e, string targetPath)
{
    string n = "$(ProjectDir)\\UWPResources"~e.name[targetPath.length..$];
    return ("<"~getType(t, e.name) ~" Include=\""~ n ~ "\"/>");
}

string getResourceFilterDescriptor(ref Terminal t, DirEntry e, string targetPath)
{
    string type = getType(t, e.name);
    string filterName = e.name[targetPath.length-"UWPResources\\".length..$];

    long ind = lastIndexOf(filterName, '\\');
    if(ind == -1)
    {
        t.writelnError("Unexpected Error: Resource is a directory.");
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


string generateFilterDefinition(string[] filters)
{
    string retVal = "";
    foreach(f; filters)
        retVal~="<Filter Include=\""~f~"\"/>\n";
    return retVal[0..$-1];
}

bool hasFilter(string filterName, const string[] filters)
{
    for(int i = 0; i < filters.length; i++)
        if(filters[i] == filterName)
            return true;
    return false;
}


void generateFilters(string filterName, ref string[] filters)
{
    string[] paths = pathSplitter(filterName).array;
    for(int i = 0; i < paths.length; i++)
    {
        string toGenerate = "";
        for(int z = i; z >= 0; z--)
            toGenerate = paths[z]~"\\"~toGenerate;
        if(toGenerate[$-1] == '\\')
            toGenerate = toGenerate[0..$-1];
        if(!hasFilter(toGenerate, filters))
            filters~= toGenerate;
    }
}


bool stripUWPResources(ref Terminal t, ref string vcx, ref string vcxfilter)
{
    if(!stripProject(t, vcx, ".vcxproj"))
    {
        t.writelnError(`Could not strip last resource. `);
        return false;
    }
    if(!stripProject(t, vcxfilter,".vcxproj.filters"))
    {
        t.writelnError(`Could not strip last resource filters.`);
        return false;
    }
    return true;
}

bool insertUWPResources(ref Terminal t, string uwpVcxProjPath, string assetsToImport)
{
    import std.path;
    import tools.copyresources;
    string vcxPath = buildNormalizedPath(uwpVcxProjPath, baseName(uwpVcxProjPath)~".vcxproj");
    if(!exists(vcxPath))
    {
        t.writelnError(vcxPath, " does not exists.");
        return false;
    }
    if(!exists(assetsToImport))
    {
        t.writelnError(assetsToImport, " does not exists. ");
        return false;
    }
    string targetPath = buildNormalizedPath(uwpVcxProjPath, "UWPResources");
    copyResources(t, assetsToImport, targetPath, false);

    string vcx = to!string(readText(vcxPath));
    string vcxfilter = to!string(readText(vcxPath~".filters"));


    if(!stripUWPResources(t, vcx, vcxfilter))
    {
        t.writelnError("Could not strip UWPResources '"~specialLabel~'\'');
        return false;
    }

    long startIndex       = cast(int)vcx.countUntil(wordToFind);
    long startIndexFilter = cast(int)vcxfilter.countUntil(wordToFind);
    if(startIndex == -1 || startIndexFilter == -1)
    {
        t.writelnError("File format is not yet supported.");
        return false;
    }

    startIndex      +=wordToFind.length;
    startIndexFilter+=wordToFind.length;


    string toAppend = specialLabel;
    string toAppendFilter = "";

    string[] filters;


    foreach(DirEntry e; dirEntries(targetPath, SpanMode.depth).filter!((DirEntry entry) => entry.isFile))
    {
        string resource = getResourceDescriptor(t, e, targetPath);
        string filter = getResourceFilterDescriptor(t, e, targetPath);
        if(resource == "")
        {
            t.writelnError("Fatal Error. Stopping resource insertion process.");
            return false;
        }
        string filterDef = getFilterName(e, targetPath);

        if(!hasFilter(filterDef, filters))
            generateFilters(filterDef, filters);

        toAppend~= resource~"\n";
        toAppendFilter ~= filter~"\n";
    }

    toAppend~= "</ItemGroup>";
    toAppendFilter = specialLabel~generateFilterDefinition(filters)~"\n"~toAppendFilter~"</ItemGroup>";

    long plusIndex = vcx.countUntil('<');
    if(plusIndex != 0) plusIndex--;

    long plusIndexFilter = vcxfilter.countUntil('<');
    if(plusIndexFilter != 0) plusIndexFilter--;

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


    t.writelnSuccess("Writing .vcxproj and .vcxproj.filters");
    std.file.write(vcxPath, vcx);
    std.file.write(vcxPath~".filters", vcxfilter);

    return true;
}