import std.stdio;
import std.range;
import std.file;

bool assertDirectoryExistence(string path)
{
    if(!exists(path))
    {
        writeln(path, " does not exists ");
        return false;
    }
    else if(!isDir(path))
    {
        writeln(path, " is not a directory");
        return false;
    }
    return true;
}

int main(string[] args)
{
    if(args.length < 3)
    {
        writeln("Usage: dirlistgen path/to/to/recurse/dirs path/to/dir/list/output");
        return 1;
    }
    string inputPath = args[1];
    string outputPath = args[2];

    if(!assertDirectoryExistence(inputPath))
    {
        writeln("Error on input path");
        return 1;
    }

    string[] dirs;
    foreach(file; dirEntries(inputPath, SpanMode.breadth))
    {
        dirs~= file;
    }
    
    std.file.write(outputPath, dirs.join('\n'));


    return 0;
}
