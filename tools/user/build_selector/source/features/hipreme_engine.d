module features.hipreme_engine;
import commons;
import feature;
import features.git;

private immutable requiredFiles = ["dub.json", "hipreme_engine.sln", "HipremeEngine.code-workspace"];

private bool isValidEnginePath(string path)
{
    return filesExists(path, requiredFiles);
}
private bool isRunningFromDubRun(string enginePath)
{
    return executeShell("cd \""~enginePath~"\" && git status").status != 0;
}

bool installHipremeEngine(ref Terminal t, ref RealTimeConsoleInput input, int targetVer, Download[] contents)
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
        ///Check for existing Hipreme Engine
        import core.runtime;
        import std.algorithm:find;
        hipremeEnginePath = [
            ".", 
            buildNormalizedPath(std.file.getcwd(), "..", "..", ".."), 
            dirName(Runtime.args[0]),
            buildNormalizedPath(dirName(Runtime.args[0]), "..", "..", ".."),
        ].find!((string dir) => isValidEnginePath(dir));
        
        if(hipremeEnginePath.length)
        {
            if(isRunningFromDubRun(hipremeEnginePath))
            {
                t.writelnHighlighted(
                    "HipremeEngine is present, but dub does not support git repositories containing submodules.\n",
                    "\tHipremeEngine needs to be cloned.");
                goto clone;
            }
            t.writelnHighlighted("Using engine path found at directory '"~hipremeEnginePath~"'");
        }
        else
        {
            clone: bool canClone = pollForExecutionPermission(t, input, "HipremeEngine path wasn't found in configs. Do you want to clone the engine?");
            if(canClone)
            {
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
    }
    configs["hipremeEnginePath"] = hipremeEnginePath;
    updateConfigFile();
    loadSubmodules(t, input);
    return true;
}


Feature HipremeEngineFeature;
static this()
{
    HipremeEngineFeature = Feature(
        "Hipreme Engine",
        "The engine for D game development",
        ExistenceChecker(["hipremeEnginePath"]),
        Installation(null, &installHipremeEngine),
        (ref Terminal){environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;},
        VersionRange(),
        [GitFeature]
    );
}
