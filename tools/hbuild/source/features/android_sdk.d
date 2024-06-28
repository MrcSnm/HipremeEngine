module features.android_sdk;

import feature;
import commons;
enum TargetAndroidSDK = 31;


version(Windows) enum SearchForSDK = true;
else version(OSX) enum SearchForSDK = true;
else enum SearchForSDK = false;

private bool androidSdkExists(ref Terminal t, TargetVersion ver, out ExistenceStatus status)
{
	static if(SearchForSDK)
	{
		string androidStudioSdkPath;
		version(OSX)
		{
			androidStudioSdkPath = buildNormalizedPath("~", "Library", "Android", "sdk");
		}
		else version(Windows)
		{
			if("LOCALAPPDATA" in environment)
				androidStudioSdkPath = buildNormalizedPath(environment["LOCALAPPDATA"], "Android", "Sdk");
		}
		string sdkManagerPath = androidStudioSdkPath.buildNormalizedPath("cmdline-tools", "latest", "sdkmanager".executableExtension); 
		if(std.file.exists(sdkManagerPath))
		{
			status.place = ExistenceStatus.Place.custom;
			status.where = androidStudioSdkPath;
			return true;
		}
	}
	return false;
}

private string getAndroidSDKPackagesToinstall(string sdkMajorVer)
{
	import std.conv:to;
    string packages = `"build-tools;`~(sdkMajorVer)~`.0.0" `~ 
		`"extras;google;webdriver" ` ~
		`"platform-tools" ` ~
		`"platforms;android-`~to!string(sdkMajorVer)~`" `~
		`"sources;android-`~to!string(sdkMajorVer)~`" `;

	version(Windows)
	{
		packages~= `"extras;intel;Hardware_Accelerated_Execution_Manager" `~
					`"extras;google;usb_driver" `;
	}
	return packages;

}

private bool installAndroidSDK(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] content)
{
    import std.conv:to;
	string sdkPath = buildNormalizedPath(std.file.getcwd(), "Android", "Sdk");
	string cmdLineTools = buildNormalizedPath(sdkPath, "cmdline-tools", "latest");

	//Rename cmdline-tools/cmdline-tools to cmdline-tools/latest
	if(!std.file.exists(cmdLineTools))
		std.file.rename(buildNormalizedPath(sdkPath, "cmdline-tools", "cmdline-tools"), cmdLineTools);
	
    t.writeln("Updating SDK manager.");
	t.flush;
	string sdkManagerPath = buildNormalizedPath(cmdLineTools, "bin");

	if(!makeFileExecutable(buildNormalizedPath(sdkManagerPath, "sdkmanager")))
	{
		t.writelnError("Failed to set sdkmanager as executable.");
		return false;
	}
    string execSdkManager = "sdkmanager ";
	version(Posix) execSdkManager = "./sdkmanager";

	if(wait(spawnShell("cd "~sdkManagerPath~" && "~execSdkManager~" --install")) != 0)
	{
		t.writelnError("Failed on installing SDK.");
		return false;
	}
    string packagesToInstall = getAndroidSDKPackagesToinstall(ver.major.to!string);

    t.writelnHighlighted("Installing packages: ", packagesToInstall, " \n\t", "You may need to accept some permissions, this process may take a little bit of time.");
    t.flush;

    if(wait(spawnShell("cd "~sdkManagerPath~" && "~execSdkManager ~" " ~packagesToInstall)) != 0)
	{
		t.writelnError("Failed on installing SDK packages.");
		return false;
	}

    string adbPath = buildNormalizedPath(sdkPath, "platform-tools", "adb");
    if(!makeFileExecutable(adbPath))
	{
		t.writelnError("Failed to set ",adbPath," as executable.");
		return false;
	}

    configs["androidSdkPath"] = sdkPath;
    updateConfigFile();
	return true;
}

Feature AndroidSDKFeature;
void initialize()
{
    import std.conv:to;
    AndroidSDKFeature = Feature(
        "Android SDK",
        "Required for being able to develop applications for Android",
        ExistenceChecker(["androidSdkPath"], null, toDelegate(&androidSdkExists)),
        Installation([Download(
            DownloadURL(
                windows:"https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip",
                linux: "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip",
                osx: "https://dl.google.com/android/repository/commandlinetools-mac-9477386_latest.zip"
            )
        )], toDelegate(&installAndroidSDK), extractionPathList: ["$CWD/Android/Sdk/cmdline-tools"]),
        (ref Terminal t, string where){environment["ANDROID_HOME"] = where;},
        VersionRange.parse(TargetAndroidSDK.to!string)
    );
}
void start(){}