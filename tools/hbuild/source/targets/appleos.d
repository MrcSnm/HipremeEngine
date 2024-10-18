module targets.appleos;
import commons;
import hconfigs;
import common_macos;
import global_opts;

enum archFolder = isARM ? "arm64" : "x86_64";

ChoiceResult prepareAppleOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	prepareAppleOSBase(c,t,input);

	string out_extraLinkerFlags;
	setupPerCompiler(t, getSelectedCompiler, archFolder, out_extraLinkerFlags);
	string codeSignCommand = getCodeSignCommand(t);
	with(WorkingDir(configs["gamePath"].str))
	{
		cleanAppleOSLibFolder();
		ProjectDetails project;
		if(waitRedub(t, 
			DubArguments().configuration("appleos").compiler(getSelectedCompiler).opts(cOpts), 
			project, 
			getHipPath("build", "appleos", XCodeDFolder, "libs")) != 0)
		{
			t.writelnError("Could not build for AppleOS.");
			return ChoiceResult.Error;
		}

		injectLinkerFlagsOnXcode(t, input, out_extraLinkerFlags);
		string clean = appleClean ? "clean " : "";
		with(WorkingDir(getHipPath("build", "appleos")))
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
