module features.java_jdk;
public import feature;
import commons;

Feature JavaJDKFeature;
private bool installOpenJDK(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] downloads)
{
	string installationOutput = buildNormalizedPath(std.file.getcwd(), "Android", "openjdk_11");
	if(!extractToFolder(downloads[0].getOutputPath, installationOutput, t, input))
	{
		t.writelnError("Could not extract to folder ", installationOutput);
		return false;
	}

	string javaHome = installationOutput;// = environment["JAVA_HOME"];
	version(Windows) javaHome = buildNormalizedPath(javaHome, "jdk-11.0.18+10");
	else version(linux) javaHome = buildNormalizedPath(javaHome, "jdk-11.0.2");
	else version(OSX) javaHome = buildNormalizedPath(javaHome, "jdk-11.0.1.jdk", "Contents", "Home");
	else assert(false, "Your OS is not supported.");
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
				windows:"https://aka.ms/download-jdk/microsoft-jdk-11.0.18-windows-x64.zip",
				linux: "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz",
				osx: "https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_osx-x64_bin.tar.gz"
			))
		], &installOpenJDK),
		(ref Terminal t, string where){environment["JAVA_HOME"] = where;}
	);

}
void start(){}