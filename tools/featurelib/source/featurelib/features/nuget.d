module featurelib.features.nuget;

import featurelib;
import std.path : buildNormalizedPath;
import std.process : spawnShell;
import std.system;

private Feature nuGetFeature;

Task!(callNuGetCommand) callNuGet;
Task!(installWithNuGetImpl) installWithNuGet;

private bool installWithNuGetImpl(Feature*[] dependencies, ref Terminal t, ConsoleInput input, string reason, string packageName, string outputPath)
{
    t.writeln("Package '", packageName, "' will be downloaded for ", reason);
    return t.wait(spawnShell(configs["nuGet"].str ~ " install " ~ packageName ~ " -o " ~ outputPath)) == 0;
}

private bool callNuGetCommand(Feature*[] dependencies, ref Terminal t, ConsoleInput input, string cmd)
{
    return t.wait(spawnShell(configs["nuGet"].str ~ " " ~ cmd)) == 0;
}

void initialize()
{
    static bool installNuGet(
        ref Terminal t,
        ConsoleInput input,
        TargetVersion ver,
        Download[] content,
        string[] extractionPaths)
    {
        configs["nuGet"] = buildNormalizedPath(content[0].getOutputPath);
        updateConfigFile();
        return true;
    }

    nuGetFeature = Feature(
        name: "NuGet CLI",
        description: "A package manager for Visual Studio projects",
        ExistenceChecker(["nuGet"]),
        Installation([Download(
            DownloadURL(windows: "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"),
            "$CONFIG_DIR/buildtools/nuget".executableExtension
        )], toDelegate(&installNuGet)),
        startUsingFeature: null,
        VersionRange(),
        requiredOn: [OS.win32, OS.win64],
        dependencies: null,
    );
    nuGetFeature.shareable = true;
}

void start()
{
    callNuGet = Task!(callNuGetCommand)([&nuGetFeature]);
    installWithNuGet = Task!(installWithNuGetImpl)([&nuGetFeature]);
}
