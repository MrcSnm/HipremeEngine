module targets.appleos;
import commons;

ChoiceResult prepareAppleOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	environment["PATH"] = pathBeforeNewLdc;
	t.writelnHighlighted("LDC not supported for building AppleOS yet. Use system path.");
	t.flush;
	loadSubmodules(t, input);
	string phobosLib = configs["phobosLibPath"].str.getFirstExisting("libphobos2.a", "libphobos.a");
	if(phobosLib == null) throw new Error("Could not find your phobos library");
	string outputPhobos = buildNormalizedPath(
		configs["hipremeEnginePath"].str, 
		"build", "appleos", "HipremeEngine D",
		"static"
	);
	std.file.mkdirRecurse(outputPhobos);
	outputPhobos = buildNormalizedPath(outputPhobos, phobosLib.baseName);
	t.writelnSuccess("Copying phobos to XCode ", phobosLib, "->", outputPhobos);
	t.flush;
	std.file.copy(phobosLib, outputPhobos);
	putResourcesIn(t, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "appleos", "assets"));
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);

	environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;

	t.writelnSuccess("Building your game for AppleOS");
	t.flush;

	cached(() => timed(() => outputTemplateForTarget(t)));
	//The template may not be present
	outputTemplate(configs["gamePath"].str);

	with(WorkingDir(getHipPath))
	{
		string targetDir = getHipPath("build", "appleos", "HipremeEngine D", "libs");
		if(std.file.exists(targetDir))
			std.file.rmdirRecurse(targetDir);
		std.file.mkdirRecurse(targetDir);
		if(timed(() => waitDubTarget(t, getBuildTarget, DubArguments().
			command("build").recipe("appleos").deep(true).compiler("dmd").opts(cOpts))) != 0)
		{
			t.writelnError("Could not build for AppleOS.");
			return ChoiceResult.Error;
		}
		
		with(WorkingDir(getHipPath("build", "appleos")))
		{
			wait(spawnShell(
				"xcodebuild -jobs 8 -configuration Debug -scheme HipremeEngine macOS build CONFIGURATION_BUILD_DIR=\"bin\""~ 
				" && cd bin && HipremeEngine.app/Contents/MacOS/HipremeEngine")
			);
		}
		
		// string script = import("appleosbuild.sh");
		// t.writeln("Executing script appleosbuild.sh");
		// t.flush;

		// auto pid = spawnShell(script);
		// wait(pid);
	}


	return ChoiceResult.Continue;
}
