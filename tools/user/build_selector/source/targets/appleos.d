module targets.appleos;
import commons;

enum XCodeDFolder = "HipremeEngine_D";

void setupPerCompiler(ref Terminal t, out string extraLinkerFlags)
{
	switch(getSelectedCompiler)	
	{
		default:
		case "auto", "ldc2":
		{
			string outputDruntime = getHipPath("build", "appleos", XCodeDFolder, "static", "libdruntime-ldc.a");
			string druntimeLib = buildNormalizedPath(configs["ldcPath"].str, "lib-x86_64").getFirstExisting("libdruntime-ldc.a");
			if(druntimeLib == null) 
				throw new Error("DRuntime Library not found on path "~configs["ldcPath"].str);
			t.writelnSuccess("Copying druntime to XCode ", druntimeLib, " -> ", outputDruntime);
			t.flush;
			std.file.copy(druntimeLib, outputDruntime);
			extraLinkerFlags = "OTHER_LDFLAGS=\"-ldruntime-ldc\"";
			break;
		}
		case "dmd":
		{
			string outputDruntime = getHipPath("build", "appleos", XCodeDFolder, "static", "libdruntime-ldc.a");
			if(std.file.exists(outputDruntime)) std.file.remove(outputDruntime);

			string phobosLib = configs["phobosLibPath"].str.getFirstExisting("libphobos2.a", "libphobos.a", "libphobos2-ldc.a");
			if(phobosLib == null) throw new Error("Could not find your phobos library");

			string outputPhobos = getHipPath("build", "appleos", XCodeDFolder,"static");
			std.file.mkdirRecurse(outputPhobos);
			outputPhobos = buildNormalizedPath(outputPhobos, "libphobos2.a");
			t.writelnSuccess("Copying phobos to XCode ", phobosLib, "->", outputPhobos);
			t.flush;
			std.file.copy(phobosLib, outputPhobos);
		}
	}
}


ChoiceResult prepareAppleOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	cached(() => timed(() => loadSubmodules(t, input)));

	string out_extraLinkerFlags;
	setupPerCompiler(t, out_extraLinkerFlags);
	putResourcesIn(t, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "appleos", "assets"));
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);

	environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;

	t.writelnSuccess("Building your game for AppleOS");
	t.flush;

	cached(() => timed(() => outputTemplateForTarget(t)));
	//The template may not be present
	cached(() => timed(() => outputTemplate(configs["gamePath"].str)));

	with(WorkingDir(getHipPath))
	{
		string targetDir = getHipPath("build", "appleos", XCodeDFolder, "libs");
		if(std.file.exists(targetDir))
			std.file.rmdirRecurse(targetDir);
		std.file.mkdirRecurse(targetDir);
		if(timed(() => waitDubTarget(t, getBuildTarget, DubArguments().
			command("build").recipe("appleos").deep(true).compiler("auto").opts(cOpts))) != 0)
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
				"xcodebuild -jobs 8 -configuration Debug -scheme 'HipremeEngine macOS' build CONFIGURATION_BUILD_DIR=\"bin\" "~ 
				out_extraLinkerFlags ~ " && cd bin && HipremeEngine.app/Contents/MacOS/HipremeEngine")
			);
		}
	}


	return ChoiceResult.Continue;
}
