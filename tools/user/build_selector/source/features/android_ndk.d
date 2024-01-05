module features.android_ndk;
public import feature;
import commons;
enum TargetAndroidNDK = "21.4.7075529";

Feature AndroidNDKFeature;
private bool installAndroidNDK(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] content)
{
    string finalOutput = buildNormalizedPath(configs["androidSdkPath"].str, "cmdline-tools", "latest");
	string sdkManagerPath = buildNormalizedPath(finalOutput, "bin");
	string execSdkManager = "sdkmanager ";
	version(Posix) execSdkManager = "./sdkmanager";
    string packagesToInstall = `"ndk;`~ver.toString~`" `;

	t.writelnHighlighted("Installing packages: ", packagesToInstall, " \n\t", "You may need to accept some permissions, this process may take a little bit of time.");
    t.flush;
	if(wait(spawnShell("cd "~sdkManagerPath~" && "~execSdkManager ~" " ~packagesToInstall)) != 0)
	{
		t.writeln("Failed on installing NDK.");
		t.flush;
		return false;
	}
	
	configs["androidNdkPath"] = buildNormalizedPath(configs["androidSdkPath"].str, "ndk", ver.toString);
	updateConfigFile();
	return true;
}

void initialize()
{
    AndroidNDKFeature = Feature(
        "Android NDK",
        "Android Native Development Kit. Required for developing in other languages than Java/Kotlin for Android",
        ExistenceChecker(["androidNdkPath"], null),
        Installation(null, &installAndroidNDK),
        null,
        VersionRange.parse(TargetAndroidNDK)
    );
}
void start()
{
    import features.android_sdk;
    AndroidNDKFeature.dependencies = [&AndroidSDKFeature];
}