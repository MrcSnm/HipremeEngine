module featurelib.features.git;

import featurelib;
import std.path : buildNormalizedPath;
import std.process : executeShell;

Feature GitFeature;
Task!loadSubmodules submoduleLoader;

string getGitExec()
{
    if ("git" in configs)
    {
        version (Windows) return buildNormalizedPath(configs["git"].str, "git.exe");
        else return buildNormalizedPath(configs["git"].str, "git");
    }
    return "git ";
}

private void loadSubmodules(Feature*[] dependencies, ref Terminal t, ConsoleInput input)
{
    t.writelnSuccess("Updating Git Submodules");
    t.flush();
    auto ret = executeShell("cd " ~ configs["hipremeEnginePath"].str ~ " && " ~ getGitExec() ~ " submodule update --init --recursive");
    if (ret.status)
        throw new Exception("Execution of git submodule update --init --recursive failed: \n" ~ ret.output);
}

bool installGit(ref Terminal t, ConsoleInput input, TargetVersion ver, Download[] downloads, string[] extractionPaths)
{
    version (Windows)
    {
        configs["git"] = buildNormalizedPath(extractionPaths[0], "cmd");
        updateConfigFile();
        return true;
    }
    else version (Posix)
    {
        t.writelnError("Please install Git to use this feature.");
        return false;
    }
}

void initialize()
{
    GitFeature = Feature(
        "git",
        "Git Versioning software",
        ExistenceChecker(["git"], ["git"]),
        Installation([
            Download(
                DownloadURL(
                    windows: "https://github.com/git-for-windows/git/releases/download/v2.40.1.windows.1/MinGit-2.40.1-64-bit.zip",
                    osx: "https://github.com/git-for-windows/git/releases/download/v2.40.1.windows.1/MinGit-2.40.1-64-bit.zip",
                ),
                outputPath: "$TEMP$NAME"
            ),
        ], toDelegate(&installGit), ["$CONFIG_DIR/buildtools/git"]
    ));
    GitFeature.shareable = true;
}

void start()
{
    submoduleLoader = Task!(loadSubmodules)([&GitFeature]);
}
