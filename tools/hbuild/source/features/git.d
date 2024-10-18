module features.git;
import commons;
import feature;

Feature GitFeature;
Task!loadSubmodules submoduleLoader;

private void loadSubmodules(Feature*[] dependencies, ref Terminal t, ref RealTimeConsoleInput input)
{
	import std.process;
	t.writelnSuccess("Updating Git Submodules");
	t.flush;
	executeShell("cd "~ configs["hipremeEnginePath"].str ~ " && " ~ getGitExec~" submodule update --init --recursive");
}

bool installGit(ref Terminal t, ref RealTimeConsoleInput input, 
    TargetVersion ver,
Download[] downlloads)
{
	version(Windows)
	{
        string gitPath = buildNormalizedPath(std.file.getcwd(), "buildtools", "git");
        if(!extractToFolder(downlloads[0].getOutputPath, "git.zip",
        t, input))
        {
            t.writelnError("Git installation failed");
            return false;
        }
        configs["git"] = buildNormalizedPath(gitPath, "cmd");
        updateConfigFile();
		return true;
	}
	else version(Posix)
	{
		t.writelnError("Please install Git to use hbuild.");
		return false;
	}
}

void initialize()
{
	GitFeature = Feature(
		"git",
		"Git Versioning software",
		ExistenceChecker(null, ["git"]),
		Installation([
			Download(
				DownloadURL(
					windows: "https://github.com/git-for-windows/git/releases/download/v2.40.1.windows.1/MinGit-2.40.1-64-bit.zip"
				),
				outputPath: "$CWD/buildtools/git"
			),
		], toDelegate(&installGit)
	));
}
void start()
{
	submoduleLoader = Task!(loadSubmodules)([&GitFeature]);
}