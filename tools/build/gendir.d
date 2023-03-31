import std.stdio;
import std.path:relativePath, buildPath, absolutePath, baseName;
import std.conv:to;
import std.array:appender;
import std.file:dirEntries, DirEntry, SpanMode, exists, write;
import core.stdc.stdlib;

enum OUTPUT_NAME = "directories.json";

///Hipreme Engine that generates a JSON containing the assets directory.
int main(string[] args)
{
    if(args.length < 3)
    {
        writeln("Usage: rdmd gendir.d inputDirectory outputDir");
        return EXIT_FAILURE;
    }
    auto output = appender!string;
    string inputDir = absolutePath(args[1]);
    output~= "{\"";
    output~= inputDir.baseName;
    output~= "\" : ";
    genJson(inputDir, output);
    output~= "}";


    if(exists(args[2]))
        write(buildPath(args[2], OUTPUT_NAME), output[]);

    return EXIT_SUCCESS;
}

void genJson(T)(string startDir, ref T output)
{
    bool first = true;
    output~= "{";
    foreach(DirEntry e; dirEntries(startDir, SpanMode.shallow))
    {
        if(!first)
            output~=",";
        first = false;
        output~= '"';
        output~= e.name.relativePath(startDir);
        output~= `": `;
        if(e.isDir)
            genJson(e.name, output);
        else
        {
            output~= e.size.to!string;
        }
    }
    output~= "}";
}