module features.android_ndk;
public import feature;
import commons;
enum TargetAndroidNDK = "28.0.12433566";

Feature AndroidNDKFeature;



enum FindAndroidNdkResult
{
	NotFound,
	Found,
	MustInstallSdk,
	MustInstallNdk
}

private FindAndroidNdkResult tryFindAndroidNDK(ref Terminal t, ref RealTimeConsoleInput input)
{
	if("ANDROID_NDK_HOME" in environment)
	{
		configs["androidNdkPath"] = environment["ANDROID_NDK_HOME"];
		string sdk = getFirstExistingVar("ANDROID_SDK", "ANDROID_SDK_HOME");
		if(!sdk.length)
			sdk = buildNormalizedPath(configs["androidNdkPath"].str, "..", "..");
		configs["androidSdkPath"] = sdk;
		return FindAndroidNdkResult.Found;
	}
	bool isValidNDK(string chosenNDK)
	{
		import std.conv:to;
		int ndkVer = chosenNDK[0..2].to!int;
		return ndkVer <= 21;
	}
	version(Windows)
	{
		string locAppData = environment["LOCALAPPDATA"];
		if(locAppData == null)
		{
			t.writelnError("Could not find %LOCALAPPDATA% in your Windows.");
			t.flush;
			return FindAndroidNdkResult.NotFound;
		}
		string sdkPath = buildNormalizedPath(locAppData, "Android", "Sdk");
		string tempNdkPath = sdkPath;

		if(!std.file.exists(sdkPath))
		{
			t.writelnError("Could not find ", sdkPath, ". You need to install Android SDK.");
			t.flush;
			return FindAndroidNdkResult.MustInstallSdk;
		}
		tempNdkPath = buildNormalizedPath(sdkPath, "ndk");
		if(!std.file.exists(tempNdkPath))
		{
			t.writelnError("Could not find ", tempNdkPath, ". You need to have at least one NDK installed.");
			t.flush;
			return FindAndroidNdkResult.MustInstallNdk;
		}
		do
		{
			string ndkPath = selectInFolder(
				"Select the NDK which you want to use. Remember that only NDK <= 21 is supported.",
				tempNdkPath, t, input
			);
			if(isValidNDK(ndkPath))
			{
				tempNdkPath = ndkPath;
				break;
			}
			t.writelnError("Please select a valid NDK (<= 21)");
		} while(true);
		t.writelnSuccess("Chosen "~ tempNdkPath~ " as your NDK.");
		environment["androidNdkPath"] = sdkPath;
		environment["androidSdkPath"] = tempNdkPath;
		return FindAndroidNdkResult.Found;
	}
	else version(linux)
	{
		return FindAndroidNdkResult.NotFound;
	}
	else version(OSX)
	{
		return FindAndroidNdkResult.NotFound;
	}
}


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
        Installation(null, toDelegate(&installAndroidNDK)),
        null,
        VersionRange.parse(TargetAndroidNDK)
    );
}
void start()
{
    import features.android_sdk;
    AndroidNDKFeature.dependencies = [&AndroidSDKFeature];
}