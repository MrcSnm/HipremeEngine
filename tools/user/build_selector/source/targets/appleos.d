module targets.appleos;
import commons;
import common_macos;
import global_opts;

version(ARM) enum isARM = true;
else version(AArch64) enum isARM = true;
else enum isARM = false;


enum archFolder = isARM ? "arm64" : "x86_64";

ChoiceResult prepareAppleOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	prepareAppleOSBase(c,t,input);

	string out_extraLinkerFlags;
	setupPerCompiler(t, getSelectedCompiler, archFolder, out_extraLinkerFlags);
	cached(() => timed(() => outputTemplateForTarget(t)));
	string codeSignCommand = getCodeSignCommand(t);
	with(WorkingDir(getHipPath))
	{
		cleanAppleOSLibFolder();

		if(timed(() => waitDubTarget(t, __MODULE__, DubArguments().
			command("build").recipe("appleos").deep(true).compiler(getSelectedCompiler).opts(cOpts))) != 0)
		{
			t.writelnError("Could not build for AppleOS.");
			return ChoiceResult.Error;
		}

		runEngineDScript(t, "copylinkerfiles.d", 
			"\"--recipe="~buildPath(getBuildTarget, "dub.json")~"\"",
			getHipPath("build", "appleos", XCodeDFolder, "libs")
		);
		injectLinkerFlagsOnXcode(t, input, out_extraLinkerFlags);
		string path = getHipPath("build", "appleos");
		string clean = appleClean ? "clean " : "";
		with(WorkingDir(path))
		{
			wait(spawnShell(
				"xcodebuild -jobs 8 -configuration Debug -scheme 'HipremeEngine macOS' " ~ clean ~ 
				" build CONFIGURATION_BUILD_DIR=\"bin\" "~ 
				codeSignCommand ~
				" && cd bin && HipremeEngine.app/Contents/MacOS/HipremeEngine")
			);
		}
	}
	return ChoiceResult.Continue;
}
