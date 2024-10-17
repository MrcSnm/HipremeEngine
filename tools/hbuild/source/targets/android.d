module targets.android;
import features.ldc;
import commons;
import std.net.curl;
import std.path;

///This is the one which will be installed when using the SDK.
enum TargetAndroidSDK = 35;
enum TargetAndroidNDK = "28.0.12433566";
enum TargetJavaJDK = "17.0.12";
///Use a random Adb Port 
enum HipremeEngineAdbPort = "55565";

private string getAndroidFlagsToolchains()
{
	enum AndroidSDKLibs = 35;

	version(Windows)
		string system = "windows-x86_64";
	else version(linux)
		string system = "linux-x86_64";
	else version(OSX)
		string system = "darwing-x86_64";
	else static assert(false, "Your OS does not support android NDK installation.");

	string toolsPath = buildNormalizedPath(configs["androidNdkPath"].str, "toolchains", "llvm", "prebuilt", system);

	version(Windows)
	{
		import std.string:replace;
		return "-gcc=\""~buildNormalizedPath(toolsPath, "bin/aarch64-linux-android35-clang.cmd").replace("\\", "/") ~"\" " ~
		"-linker=\""~buildNormalizedPath(toolsPath, "bin/ld.lld.exe").replace("\\", "/") ~"\" " ~
		///Put the lib path for finding libandroid, liblog, libOpenSLES, libEGL and libGLESv3
		"-L-L\""~buildNormalizedPath(toolsPath, "sysroot/usr/lib/aarch64-linux-android/"~AndroidSDKLibs~"/").replace("\\", "/")~"\" "
		;
	}
	else
	{
		return "-gcc="~buildNormalizedPath(toolsPath, "bin/aarch64-linux-android35-clang") ~" " ~
		"-linker="~buildNormalizedPath(toolsPath, "bin/ld.lld") ~" " ~
		"-L-L"~buildNormalizedPath(toolsPath, "sysroot/usr/lib/aarch64-linux-android/"~AndroidSDKLibs~"/")
		;
	}
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

		if(!makeFileExecutable(getHipPath("build", "android", "project", "gradlew")))
		{
			t.writelnError("Could not make gradlew executable.");
			return ChoiceResult.Error;
		}
	}

	with(WorkingDir(getHipPath("build", "android", "project")))
	{
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
	}
	//logcat -b all -v color com.hipremengine.app:D | findstr com.hipremeengine.app
	return ChoiceResult.Continue;
}

ChoiceResult prepareAndroid(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	import features.android_ndk;
	import features.java_jdk;
	import features.android_ldc;

	if(!JavaJDKFeature.getFeature(t, input, TargetVersion.parse(TargetJavaJDK)))
		return ChoiceResult.Error;
	if(!AndroidNDKFeature.getFeature(t, input, TargetVersion.parse(TargetAndroidNDK)))
		return ChoiceResult.Error;

	executeGameRelease(t);
	putResourcesIn(t, getHipPath("build", "android", "project", "app", "src", "main", "assets"));
	outputTemplate(t, configs["gamePath"].str);

	string ldcLibsPath = getAndroidLDCLibrariesPath.execute(t, input);

	string nextReleaseFlags = "-defaultlib=phobos2-ldc,druntime-ldc " ~
		"-link-defaultlib-shared=false " ~
		"-L-L"~ ldcLibsPath ~" " ~
		"-L-rpath="~ ldcLibsPath~" ";

	environment["DFLAGS"] = nextReleaseFlags ~ getAndroidFlagsToolchains();
	t.writeln(environment["DFLAGS"]);
	t.flush;

	with(WorkingDir(configs["gamePath"].str))
	{
		ProjectDetails proj;
		if(waitRedub(t, DubArguments().command("build").arch("aarch64--linux-android").configuration("android").opts(cOpts), proj) != 0)
		{
			t.writelnError("Compilation failed.");
			return ChoiceResult.Error;
		}

		string file = proj.getOutputFile();
		if(std.file.exists(file))
		{
			string newName = getHipPath("build", "android", "project", "app", "src", "main", "jniLibs", "arm64-v8a", "libhipreme_engine.so");
			t.writelnHighlighted("Renaming ", file, " to "~newName~" for compatibility");
			std.file.rename(
				file,
				newName
			);
		}
	}

	return runAndroidApplication(t);
}
