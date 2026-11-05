module featurelib.features.wsl;

import featurelib;
import std.process : executeShell, spawnShell;
import std.system;

private Feature WSLFeature;

Task!(getWslSourceImpl) getWslSource;
Task!(wslExecImpl) wslExec;

string getWslSourceImpl(Feature*[] dependencies, ref Terminal t, ConsoleInput input)
{
    return executeShell(`wsl echo -n $(wslpath "%USERPROFILE%")/.bashrc`).output;
}

int wslExecImpl(Feature*[] dependencies, ref Terminal t, ConsoleInput input, scope string[] commands...)
{
    import std.array : join;

    string fileToSource = getWslSource.execute(t, input);
    t.writelnHighlighted("WSL Execution: ", join(commands, " "));
    return t.wait(spawnShell("wsl source " ~ fileToSource ~ " ^&^& " ~ join(commands, " ")));
}

bool wslExists(ref Terminal t, TargetVersion v, out ExistenceStatus where)
{
    if (findProgramPath("wsl") == null)
    {
        t.writelnError("Please, run a command prompt with administrator access and run `wsl --install` before developing for PSV on Windows.");
        return false;
    }
    return true;
}

void initialize()
{
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
