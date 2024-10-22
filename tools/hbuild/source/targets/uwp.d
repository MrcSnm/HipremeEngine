module targets.uwp;
version(Windows):
import commons;
import common_windows;

private bool installUWPBuildTools(ref Terminal t, ref RealTimeConsoleInput input, out string devConsoleDir)
{
    import features.vs_buildtools_installer;
    import std.conv:to;

    wchar[] ver, installDir;
    bool shouldInstall;

    shouldInstall = !detectVSInstallDirViaCOM(ver, installDir);
    if(!shouldInstall)
    {
        import std.file;
        string install = installDir.to!string;
        devConsoleDir = buildNormalizedPath(install, "Common7", "Tools", "VsDevCmd.bat");

        string uwpCheck = buildNormalizedPath(install, "VC", "Tools", "MSVC");
        if(!shouldInstall)
            shouldInstall = !std.file.exists(uwpCheck);
        if(!shouldInstall)
            shouldInstall = !std.file.exists(buildNormalizedPath(dirEntries(uwpCheck, SpanMode.shallow).front, "lib", "x64", "uwp"));
    }


    if(shouldInstall)
    {
        return installFromVSBuildTools.execute(t, input, "Installing UWP SDK",
        [
            "Microsoft.VisualStudio.Workload.UniversalBuildTools",
            "Microsoft.VisualStudio.ComponentGroup.UWP.VC.BuildTools",
        ]);
    }
    return true;
    /**
    HipremeEngine

Updates:

Microsoft.Windows.CppWinRT.2.0.210309.3 -> Microsoft.Windows.CppWinRT.2.0.240405.15

Needs to install nuget
*/
}



private string getCppWinRt(string basePath)
{
    import std.string;
    import std.file;
    if(!std.file.exists(basePath))
        return null;
    foreach(DirEntry e; dirEntries(basePath, SpanMode.shallow))
    {
        if(baseName(e.name).startsWith("Microsoft.Windows.CppWinRT"))
            return e.name;
    }
    return null;
}

ChoiceResult prepareUWP(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    import common_windows;
    import tools.insert_resources_uwp;
    string vsDevCmd;
    if(!installUWPBuildTools(t, input, vsDevCmd))
        return ChoiceResult.Error;
    ProjectDetails project;
	with(WorkingDir(configs["gamePath"].str))
    {
		if(waitRedub(t, DubArguments().command("build").configuration("uwp").compiler("ldc2").opts(cOpts), project) != 0)
        {
            t.writelnError("Could not build for UWP. ");
            return ChoiceResult.Error;
        }
    }

    string file = project.getOutputFile();
    if(std.file.exists(file))
    {
        t.writelnHighlighted("Renaming ", file, " to hipreme_engine.dll for compatibility. ");
        string outDirectory = getHipPath("bin", "uwp");
        if(!std.file.exists(outDirectory))
            std.file.mkdirRecurse(outDirectory);
        std.file.rename(file, getHipPath("bin", "uwp", "hipreme_engine.dll"));
    }

    if(!insertUWPResources(t, getHipPath("build", "uwp", "HipremeEngine", "HipremeEngine"), buildNormalizedPath(configs["gamePath"].str, "assets")))
    {
        t.writelnError("Could not insert UWP resources.");
        return ChoiceResult.Error;
    }

    with(WorkingDir(getHipPath("build", "uwp", "HipremeEngine")))
    {
        string nugetPath = getHipPath("build", "uwp", "HipremeEngine", "packages");
        if(!getCppWinRt(nugetPath))
        {
            import features.nuget;
            if(!installWithNuGet.execute(t, input, "being able to build with MSBuild.", "Microsoft.Windows.CppWinRT -Version 2.0.240405.15", nugetPath))
            {
                t.writelnError("Download Failure: This package is needed for executing build on UWP");
                return ChoiceResult.Error;
            }
        }

        wait(spawnShell(
            "\""~vsDevCmd~ "\"" ~" && " ~
            "msbuild HipremeEngine.sln /m /p:Configuration=Debug /p:Platform=x64"
        ));
    }


	return ChoiceResult.Continue;
}
