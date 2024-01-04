module features._7zip;
public import feature;
import commons;

Feature _7zFeature;
Task!(extract7ZipToFolderImpl) extract7ZipToFolder;

bool install7Zip(
    ref Terminal t,
    ref RealTimeConsoleInput input, 
    TargetVersion ver,
    Download[] content
)
{
    configs["7zip"] = buildNormalizedPath(content[0].getOutputPath);
    updateConfigFile();
	return true;
}

private bool extract7ZipToFolderImpl(ref Terminal t, ref RealTimeConsoleInput input, string zPath, string outputDirectory)
{
	if(!std.file.exists(zPath)) 
	{
		t.writelnError("File ", zPath, " does not exists.");
		return false;
	}
	t.writeln("Extracting ", zPath, " to ", outputDirectory);
	t.flush;

	string folderName = baseName(outputDirectory);
	outputDirectory = dirName(outputDirectory);
	if(!std.file.exists(outputDirectory))
		std.file.mkdirRecurse(outputDirectory);

	with(WorkingDir(outputDirectory))
	{
		bool ret = dbgExecuteShell(configs["7zip"].str ~ " x -y "~zPath~" "~folderName, t);
		return ret;
	}
}

void initialize()
{
	_7zFeature  = Feature(
		name: "7zip",
		description: "Compressed file type",
		ExistenceChecker(["7zip"], ["7z", "7za"]),
		Installation([Download(
			DownloadURL(windows: "https://www.7-zip.org/a/7zr.exe"),
			"$CWD/buildtools/7z".executableExtension
		)], &install7Zip),
		startUsingFeature: null,
		VersionRange(),
		dependencies: null,
		requiredOn: null
	);
}

void start()
{
	extract7ZipToFolder = Task!(extract7ZipToFolderImpl)([&_7zFeature]);
}