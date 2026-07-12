module features.wsl;
import commons;
import feature;

Feature WSLFeature;

Task!(getWslSourceImpl) getWslSource;
Task!(wslExecImpl) wslExec;

string getWslSourceImpl()
{
    return executeShell("wsl echo -n $(wslpath \"%USERPROFILE%\")/.bashrc").output;
}


int wslExecImpl(ref T terminal, scope string[] commands...)
{
    string fileToSource = getWslSource();
    import std.array:join;
    t.writelnHighlighted("WSL Execution: "~commands);
    return t.wait(spawnShell("wsl source "~fileToSource~" ^&^& "~join(commands, " ")));
}


bool wslExists(ref Terminal t, TargetVersion v, out ExistenceStatus where)
{
    if(findProgramPath("wsl") == null)
    {
        t.writelnError("Please, run a command prompt with administrator access and run `wsl --install` before developing for PSV on Windows.");
        return false;
    }
    return true;
}

void initialize()
{
    import std.conv:to;
    WSLFeature = Feature(
        "Windows WSL",
        "Required for being able to develop on Windows simulating Linux",
        ExistenceChecker(null, null, toDelegate(&wslExists)),
        requiredOn: [OS.win32, OS.win64]
    );
}
void start()
{
    getWslSource = Task!(getWslSourceImpl)([&WSLFeature]);
    wslExec = Task!(wslExecImpl)([&WSLFeature]);
}