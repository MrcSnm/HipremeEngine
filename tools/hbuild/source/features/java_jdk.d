module features.java_jdk;
public import feature;
import commons;
import hconfigs;

enum JDKVersion = "17.0.12";

Feature JavaJDKFeature;

static if(isARM)
	string arch = "aarch64";
else
	string arch = "x64";


private bool installOpenJDK(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] downloads)
{
	string installationOutput = buildNormalizedPath(std.file.getcwd(), "Android", "openjdk_17");
	if(!extractToFolder(downloads[0].getOutputPath(ver), installationOutput, t, input))
	{
		t.writelnError("Could not extract to folder ", installationOutput);
		return false;
	}

	string javaHome = buildNormalizedPath(installationOutput, std.file.dirEntries(installationOutput, std.file.SpanMode.shallow).front.name);// = environment["JAVA_HOME"];
	version(OSX)
		javaHome = buildNormalizedPath(javaHome, "Contents", "Home");

	if(!std.file.exists(javaHome))
	{
		t.writelnError("Expected JAVA_HOME at automatic installation does not exists:" ~ javaHome);
		return false;
	}
	configs["javaHome"] = javaHome;
	updateConfigFile();
	return true;
}

void initialize()
{
	JavaJDKFeature = Feature("Java JDK",
		"Java Development Kit. Required for compiling Java code and running gradle",
		ExistenceChecker(["javaHome"], ["JAVA_HOME"]),
		Installation([Download(
			DownloadURL(
				windows:"https://aka.ms/download-jdk/microsoft-jdk-$VERSION-windows-"~arch~".zip",
				linux: "https://aka.ms/download-jdk/microsoft-jdk-$VERSION-linux-"~arch~".tar.gz",
				osx: "https://aka.ms/download-jdk/microsoft-jdk-$VERSION-macos-"~arch~".tar.gz"
			))
		], toDelegate(&installOpenJDK)),
		(ref Terminal t, string where){environment["JAVA_HOME"] = where;},
		VersionRange.parse(JDKVersion)
	);

}
void start(){}