import std.stdio;
import std.algorithm;
import std.string;
import std.array;
import std.path;
import std.file;
import core.stdc.stdlib:EXIT_FAILURE, EXIT_SUCCESS;


enum string[] availableSourceFolders = ["source", "src", "scripts"];
enum string[] ignoreExtensions = [".dll", ".lib", ".so"];
enum string[] ignoreFolders = [".dub"];

bool shouldFileSkip(string fileName)
{
    string ext = fileName.extension;
    return (ignoreExtensions.countUntil(ext) == -1 &&
            ignoreFolders.countUntil(fileName) == -1);
}


string findSourceFolder(string gamePath)
{
    string srcPath;
    foreach(s; availableSourceFolders)
    {
        string temp = buildPath(gamePath, s);
        if(isFile(temp))
        {
            writeln("Aborting releasegame.d.\n The file name '", temp,
            "' uses a reserved folder name (", s, ")");
            return null;
        }
        if(exists(temp))
        {
            srcPath = temp;
            break;
        }
    }
    if(srcPath == null)
    {
        writeln("No source folder was found at "~gamePath~
        "\n Your game path should contain one of those folders: \n\t",
        availableSourceFolders.join("\n\t"));
    }

    return asNormalizedPath(srcPath).array;
}

string outputPath = "release_game";


// void copyWithNewModuleName(string relativizedName,  string absPath)
// {
//     string fileContent = readText(absPath);
//     long moduleIndex = countUntil(fileContent, "module ");

//     string moduleName = relativizedName.stripExtension.pathSplitter.join(".");
    
//     string outputFilePath = buildNormalizedPath(outputPath, relativizedName);
//     string moduleDef = "module "~outputPath~"."~moduleName~";\n";
//     if(moduleIndex == -1)
//         std.file.write(outputFilePath, moduleDef~fileContent);
//     else
//     {
//         long moduleIndexEnd = fileContent[cast(uint)moduleIndex..$].countUntil(";")+1;
//         std.file.write(outputFilePath,
//         fileContent[0..cast(uint)moduleIndex]
//         ~moduleDef~fileContent[cast(uint)moduleIndexEnd..$]); 
//     }
// }

int main(string[] args)
{
    if(args.length < 2)
    {
        writeln("releasegame.d must receive a path in which the game is located");
        return EXIT_FAILURE;
    }
    string gamePath = args[1];
    if(!isDir(gamePath))
    {
        writeln("releasegame.d expects a directory");
        return EXIT_FAILURE;
    }
    if(!exists(gamePath))
    {
        writeln("releasegame.d game path '", gamePath, " does not exists");
        return EXIT_FAILURE;
    }
    mkdirRecurse(outputPath);

    foreach(DirEntry d; dirEntries(gamePath, SpanMode.depth))
    {
        string relativizedName = d.name[srcPath.length+1..$];
        string absPath = d.name.asAbsolutePath.array;
        

        if(isDir(absPath))
            mkdirRecurse(absPath);
        else
            // copyWithNewModuleName(relativizedName, absPath);
            copy(absPath, relativizedName);
    }
    return EXIT_SUCCESS;
}
