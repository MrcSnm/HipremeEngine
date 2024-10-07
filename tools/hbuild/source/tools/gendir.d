module tools.gendir;
import std.path:relativePath, buildPath, absolutePath, baseName;
import std.conv:to;
import std.array:appender;
static import std.file;

enum OUTPUT_NAME = "directories.json";

///Hipreme Engine that generates a JSON containing the assets directory.
void generateDirectoriesJSON(string inputDirectory, string outputDirectory)
{
    auto output = appender!string;
    string inputDir = absolutePath(inputDirectory);
    output~= "{\"";
    output~= inputDir.baseName;
    output~= "\" : ";
    genJson(inputDir, output);
    output~= "}";


    if(!std.file.exists(outputDirectory))
        std.file.mkdirRecurse(outputDirectory);

    std.file.write(buildPath(outputDirectory, OUTPUT_NAME), output[]);
}

void genJson(T)(string startDir, ref T output)
{
    bool first = true;
    output~= "{";
    if(std.file.exists(startDir)) foreach(std.file.DirEntry e; std.file.dirEntries(startDir, std.file.SpanMode.shallow))
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