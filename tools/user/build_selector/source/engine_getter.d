module engine_getter;
import commons;

bool setupEngine(ref Terminal t, ref RealTimeConsoleInput input)
{
    if(!("hipremeEnginePath" in configs))
    {
	    import std.array:replace;
        string hipremeEnginePath;
        if("HIPREME_ENGINE" in environment)
        {
            hipremeEnginePath = environment["HIPREME_ENGINE"];
            t.writelnHighlighted("Using existing environment variable 'HIPREME_ENGINE' for hipremeEnginePath");
        }
        else if(!pollForExecutionPermission(t, input, "HipremeEngine path wasn't found in configs. Do you want to clone the engine?"))
        {
            hipremeEnginePath = getValidPath(t, "HipremeEngine Path: ");
            if(!hipremeEnginePath)
                return false;
        }
        if(!hasGit)
        {
            if(!installGit(t, input))
            {
                t.writelnError("Could not install Git.");
                return false;
            }
            if(wait(spawnShell(getGitExec~" clone "~hipremeEngineRepo)) != 0)
            {
                t.writelnError("Could not clone HipremeEngine on repo ", hipremeEngineRepo);
                return false;
            }
            hipremeEnginePath = buildNormalizedPath(std.file.getcwd(), "HipremeEngine");
        }
	    hipremeEnginePath = hipremeEnginePath.replace("\\", "\\\\");
        configs["hipremeEnginePath"] = hipremeEnginePath;
        updateConfigFile();
    }
    return true;
}