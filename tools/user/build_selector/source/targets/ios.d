module targets.ios;
import common_macos;
import commons;

enum iosArch =
[
	"simulator" : "x86_64",
	"hardware"  : "arm64"
];

private __gshared string codeSignUuid;

ChoiceResult prepareiOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	string buildTarget = getBuildTarget("appleos");
	string arch = iosArch["simulator"];
	prepareAppleOSBase(c,t,input);

	string out_extraLinkerFlags;
	setupPerCompiler(t, "ldc2", "ios-"~arch, out_extraLinkerFlags);

	cached(() => timed(() => outputTemplateForTarget(t, buildTarget)));

	cached(
	{
		auto res = executeShell("security find-identity -v -p codesigning");
		if(res.status)
			throw new Error("Could not get codesigning UUID for building to iOS");
		import std.string:indexOf, chomp;
		string uuid = res.output;
		codeSignUuid = uuid[uuid.indexOf(')')+1..uuid.indexOf('"')].chomp;
		t.writelnHighlighted("CodeSign UUID: ", codeSignUuid);
	});
	

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

		
		with(WorkingDir(path))
		{
			wait(spawnShell(
				"xcodebuild -jobs 8 -configuration Debug -scheme 'HipremeEngine iOS' clean build CONFIGURATION_BUILD_DIR=\"bin\" "~ 
				"PROVISIONING_PROFILE='"~codeSignUuid~"' " ~
				"-destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' " ~
				out_extraLinkerFlags ~ " && cd bin && HipremeEngine.app/Contents/iOS/HipremeEngine")
			);
		}
	}
	return ChoiceResult.Continue;
}
