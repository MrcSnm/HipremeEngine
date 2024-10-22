module features.vs_buildtools_installer;
public import feature;
import commons;

enum BuildToolsVersion = "17";

private Feature vsBuildToolsInstaller;
/**
```d
bool (ref Terminal t, ref RealTimeConsoleInput input, string usage, const string[] features
```
*/
Task!(installFromVSBuildToolsImpl) installFromVSBuildTools;

private bool installFromVSBuildToolsImpl(Feature*[] dependencies, ref Terminal t, ref RealTimeConsoleInput input, string usage, const string[] features)
{
    import std.algorithm;
    t.writeln("Installing the following features with Microsoft Visual Studio Build Tools for '", usage, "'");
    foreach(f; features)
        t.writeln("\t", f);
    return wait(spawnShell(configs["vsBuildTools"].str~ " --passive --wait --norestart "
		~ features.reduce!((str, last) => "--add "~last~" "~str))
	) != 0;
}

bool installVSBuildTools(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] downloadsRequired)
{
	configs["vsBuildTools"] = downloadsRequired[0].getOutputPath();
	return true;
}

void initialize()
{
	vsBuildToolsInstaller  = Feature(
		name: "Visual Studio Build Tools Installer",
		description: "Gets the official Visual Studio Build Tools so it is possible to build to microsoft targets",
		ExistenceChecker(["vsBuildTools"]),
		Installation([Download(
			DownloadURL(
                windows: "https://aka.ms/vs/$VERSION/release/vs_BuildTools.exe"
            ),
			"$CWD/buildtools/vs_BuildTools".executableExtension
		)], toDelegate(&installVSBuildTools)),
        currentVersion: TargetVersion.parse(BuildToolsVersion)
	);
}

void start()
{
	installFromVSBuildTools = Task!(installFromVSBuildToolsImpl)([&vsBuildToolsInstaller]);
}