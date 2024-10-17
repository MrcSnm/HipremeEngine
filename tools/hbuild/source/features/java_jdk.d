module features.java_jdk;
public import feature;
import commons;

enum JDKVersion = "17.0.12";

Feature JavaJDKFeature;

private bool installOpenJDK(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] downloads)
{
	string installationOutput = buildNormalizedPath(std.file.getcwd(), "Android", "openjdk_17");
	if(!extractToFolder(downloads[0].getOutputPath(ver), installationOutput, t, input))
	{
		t.writelnError("Could not extract to folder ", installationOutput);
		return false;
	}

	string javaHome = installationOutput;// = environment["JAVA_HOME"];
	version(OSX)
		javaHome = buildNormalizedPath(javaHome, "jdk-11.0.1.jdk", "Contents", "Home");
	else
		javaHome = buildNormalizedPath(javaHome, "jdk-17.0.12+7");

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
				windows:"https://aka.ms/download-jdk/microsoft-jdk-$VERSION-windows-x64.zip",
				linux: "https://aka.ms/download-jdk/microsoft-jdk-$VERSION-linux-x64.tar.gz",
				osx: "https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_osx-x64_bin.tar.gz"
			))
		], toDelegate(&installOpenJDK)),
		(ref Terminal t, string where){environment["JAVA_HOME"] = where;},
		VersionRange.parse(JDKVersion)
	);

}
void start(){}