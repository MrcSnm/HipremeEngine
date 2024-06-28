module targets.android;
import commons;
import std.net.curl;
import std.path;

///This is the one which will be installed when using the SDK.
enum TargetAndroidSDK = 31;
enum TargetAndroidNDK = "21.4.7075529";
enum Ldc2AndroidAarchLibReleaseLink = "https://github.com/MrcSnm/HipremeEngine/releases/download/BuildAssets.v1.0.0/android.zip";
enum CurrentlySupportedLdc2Version = "ldc2 1.33.0-beta1";
///Use a random Adb Port 
enum HipremeEngineAdbPort = "55565";

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

private string getAndroidSDKDownloadLink()
{
	version(Windows) return "https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip";
	else version(linux) return "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip";
	else version(OSX) return "https://dl.google.com/android/repository/commandlinetools-mac-9477386_latest.zip";
	else assert(false, "Your system does not have an Android SDK.");
}

private string getOpenJDKDownloadLink()
{
	version(Windows) return "https://aka.ms/download-jdk/microsoft-jdk-11.0.18-windows-x64.zip";
	else version(linux) return "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz";
	else version(OSX) return "https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_osx-x64_bin.tar.gz";
	else assert(false, "Your system does not have an OpenJDK");
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
		return "-gcc=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang") ~"\" " ~
		"-linker=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ld.bfd") ~"\" " ~
		///Put the lib path for finding libandroid, liblog, libOpenSLES, libEGL and libGLESv3
		"-L-L\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/30/")~"\" "
		;
	}
	else version(OSX)
	{
		return "-gcc=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android21-clang") ~"\" " ~
		"-linker=\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android-ld.bfd") ~"\" " ~
		///Put the lib path for finding libandroid, liblog, libOpenSLES, libEGL and libGLESv3
		"-L-L\""~buildNormalizedPath(configs["androidNdkPath"].str, "toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/aarch64-linux-android/30/")~"\" "
		;
	}
}

private string getPackagesToInstall()
{
	import std.conv:to;
	string packages = `"build-tools;`~to!string(TargetAndroidSDK)~`.0.0" `~ 
		`"extras;google;webdriver" ` ~
		`"platform-tools" ` ~
		`"ndk;`~TargetAndroidNDK~`" `~
		`"platforms;android-`~to!string(TargetAndroidSDK)~`" `~
		`"sources;android-`~to!string(TargetAndroidSDK)~`" `;

	version(Windows)
	{
		packages~= `"extras;intel;Hardware_Accelerated_Execution_Manager" `~
					`"extras;google;usb_driver" `;
	}
	return packages;
}


private bool downloadOpenJDK(ref Terminal t, ref RealTimeConsoleInput input)
{
	string javaContainer = "openjdk_11.zip";
	version(Posix) javaContainer = javaContainer.setExtension(".tar.gz");
	javaContainer = buildNormalizedPath(std.file.tempDir, javaContainer);
	downloadFileIfNotExists("OpenJDK for building to Android. ", getOpenJDKDownloadLink(), javaContainer, t, input);

	string outputPath = buildNormalizedPath(std.file.getcwd(), "Android", "openjdk_11");
	return extractToFolder(javaContainer, outputPath, t, input);
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
	if(!makeFileExecutable(buildNormalizedPath(sdkPath, "platform-tools", "adb")))
	{
		t.writeln("Failed to set adb as executable.");
		t.flush;
		return false;
	}

	configs["androidSdkPath"] = sdkPath;
	configs["androidNdkPath"] = buildNormalizedPath(sdkPath, "ndk", TargetAndroidNDK);
	updateConfigFile();
	return true;
}

private bool installOpenJDK(ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!("javaHome" in configs))
	{
		if(!("JAVA_HOME" in environment))
		{
			t.writelnHighlighted("JAVA_HOME wasn't found in your environment. 
				Build Selector will download a compatible OpenJDK for Android Development.");
			t.flush;
			if(!downloadOpenJDK(t, input))
			{
				t.writelnError("Could not download OpenJDK");
				return false;
			}
			string javaHome = buildNormalizedPath(std.file.getcwd(), "Android", "openjdk_11");
			version(Windows) javaHome = buildNormalizedPath(javaHome, "jdk-11.0.18+10");
			else version(linux) javaHome = buildNormalizedPath(javaHome, "jdk-11.0.2");
			else version(OSX) javaHome = buildNormalizedPath(javaHome, "jdk-11.0.1.jdk", "Contents", "Home");
			else assert(false, "Your OS is not supported.");
			if(!std.file.exists(javaHome))
			{
				t.writelnError("Expected JAVA_HOME at automatic installation does not exists:" ~ javaHome);
				t.flush();
				return false;
			}
			configs["javaHome"] = javaHome;
			updateConfigFile();
		}
		else
		{
			configs["javaHome"] = environment["JAVA_HOME"];
			updateConfigFile();
		}
	}
	return true;
}

private bool installAndroidSDK(ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!("androidNdkPath" in configs) || !("androidSdkPath" in configs))
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
					return false;
				}
				if(!installAndroidNDK(t, sdkPath))
				{
					t.writelnError("Could not install Android NDK.");
					return false;
				}
				break;
			}
			case FindAndroidNdkResult.Found:
				updateConfigFile();
				break;
			default: assert(false, "Case not yet implemented.");
		}
	}
	return true;
}


private ChoiceResult runAndroidApplication(ref Terminal t)
{
	version(Windows)
	{
		string adb = buildNormalizedPath(configs["androidSdkPath"].str, "platform-tools", "adb.exe");
		string gradlew = "gradlew.bat";
	}
	else version(Posix)
	{
		string adb = buildNormalizedPath(configs["androidSdkPath"].str, "platform-tools", "adb");
		string gradlew = "./gradlew";

		if(!makeFileExecutable(buildNormalizedPath("build", "android", "project", "gradlew")))
		{
			t.writelnError("Could not make gradlew executable.");
			return ChoiceResult.Error;
		}
	}

	std.file.chdir(buildNormalizedPath("build", "android", "project"));

	if(wait(spawnShell(gradlew ~ " :app:assembleDebug")) != 0)
	{
		t.writelnError("Could not build Java code.");
		return ChoiceResult.Error;
	}

	string adbInstall = adb~" install -r "~
		buildNormalizedPath(std.file.getcwd(), "app", "build", "outputs", "apk", "debug", "app-debug.apk");

	t.writeln("Executing adb install: ", adbInstall);
	t.flush;
	environment["ANDROID_ADB_SERVER_PORT"] = HipremeEngineAdbPort;
	if(wait(spawnShell(adbInstall)) != 0)
	{
		t.writelnError("Could not install application to your device.");
		return ChoiceResult.Error;
	}
	if(wait(spawnShell(adb~" shell monkey -p com.hipremeengine.app 1")) != 0)
	{
		t.writelnHighlighted("Could not connect to Android's shell");
	}
	//logcat -b all -v color com.hipremengine.app:D | findstr com.hipremeengine.app
	return ChoiceResult.Continue;
}

ChoiceResult prepareAndroid(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	// if(!installOpenJDK(t, input))
	// {
	// 	t.writelnError("Failed installing OpenJDK.");
	// 	return ChoiceResult.Error;
	// }
	// environment["JAVA_HOME"] = configs["javaHome"].str;
	// if(!installAndroidSDK(t, input))
	// {
	// 	t.writelnError("Failed installing Android SDK.");
	// 	return ChoiceResult.Error;
	// }
	

	// if(!std.file.exists(
	// 	buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs", "android", "lib", "libdruntime-ldc.a")))
	// {
	// 	if(!downloadAndroidLibraries(t, input))
	// 	{
	// 		t.writelnError("Failed downloading ldc android libraries.");
	// 		t.flush;
	// 		return ChoiceResult.Error;
	// 	}
	// }
	// environment["ANDROID_HOME"] = configs["androidSdkPath"].str;

	import features.android_ndk;
	import features.java_jdk;
	import features.android_ldc;

	if(!JavaJDKFeature.getFeature(t, input))
		return ChoiceResult.Error;
	if(!AndroidNDKFeature.getFeature(t, input, TargetVersion.parse(TargetAndroidNDK)))
		return ChoiceResult.Error;
	if(!AndroidLDCLibraries.getFeature(t, input))
		return ChoiceResult.Error;
	

	executeGameRelease(t);
	putResourcesIn(t, getHipPath("build", "android", "project", "app", "src", "main", "assets"));
	cached(() => timed(t, outputTemplateForTarget(t)));
	outputTemplate(t, configs["gamePath"].str);

	string ldcLibsPath = buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs", "android", "lib");


	string nextReleaseFlags = "-defaultlib=phobos2-ldc,druntime-ldc " ~
		"-link-defaultlib-shared=false " ~
		"-L-L\""~ ldcLibsPath ~"\" " ~
		"-L-rpath=\""~ ldcLibsPath~"\" ";

	environment["DFLAGS"] = nextReleaseFlags ~ getAndroidFlagsToolchains();
	t.writeln(environment["DFLAGS"]);
	t.flush;

	std.file.chdir(configs["hipremeEnginePath"].str);

	if(waitDubTarget(t, "android", DubArguments().command("build").arch("aarch64--linux-android").opts(cOpts)) != 0)
	{
		t.writelnError("Compilation failed.");
		return ChoiceResult.Error;
	}

	std.file.rename(
		buildNormalizedPath("bin", "android", "libhipreme_engine.so"),
		buildNormalizedPath("build", "android", "project", "app", "src", "main", "jniLibs", "arm64-v8a", "libhipreme_engine.so")
	);
	return runAndroidApplication(t);
}
