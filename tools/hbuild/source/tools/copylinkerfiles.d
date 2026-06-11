module tools.copylinkerfiles;

import std.json;
import std.string;
import std.path;
import std.algorithm;
static import std.file;

void copyLinkerFiles(const string[] libraries, string outputPath)
{
    string libIncludes = buildNormalizedPath(outputPath, "..", "libIncludes.json");
    JSONValue includes = parseJSON("{}");

    if(std.file.exists(libIncludes))
    {
        includes = parseJSON(cast(string)std.file.read(libIncludes));
        foreach(key, value; includes.object)
            includes[key] = false;
    }
    foreach(library; libraries)
        includes[library.baseName] = true;
    std.file.write(libIncludes, includes.toPrettyString());

    std.file.mkdirRecurse(outputPath);
    copyFiles(libraries, outputPath);
}

void copyLinkerFilesAsTxt(const string[] libraries, string outputPath)
{
    import std.algorithm.mutation;
    import std.algorithm.iteration:joiner;
    import std.path;

    string libIncludes = buildNormalizedPath(outputPath, "..", "libIncludes.txt");
    string txt = libraries.map!(lib => "-l"~lib.baseName[3..$].setExtension("")).join(" ");
    
    std.file.write(libIncludes, txt);
    copyFiles(libraries, outputPath);

}

private void copyFiles(const string[] libraries, string outputPath)
{
    foreach(l; libraries)
    {
        string n = baseName(l);
        string newPath = buildPath(outputPath, n);
        if(newPath == l)
            continue;
        std.file.copy(l, newPath);
    }
}