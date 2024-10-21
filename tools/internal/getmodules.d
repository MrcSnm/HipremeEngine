import std.file;
import std.path;
import core.stdc.stdlib;
import std.stdio;
import std.array:replace;

/** 
 * Simple utility file to get the source files used for a game project in Hipreme Engine.
 *  This utility may be replaced in the future to prefer dub describe --data=source-files
 *  
 */
int main(string[] args)
{
    if(args.length != 3)
    {
        writeln("Usage: rdmd gemodules inputPath outputPath");
        return EXIT_FAILURE;
    }
    string inputPath = args[1];
    string outputPath = args[2];

    if(!exists(inputPath))
    {
        writeln("Input path '",inputPath," does not exists");
        return EXIT_FAILURE;
    }
    if(!isDir(inputPath))
    {
        writeln("Input path '",inputPath,"' is not a directory");
        return EXIT_FAILURE;
    }
    if(exists(outputPath) && isDir(outputPath))
    {
        writeln("Invalid output path '",outputPath,"', the output path is a directory");
        return EXIT_FAILURE;
    }

    string output;
    foreach(string file; dirEntries(inputPath, "*.d", SpanMode.breadth))
    {
        if(output != "")
            output~="\n";
        //Remove .d, change / or \ to .

        output~= file[inputPath.length..$-2].replace('/', '.').replace('\\', '.');
    }

    string outDir = dirName(outputPath);
    if(!std.file.exists(outDir))
        std.file.mkdirRecurse(outDir);

    std.file.write(outputPath, output);
    return EXIT_SUCCESS;
}