module features._7zip;
public import feature;
import commons;

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



Feature _7zFeature = Feature(
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