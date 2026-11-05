module featurelib.util;

import std.file;
import std.path : buildNormalizedPath;
import std.process;
import featurelib.terminal : Terminal;

version (ARM) enum isARM = true;
else version (AArch64) enum isARM = true;
else enum isARM = false;

T[] unique(T)(T[] input)
{
    bool[T] seen;
    T[] ret;
    foreach (v; input)
    {
        if (!(v in seen))
        {
            seen[v] = true;
            ret ~= v;
        }
    }
    return ret;
}

string findProgramPath(string program)
{
    import std.algorithm : countUntil;

    string searcher;
    version (Windows) searcher = "where";
    else version (Posix) searcher = "which";
    else static assert(false, "No searcher program found in this OS.");

    auto pathValue = "PATH" in environment;
    string path = pathValue ? environment["PATH"] : "";
    auto shellRes = executeShell(searcher ~ " " ~ program, ["PATH": path]);
    if (shellRes.status == 0)
        return shellRes.output[0 .. shellRes.output.countUntil("\n")];
    return null;
}

bool dbgExecuteShell(scope const(char)[] command, ref Terminal t, const string[string] env = null)
{
    t.writeln("Executing command: ", command);
    auto ret = executeShell(command, env);
    if (ret.status)
    {
        t.writelnError(cast(string) ("Command '" ~ command ~ "' failed with: " ~ ret.output));
        t.flush();
    }
    return ret.status == 0;
}

struct WorkingDir
{
    private string previous;

    this(string targetDir)
    {
        previous = std.file.getcwd();
        std.file.chdir(targetDir);
    }

    ~this()
    {
        std.file.chdir(previous);
    }
}

bool makeFileExecutable(string filePath)
{
    version (Windows) return true;
    version (Posix)
    {
        if (!exists(filePath)) return false;
        import std.conv : octal;
        std.file.setAttributes(filePath, octal!700);
        return true;
    }
}

/// Lets feature code keep using `t.wait(pid)` after importing featurelib.
int wait(ref Terminal t, Pid pid)
{
    t.flush();
    return std.process.wait(pid);
}

string executableExtension(string path)
{
    version (Windows) return path ~ ".exe";
    return path;
}

bool filesExists(string basePath, scope immutable string[] files...)
{
    foreach (f; files)
    {
        auto temp = buildNormalizedPath(basePath, f);
        if (!exists(temp)) return false;
    }
    return true;
}

string getFirstExisting(string basePath, scope string[] tests...)
{
    foreach (t; tests)
    {
        auto temp = buildNormalizedPath(basePath, t);
        if (exists(temp)) return temp;
    }
    return "";
}

string getFirstExistingVar(scope string[] vars...)
{
    foreach (variable; vars)
    {
        if (variable in environment)
            return environment[variable];
    }
    return "";
}

string getValidPath(ref Terminal t, string pathRequired)
{
    while (true)
    {
        string path = t.getline(pathRequired);
        if (exists(path))
            return path;
    }
}

void addToPath(string pathToAdd)
{
    import std.array : join;
    import std.path : pathSeparator;

    string current = "PATH" in environment ? environment["PATH"] : "";
    environment["PATH"] = join([pathToAdd, current], pathSeparator);
}

string selectInFolder(string selectWhat, string directory, ref Terminal t)
{
    import std.algorithm.sorting : sort;
    import std.conv : to;
    import std.path : baseName;

    string[] names;
    foreach (entry; std.file.dirEntries(directory, std.file.SpanMode.shallow))
        if (entry.isDir)
            names ~= entry.name.baseName;
    names.sort();

    t.writeln(selectWhat);
    foreach (i, name; names)
        t.writeln("\t", i, ") ", name);
    t.flush();

    while (true)
    {
        string line = t.getline("Select: ");
        try
        {
            size_t index = line.to!size_t;
            if (index < names.length)
                return names[index];
        }
        catch (Exception) {}
        t.writelnError("Invalid choice.");
    }
}

version (Windows)
{
    import std.windows.registry : Key, Registry;

    Key windowsGetKeyWithPath(string[] path...)
    {
        Key hklm = Registry.localMachine;
        if (hklm is null) throw new Error("No HKEY_LOCAL_MACHINE in this system.");
        Key currKey = hklm;
        foreach (p; path)
        {
            try
            {
                currKey = currKey.getKey(p);
                if (currKey is null) return null;
            }
            catch (Exception)
            {
                return null;
            }
        }
        return currKey;
    }
}
