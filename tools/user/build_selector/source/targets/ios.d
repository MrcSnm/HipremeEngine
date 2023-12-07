module targets.ios;
import common_macos;
import commons;
import global_opts;

enum iosArch =
[
	"simulator" : "x86_64",
	"hardware"  : "arm64"
];

ChoiceResult prepareiOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	string buildTarget = getBuildTarget("appleos");
	string arch = iosArch["simulator"];
	prepareAppleOSBase(c,t,input);

	string out_extraLinkerFlags;
	setupPerCompiler(t, "ldc2", "ios-"~arch, out_extraLinkerFlags);
	injectLinkerFlagsOnXcode(t, input, out_extraLinkerFlags);
	if(!("lastUser" in configs))
	{
		configs["lastUser"] = environment["USERNAME"];
		configs["firstiOSRun"] = true;
	}
	if(environment["USERNAME"] != configs["lastUser"].str)
		configs["firstiOSRun"] = true;
	
	appleClean = configs["firstiOSRun"].boolean;

	cached(() => timed(() => outputTemplateForTarget(t, buildTarget)));
	string codeSignCommand = getCodeSignCommand(t);

	with(WorkingDir(getHipPath))
	{
		cleanAppleOSLibFolder();

		if(timed(() => waitDubTarget(t, buildTarget, DubArguments().
			command("build").recipe("appleos").deep(true).arch(arch~"-apple-ios12.0").compiler("ldc2").opts(cOpts))) != 0)
		{
			t.writelnError("Could not build for AppleOS.");
			return ChoiceResult.Error;
		}
		runEngineDScript(t, "copylinkerfiles.d", 
			"\"--recipe="~buildPath(buildTarget, "dub.json")~"\"",
			getHipPath("build", "appleos", XCodeDFolder, "libs")
		);
		
		string path = getHipPath("build", "appleos");
		string clean = appleClean ? "clean " : "";

		
		with(WorkingDir(path))
		{
			wait(spawnShell(
				"xcodebuild -jobs 8 -configuration Debug -scheme 'HipremeEngine iOS' " ~
				clean ~
				"build CONFIGURATION_BUILD_DIR=\"bin\" "~ 
				codeSignCommand ~
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
