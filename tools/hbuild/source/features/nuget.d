module features.nuget;
public import feature;
import commons;


private Feature nuGetFeature;

/**
```d
bool(ref Terminal t, ref RealTimeConsoleInput input, string command)
```
*/
Task!(callNuGetCommand) callNuGet;

/**
```d
bool(ref Terminal t, ref RealTimeConsoleInput input, string reason, string packageName, string outputPath)
```
*/
Task!(installWithNuGetImpl) installWithNuGet;

private bool installWithNuGetImpl(Feature*[] dependencies, ref Terminal t, ref RealTimeConsoleInput input, string reason, string packageName, string outputPath)
{
	t.writeln("Package '", packageName, "' will be downloaded for ", reason);
    return t.wait(spawnShell(configs["nuGet"].str ~" install "~ packageName ~" -o "~ outputPath)) == 0;
}

private bool callNuGetCommand(Feature*[] dependencies, ref Terminal t, ref RealTimeConsoleInput input, string cmd)
{
    return t.wait(spawnShell(configs["nuGet"].str ~" "~ cmd)) == 0;
}

void initialize()
{
	static bool installNuGet(
		ref Terminal t,
		ref RealTimeConsoleInput input,
		TargetVersion ver,
	    Download[] content
	)
	{
		configs["nuGet"] = buildNormalizedPath(content[0].getOutputPath);
		updateConfigFile();
		return true;
	}

	import std.system;
	nuGetFeature  = Feature(
		name: "NuGet CLI",
		description: "A package manager for Visual Studio projects",
		ExistenceChecker(["nuGet"]),
		Installation([Download(
			DownloadURL(windows: "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"),
			"$CWD/buildtools/nuget".executableExtension
		)], toDelegate(&installNuGet)),
		startUsingFeature: null,
		VersionRange(),
		requiredOn: [OS.win32, OS.win64],
		dependencies: null,
	);
}

void start()
{
	callNuGet = Task!(callNuGetCommand)([&nuGetFeature]);
	installWithNuGet = Task!(installWithNuGetImpl)([&nuGetFeature]);
}