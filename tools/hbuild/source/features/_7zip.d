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
	import std.file;
	if(!exists(content[0].getOutputPath))
		throw new Exception("7zip wasn't found at its target path: "~content[0].getOutputPath);
    configs["7zip"] = buildNormalizedPath(content[0].getOutputPath);
    updateConfigFile();
	return true;
}

private bool extract7ZipToFolderImpl(Feature*[] dependencies, ref Terminal t, ref RealTimeConsoleInput input, string zPath, string outputDirectory)
{
	if(!std.file.exists(zPath)) 
	{
		t.writelnError("File ", zPath, " does not exists.");
		return false;
	}
	t.writeln("Extracting ", zPath, " to ", outputDirectory);
	t.flush;

	if(!std.file.exists(outputDirectory))
		std.file.mkdirRecurse(outputDirectory);


	with(WorkingDir(outputDirectory))
	{
		bool ret = dbgExecuteShell(configs["7zip"].str ~ " x -y "~zPath, t);
		return ret;
	}
}

void initialize()
{
	import std.system;
	_7zFeature  = Feature(
		name: "7zip",
		description: "Compressed file type",
		ExistenceChecker(["7zip"], ["7z", "7za"]),
		Installation([Download(
			DownloadURL(windows: "https://www.7-zip.org/a/7zr.exe"),
			"$CWD/buildtools/7z".executableExtension
		)], toDelegate(&install7Zip)),
		startUsingFeature: null,
		VersionRange(),
		requiredOn: [OS.win32, OS.win64],
		dependencies: null,
	);
}

void start()
{
	extract7ZipToFolder = Task!(extract7ZipToFolderImpl)([&_7zFeature]);
}