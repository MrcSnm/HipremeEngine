module targets.ios;
import common_macos;
import commons;

ChoiceResult prepareiOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	prepareAppleOSBase(c,t,input);

	string out_extraLinkerFlags;
	setupPerCompiler(t, "ldc2", "ios-arm64", out_extraLinkerFlags);

	cached(() => timed(() => outputTemplateForTarget(t, "appleos")));
	

	with(WorkingDir(getHipPath))
	{
		cleanAppleOSLibFolder();

		if(timed(() => waitDubTarget(t, getBuildTarget, DubArguments().
			command("build").recipe("appleos").deep(true).arch("arm64-apple-ios").compiler("ldc2").opts(cOpts))) != 0)
		{
			t.writelnError("Could not build for AppleOS.");
			return ChoiceResult.Error;
		}
		runEngineDScript(t, "copylinkerfiles.d", 
			"\"--recipe="~buildPath(getBuildTarget, "dub.json")~"\"",
			getHipPath("build", "appleos", XCodeDFolder, "libs")
		);
		
		string path = getHipPath("build", "appleos");
		with(WorkingDir(path))
		{
			wait(spawnShell(
				"xcodebuild -jobs 8 -configuration Debug -scheme 'HipremeEngine iOS' build CONFIGURATION_BUILD_DIR=\"bin\" "~ 
				out_extraLinkerFlags ~ " && cd bin && HipremeEngine.app/Contents/iOS/HipremeEngine")
			);
		}
	}
	return ChoiceResult.Continue;
}
