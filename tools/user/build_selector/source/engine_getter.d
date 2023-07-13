module engine_getter;
import commons;


private immutable requiredFiles = ["dub.json", "hipreme_engine.sln", "HipremeEngine.code-workspace"];

private bool isValidEnginePath(string path)
{
    return filesExists(path, requiredFiles);
}

bool setupEngine(ref Terminal t, ref RealTimeConsoleInput input)
{
    if(!("hipremeEnginePath" in configs))
    {
	    import std.array:replace;
        string hipremeEnginePath;
        if("HIPREME_ENGINE" in environment)
        {
            hipremeEnginePath = environment["HIPREME_ENGINE"];
            if(hipremeEnginePath[0] == '"' && hipremeEnginePath[$-1] == '"') 
                hipremeEnginePath = hipremeEnginePath[1..$-1];
            t.writelnHighlighted("Using existing environment variable 'HIPREME_ENGINE' for hipremeEnginePath");
        }
        else 
        {
            clone: bool canClone = pollForExecutionPermission(t, input, "HipremeEngine path wasn't found in configs. Do you want to clone the engine?");
            if(canClone)
            {
                if(!hasGit)
                {
                    if(!installGit(t, input))
                    {
                        t.writelnError("Could not install Git.");
                        return false;
                    }
                }
                if(wait(spawnShell(getGitExec~" clone "~hipremeEngineRepo)) != 0)
                {
                    t.writelnError("Could not clone HipremeEngine on repo ", hipremeEngineRepo);
                    return false;
                }
                hipremeEnginePath = buildNormalizedPath(std.file.getcwd(), "HipremeEngine");
            }
            else 
            {
                hipremeEnginePath = getValidPath(t, "HipremeEngine Path: ");
                if(!isValidEnginePath(hipremeEnginePath))
                {
                    import std.string:join;
                    t.writelnHighlighted("Path is not valid. HipremeEngine path should have: \n\t"~requiredFiles.join("\n\t"));
                    goto clone;
                }
            }
        }
        configs["hipremeEnginePath"] = hipremeEnginePath;
        updateConfigFile();
    }
    return true;
}