module targets.android;
import commons;
import std.net.curl;

///This is the one which will be installed when using the SDK.
enum TargetAndroidSDK = 31;
enum TargetAndroidNDK = "21.4.7075529";

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
		return "-gcc=\""~configs["androidNdkPath"].str~"toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android21-clang.cmd\" " ~
		"-linker=\""~configs["androidNdkPath"].str~"toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android-ld.bfd.exe\" " ~
		///Put the lib path for finding libandroid, liblog, libOpenSLES, libEGL and libGLESv3
		"-L-L\""~configs["androidNdkPath"].str~"\"toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/lib/aarch64-linux-android/30/"
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
	if(!std.file.exists(androidSdkZip))
	{
		dchar shouldDownload;
		t.writelnHighlighted("Android SDK will be installed on your system, do you accept it? Select [Y]es/[N]o");
		t.flush;
		while(true)
		{
			shouldDownload = input.getch;
			if(shouldDownload == 'y' || shouldDownload == 'Y') break;
			else if(shouldDownload == 'n' || shouldDownload == 'N') return false;
		}
		download(getAndroidSDKDownloadLink(), androidSdkZip);
	}


	string outputDirectory = buildNormalizedPath(std.file.getcwd(), "androidSdk");
	sdkPath = outputDirectory;
	string finalOutput = buildNormalizedPath(outputDirectory, "cmdline-tools", "latest");

	if(!std.file.exists(finalOutput))
	{
		ZipArchive zip = new ZipArchive(std.file.read(androidSdkZip));
		if(!std.file.exists(outputDirectory))
		{
			t.writeln("Creating directory ", outputDirectory);
			std.file.mkdirRecurse(outputDirectory);
		}

		foreach(fileName, archiveMember; zip.directory)
		{
			string outputFile = buildNormalizedPath(outputDirectory, fileName);
			if(!std.file.exists(outputFile))
			{
				t.writeln("Extracting ", fileName);
				t.flush;
				if(!std.file.exists(outputFile.dirName))
					std.file.mkdirRecurse(outputFile.dirName);
				std.file.write(outputFile, zip.expand(archiveMember));
			}
		}
		std.file.rename(buildNormalizedPath(outputDirectory, "cmdline-tools/"), buildNormalizedPath(outputDirectory, "latest/"));
		std.file.mkdirRecurse(buildNormalizedPath(outputDirectory, "cmdline-tools"));
		std.file.rename(buildNormalizedPath(outputDirectory, "latest"), finalOutput);
	}
	return true;
}

private bool installAndroidNDK(ref Terminal t, string sdkPath)
{
	string finalOutput = buildNormalizedPath(sdkPath, "cmdline-tools", "latest");
	t.writeln("Updating SDK manager.");
	t.flush;

	string sdkManagerPath = buildNormalizedPath(finalOutput, "bin");
	wait(spawnShell("cd "~sdkManagerPath~" && sdkmanager --install"));

	t.writeln("Installing packages: ", getPackagesToInstall());
	t.writeln("You will need to accept some permissions, this process may take a little bit of time.");
	t.flush;
	wait(spawnShell("cd "~sdkManagerPath~" && sdkmanager "~getPackagesToInstall()));

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
	environment["DFLAGS"] = getAndroidFlagsToolchains();

	std.file.chdir(configs["hipremeEnginePath"].str);
	wait(spawnShell("dub build -c android --compiler=ldc2 -a aarch64--linux-android"));
}
