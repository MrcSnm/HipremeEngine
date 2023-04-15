module targets.android;
import commons;
import std.net.curl;

///This is the one which will be installed when using the SDK.
enum TargetAndroidSDK = 31;
enum TargetAndroidNDK = "21.4.7075529";
enum Ldc2AndroidAarchLibReleaseLink = "https://github.com/MrcSnm/HipremeEngine/releases/download/BuildAssets.v1.0.0/android.zip";
enum CurrentlySupportedLdc2Version = "ldc2 1.32.0";

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
		string tempNdkPath = buildNormalizedPath(locAppData, "Android", "Sdk");
		if(!std.file.exists(tempNdkPath))
		{
			t.writelnError("Could not find ", tempNdkPath, ". You need to install Android SDK.");
			t.flush;
			return FindAndroidNdkResult.MustInstallSdk;
		}
		tempNdkPath = buildNormalizedPath(tempNdkPath, "ndk");
		if(!std.file.exists(tempNdkPath))
		{
			t.writelnError("Could not find ", tempNdkPath, ". You need to have at least one NDK installed.");
			t.flush;
			return FindAndroidNdkResult.MustInstallNdk;
		}
		do
		{
			string ndkPath = selectInFolder(tempNdkPath, t, input);
			if(isValidNDK(ndkPath))
			{
				tempNdkPath = ndkPath;
				break;
			}
			t.writelnError("Please select a valid NDK (<= 21)");
		} while(true);
		t.writelnSuccess("Chosen "~ tempNdkPath~ " as your NDK.");
		environment["androidNdkPath"] = tempNdkPath;
		return FindAndroidNdkResult.Found;
	}
	else version(linux)
	{
		return FindAndroidNdkResult.NotFound;
	}

}

private string getAndroidSDKDownloadLink()
{
	version(Windows) return "https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip";
	else version(linux) return "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip";
	else version(OSX) return "https://dl.google.com/android/repository/commandlinetools-mac-9477386_latest.zip";
	else assert(false, "Your system does not have an Android SDK.");
}

private string getAndroidFlagsToolchains()
{
	version(Windows)
	{
		import std.string:replace;
		return "-gcc=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android21-clang.cmd").replace("\\", "/") ~"\" " ~
		"-linker=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android-ld.bfd.exe").replace("\\", "/") ~"\" " ~
		///Put the lib path for finding libandroid, liblog, libOpenSLES, libEGL and libGLESv3
		"-L-L\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/lib/aarch64-linux-android/30/").replace("\\", "/")~"\" "
		;
	}
	else version(linux)
	{
		return "-gcc=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang.cmd") ~"\" " ~
		"-linker=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ld.bfd.exe") ~"\" " ~
		///Put the lib path for finding libandroid, liblog, libOpenSLES, libEGL and libGLESv3
		"-L-L\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/30/")~"\" "
		;
	}
}

private string getPackagesToInstall()
{
	import std.conv:to;
	return `"build-tools;`~to!string(TargetAndroidSDK)~`.0.0" `~ 
		`"extras;google;usb_driver" ` ~
		`"extras;google;webdriver" ` ~
		`"extras;intel;Hardware_Accelerated_Execution_Manager" `~
		`"ndk;`~TargetAndroidNDK~`" `~
		`"platforms;android-`~to!string(TargetAndroidSDK)~`" `~
		`"sources;android-`~to!string(TargetAndroidSDK)~`" `
	;
}

private bool downloadAndroidSDK(ref Terminal t, ref RealTimeConsoleInput input, out string sdkPath)
{
	import std.file:tempDir;
	import std.zip;

	string androidSdkZip = buildNormalizedPath(tempDir, "android_sdk.zip");

	if(!downloadFileIfNotExists("Android SDK will be installed on your system, do you accept it?", 
		getAndroidSDKDownloadLink(), androidSdkZip, t, input))
		return false;

	string outputDirectory = buildNormalizedPath(std.file.getcwd(), "Android", "Sdk");
	sdkPath = outputDirectory;
	string finalOutput = buildNormalizedPath(outputDirectory, "cmdline-tools", "latest");

	if(!std.file.exists(finalOutput))
	{
		if(!extractZipToFolder(androidSdkZip, outputDirectory, t))
			return false;
		std.file.rename(buildNormalizedPath(outputDirectory, "cmdline-tools/"), buildNormalizedPath(outputDirectory, "latest/"));
		std.file.mkdirRecurse(buildNormalizedPath(outputDirectory, "cmdline-tools"));
		std.file.rename(buildNormalizedPath(outputDirectory, "latest"), finalOutput);
	}
	return true;
}

private bool downloadAndroidLibraries(ref Terminal t, ref RealTimeConsoleInput input)
{
	string androidZipDir = buildNormalizedPath(std.file.tempDir(), "androidLibs.zip");
	if(!downloadFileIfNotExists("Do you accept downloading android libraries for "~CurrentlySupportedLdc2Version, 
		Ldc2AndroidAarchLibReleaseLink, androidZipDir, t, input))
		return false;

	string outputDir = buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs");
	extractZipToFolder(androidZipDir, outputDir, t);

	return true;
}

private bool installAndroidNDK(ref Terminal t, string sdkPath)
{
	string finalOutput = buildNormalizedPath(sdkPath, "cmdline-tools", "latest");
	t.writeln("Updating SDK manager.");
	t.flush;


	string sdkManagerPath = buildNormalizedPath(finalOutput, "bin");

	if(!makeFileExecutable(buildNormalizedPath(sdkManagerPath, "sdkmanager")))
	{
		t.writeln("Failed to set sdkmanager as executable.");
		t.flush;
		return false;
	}

	string execSdkManager = "sdkmanager ";
	version(Posix) execSdkManager = "./sdkmanager";

	if(wait(spawnShell("cd "~sdkManagerPath~" && "~execSdkManager~" --install")) != 0)
	{
		t.writeln("Failed on installing SDK.");
		t.flush;
		return false;
	}

	t.writeln("Installing packages: ", getPackagesToInstall());
	t.writeln("You will need to accept some permissions, this process may take a little bit of time.");
	t.flush;
	if(wait(spawnShell("cd "~sdkManagerPath~" && "~execSdkManager ~" " ~getPackagesToInstall())) != 0)
	{
		t.writeln("Failed on installing NDK.");
		t.flush;
		return false;
	}

	configs["androidNdkPath"] = buildNormalizedPath(sdkPath, "ndk", TargetAndroidNDK);
	updateConfigFile();
	return true;
}



void prepareAndroid(Choice* c, ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!("androidNdkPath" in configs))
	{
		FindAndroidNdkResult res = tryFindAndroidNDK(t, input);
		switch(res)
		{
			case FindAndroidNdkResult.NotFound:
			{
				string sdkPath;
				if(!downloadAndroidSDK(t, input, sdkPath))
				{
					t.writelnError("Android SDK download didn't succeed");
					return;
				}
				if(!installAndroidNDK(t, sdkPath))
				{
					t.writelnError("Could not install Android NDK.");
					return;
				}
				break;
			}
			case FindAndroidNdkResult.Found:
				updateConfigFile();
				break;
			default: assert(false, "Case not yet implemented.");
		}
	}

	if(!std.file.exists(
		buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs", "android", "lib", "libdruntime-ldc.a")))
	{
		if(!downloadAndroidLibraries(t, input))
		{
			t.writelnError("Failed downloading ldc android libraries.");
			t.flush;
			return;
		}
	}


	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);
	putResourcesIn(t, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "android", "project", "app", "src", "main", "assets"));

	string ldcLibsPath = buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs", "android", "lib");


	///The commented commands will have to wait a rework in dub cli handling.
	environment["DFLAGS"] = 
		// "-defaultlib=phobos2-ldc,druntime-ldc " ~
		// "-link-defaultlib-shared=false " ~
		// "-L-L\""~ ldcLibsPath ~"\" " ~
		// "-L-rpath=\""~ ldcLibsPath~"\" "~
		getAndroidFlagsToolchains()
	;

	t.writeln(environment["DFLAGS"]);
	t.flush;

	std.file.chdir(configs["hipremeEnginePath"].str);
	wait(spawnShell("dub build --parallel -c android --compiler=ldc2 -a aarch64--linux-android -v"));
}
