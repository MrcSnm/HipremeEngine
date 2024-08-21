module targets.wasm;
import features.git;
import commons;
import global_opts;
import serve;
import tools.gendir;
import tools.releasegame;


ChoiceResult prepareWASM(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	import std.conv:to;
	if(!hasLdc)
	{
		t.writelnError("WASM build requires ldc2 in path. Please install it before building to it.");
		return ChoiceResult.Error;
	}
	if(!serverStarted)
	{
		t.writelnHighlighted("Attempt to start WebAssembly development server.");
		startServer(&gameServerPort);
		t.writelnSuccess("Development started at localhost:"~gameServerPort.to!string);
	}

	inParallel(
		cached(() => timed(t, submoduleLoader.execute(t, input))),
		putResourcesIn(t, getHipPath("build", "wasm", "build", "assets")),
		generateDirectoriesJSON(
			getHipPath("build", "release_game", "assets"),
			getHipPath("build", "wasm", "generated")
		),
		//The template may not be present
		outputTemplate(t, configs["gamePath"].str),
		cached(() => timed(t, outputTemplateForTarget(t)))
	);


	environment["DFLAGS"] = 
		"-I="~getHipPath("modules", "d_std", "source") ~" "~
		"-I="~getHipPath("dependencies", "runtime", "druntime", "arsd-webassembly") ~" " ~
		"-L-allow-undefined -d-version=CarelessAlocation";

	with(WorkingDir(getHipPath))
	{
		//In the future, it will be better to make hipreme_engine precompiled and just relink with the game.
		// with(WorkingDir(configs["gamePath"].str))
		// {
		// 	if(timed(t, waitDub(t, DubArguments().command("build").compiler("ldc2").build("debug").arch("wasm32-unknown-unknown-wasm").configuration("release").opts(cOpts)) != 0))
		// 	{
		// 		t.writelnError("Could not build for WebAssembly.");
		// 		return ChoiceResult.Error;	
		// 	}
		// }
		if(timed(t, waitDubTarget(t, "wasm", DubArguments()
			.command("build").compiler("ldc2").build("debug")
			.arch("wasm32-unknown-unknown-wasm").opts(cOpts))) != 0)
		{
			t.writelnError("Could not build for WebAssembly.");
			return ChoiceResult.Error;
		}
		import wasm_sourcemaps.generate;

		///In the current status, wasm sourcemap generation invalidates cache, but since the compilation is really fast right now
		///We can keep that
		string[] out_Errors;
		if(!timed(t, "Generating WASM Sourcemaps ", generateSourceMaps(null, getHipPath("hipreme_engine.wasm"), null, shouldEmbed: true, includeSources:true, out_Errors)))
			t.writelnError(out_Errors);
		foreach(file; ["hipreme_engine.wasm", "hipreme_engine.wasm.map"])
			std.file.rename(file, buildPath("build", "wasm", "build", file));
		t.writelnSuccess("Succesfully built for WebAssembly. Listening on http://localhost:"~gameServerPort.to!string);
		pushWebsocketMessage("reload");
		cached(() => cast(void)openDefaultBrowser("http://localhost:"~gameServerPort.to!string));
	}

	return ChoiceResult.None;
}