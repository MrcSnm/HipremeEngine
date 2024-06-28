module tools.releasegame;

import commons;
import std.string;
import std.array;
import std.path;
import std.file;

enum string[] availableSourceFolders = ["source", "src", "scripts"];
enum string[] ignoreExtensions = [".dll", ".lib", ".so", ".obj", ".pdb", ".gitkeep"];
enum string[] ignoreFolders = [".dub", ".git", ".history"];


string[] getGameValidFiles(string input)
{
    string[] validFiles;
    FileLoop: foreach(DirEntry e; dirEntries(input, SpanMode.shallow))
    {
        foreach(folder; ignoreFolders)
        {
            if(e.name.indexOf(folder) != -1)
                continue FileLoop;
        }
        validFiles~= e.name;
    }
    return validFiles;
}

bool shouldFileSkip(string fileName)
{
    string ext = fileName.extension;

    foreach(x; ignoreExtensions)
    {
        if(ext.indexOf(x) != -1)
            return true;
    }
    return false;
}

string outputPath = "release_game";


void releaseGame(ref Terminal t, string gamePath, string outputFolder, bool verbose)
{
    t.writeln("Creating directory: ", outputFolder);
    mkdirRecurse(outputFolder);

    string[] validFiles = getGameValidFiles(gamePath);
    foreach(f; validFiles)
    {
        if(isDir(f))
        {
            t.writeln("Copying contents from folder ", f);
            foreach(DirEntry e; dirEntries(f, SpanMode.breadth))
            {
                string relativizedName = relativePath(e.name, gamePath);
                string outputBasedOnGame = outputFolder~relativizedName;
                if(isDir(e.name))
                {
                    if(!exists(outputBasedOnGame))
                    {
                        if(verbose)
                            t.writeln("[FOLDER_CONTENT] MKDIR ",outputBasedOnGame);
                        mkdirRecurse(outputBasedOnGame);
                    }
                }
                else 
                {
                    if(!exists(dirName(outputBasedOnGame)))
                    {
                        if(verbose)
                            t.writeln("[FOLDER_CONTENT] MKDIR ",outputBasedOnGame);
                        mkdirRecurse(dirName(outputBasedOnGame));
                    }
                    if(verbose)
                        t.writeln("[FOLDER_CONTENT] COPY[",e.name,"] ---> ", outputBasedOnGame);
                    copy(e.name, outputBasedOnGame);
                }
            }
        }
        else if(!shouldFileSkip(f))
        {
            string relativizedName = relativePath(f, gamePath);
            if(verbose)
                t.writeln("Copying [",f,"] -> ", outputFolder~relativizedName);
            copy(f, outputFolder~relativizedName);
        }
    }
}
