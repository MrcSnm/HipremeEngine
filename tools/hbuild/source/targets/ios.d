module targets.ios;
import common_macos;
import commons;
import global_opts;


enum TARGET_TYPE = "simulator";
enum iosArch =
[
	"simulator" : "x86_64",
	"hardware"  : "arm64"
];

string getExtraCommand(string type)
{
	if(type == "simulator") return " -sdk iphonesimulator ";
	return "";
}

ChoiceResult prepareiOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	string arch = iosArch[TARGET_TYPE];
	prepareAppleOSBase(c,t,input);

	string out_extraLinkerFlags;
	setupPerCompiler(t, "ldc2", "ios-"~arch, out_extraLinkerFlags);
	injectLinkerFlagsOnXcode(t, input, out_extraLinkerFlags);
	if(!("lastUser" in configs))
	{
		configs["lastUser"] = environment["USER"];
		configs["firstiOSRun"] = true;
	}
	if(environment["USER"] != configs["lastUser"].str)
		configs["firstiOSRun"] = true;
	
	appleClean = configs["firstiOSRun"].boolean;

	string codeSignCommand = getCodeSignCommand(t);
	string extraCommands = getExtraCommand(TARGET_TYPE);

	with(WorkingDir(configs["gamePath"].str))
	{
		cleanAppleOSLibFolder();
		ProjectDetails d;
		if(waitRedub(t, DubArguments().
			command("build").configuration("ios").arch(arch~"-apple-ios12.0").compiler("ldc2").opts(cOpts),
			d,
			getHipPath("build", "appleos", XCodeDFolder, "libs")) != 0)
		{
			t.writelnError("Could not build for AppleOS.");
			return ChoiceResult.Error;
		}
		string clean = appleClean ? "clean " : "";

		with(WorkingDir(getHipPath("build", "appleos")))
		{
			wait(spawnShell(
				"xcodebuild -jobs 8 -configuration Debug -scheme 'HipremeEngine iOS' " ~
				clean ~
				"build CONFIGURATION_BUILD_DIR=\"bin\" "~ 
				codeSignCommand ~ extraCommands ~
				"-destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' " ~
				" && cd bin && HipremeEngine.app/Contents/iOS/HipremeEngine")
			);
		}
	}
	if(configs["firstiOSRun"].boolean)
	{
		configs["firstiOSRun"] = false;
		updateConfigFile();
	}
	return ChoiceResult.Continue;
}
