module featurelib.features.vs_buildtools_installer;

import featurelib;
import std.process : spawnShell;

enum BuildToolsVersion = "17";

private Feature vsBuildToolsInstaller;

Task!(installFromVSBuildToolsImpl) installFromVSBuildTools;

private bool installFromVSBuildToolsImpl(Feature*[] dependencies, ref Terminal t, ConsoleInput input, string usage, const string[] features)
{
    import std.algorithm;

    t.writeln("Installing the following features with Microsoft Visual Studio Build Tools for '", usage, "'");
    foreach (f; features)
        t.writeln("\t", f);
    return t.wait(spawnShell(configs["vsBuildTools"].str ~ " --passive --wait --norestart "
        ~ features.reduce!((str, last) => "--add " ~ last ~ " " ~ str))
    ) != 0;
}

bool installVSBuildTools(ref Terminal t, ConsoleInput input, TargetVersion ver, Download[] downloadsRequired, string[] extractionPaths)
{
    configs["vsBuildTools"] = downloadsRequired[0].getOutputPath();
    updateConfigFile();
    return true;
}

void initialize()
{
    vsBuildToolsInstaller = Feature(
        name: "Visual Studio Build Tools Installer",
        description: "Gets the official Visual Studio Build Tools so it is possible to build to microsoft targets",
        ExistenceChecker(["vsBuildTools"]),
        Installation([Download(
            DownloadURL(
                windows: "https://aka.ms/vs/$VERSION/release/vs_BuildTools.exe"
            ),
            "$CONFIG_DIR/buildtools/vs_BuildTools".executableExtension
        )], toDelegate(&installVSBuildTools)),
        currentVersion: TargetVersion.parse(BuildToolsVersion)
    );
    vsBuildToolsInstaller.shareable = true;
}

void start()
{
    installFromVSBuildTools = Task!(installFromVSBuildToolsImpl)([&vsBuildToolsInstaller]);
}
