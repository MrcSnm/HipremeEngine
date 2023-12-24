module features.git;
import commons;

bool installGit(ref Terminal t, ref RealTimeConsoleInput input)
{
	version(Windows)
	{
        string gitPath = buildNormalizedPath(std.file.getcwd(), "buildtools", "git");
        if(!installFileTo("Download Git for getting HipremeEngine's source code.", getGitDownloadLink(), "git.zip",
        gitPath, t, input))
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
		t.writelnError("Please install Git to use build_selector.");
		return false;
	}
}