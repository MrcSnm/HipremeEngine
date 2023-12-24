module features._7zip;

bool install7Zip(string purpose, ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!("7zip" in configs))
	{
		version(Windows)
		{
			string _7zPath = findProgramPath("7z");
			if(!_7zPath)
			{
				if(!downloadFileIfNotExists("Needs 7zip for "~purpose, "https://www.7-zip.org/a/7zr.exe", 
					buildNormalizedPath(std.file.getcwd(), "7z.exe"), t, input
				))
					return false;

				string outFolder = buildNormalizedPath(std.file.getcwd(), "buildtools");
				std.file.mkdirRecurse(outFolder);
				std.file.rename(buildNormalizedPath(std.file.getcwd(), "7z.exe"), buildNormalizedPath(outFolder, "7z.exe"));
				configs["7zip"] = buildNormalizedPath(outFolder, "7z.exe");
			}
			else
				configs["7zip"] = buildNormalizedPath(_7zPath);
			updateConfigFile();
		}
		else version(Posix)
		{
			configs["7zip"] = "7za";
			updateConfigFile();
		}
	}
	return true;
}

bool install7Zip2(ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!("7zip" in configs))
	{
		version(Windows)
		{
			string _7zPath = findProgramPath("7z");
			if(!_7zPath)
			{
				if(!downloadFileIfNotExists("Needs 7zip for "~purpose, "https://www.7-zip.org/a/7zr.exe", 
					buildNormalizedPath(std.file.getcwd(), "7z.exe"), t, input
				))
					return false;

				string outFolder = buildNormalizedPath(std.file.getcwd(), "buildtools");
				std.file.mkdirRecurse(outFolder);
				std.file.rename(buildNormalizedPath(std.file.getcwd(), "7z.exe"), buildNormalizedPath(outFolder, "7z.exe"));
				configs["7zip"] = buildNormalizedPath(outFolder, "7z.exe");
			}
			else
				configs["7zip"] = buildNormalizedPath(_7zPath);
			updateConfigFile();
		}
		else version(Posix)
		{
			configs["7zip"] = "7za";
			updateConfigFile();
		}
	}
	return true;
}