module targets.wasm;
import features.git;
import commons;
import global_opts;
import serve;
import tools.gendir;
import tools.releasegame;


ChoiceResult prepareWASM(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(!hasLdc)
	{
		t.writelnError("WASM build requires ldc2 in path. Please install it before building to it.");
		return ChoiceResult.Error;
	}
	if(!serverStarted)
	{
		t.writelnHighlighted("Attempt to start WebAssembly development server.");
		startServer();
		t.writelnSuccess("Development started at localhost:9000");
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
		if(timed(t, waitDubTarget(t, "wasm", DubArguments()
			.command("build").compiler("ldc2").build("debug")
			.arch("wasm32-unknown-unknown-wasm").opts(cOpts))) != 0)
		{
			t.writelnError("Could not build for WebAssembly.");
			return ChoiceResult.Error;
		}
		import wasm_sourcemaps.generate;

		string[] out_Errors;
		if(!timed(t, "Generating WASM Sourcemaps ", generateSourceMaps(null, getHipPath("hipreme_engine.wasm"), null, shouldEmbed: true, includeSources:true, out_Errors)))
			t.writelnError(out_Errors);
		foreach(file; ["hipreme_engine.wasm", "hipreme_engine.wasm.map"])
			std.file.copy(file, buildPath("build", "wasm", "build", file));
		t.writelnSuccess("Succesfully built for WebAssembly. Listening on http://localhost:9000");
		pushWebsocketMessage("reload");
		cached(() => cast(void)openDefaultBrowser("http://localhost:9000"));
	}

	return ChoiceResult.None;
}