module targets.wasm;
import features.git;
import commons;
import global_opts;
import serve;

ChoiceResult prepareWASM(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(!hasLdc)
	{
		t.writelnError("WASM build requires ldc2 in path. Please install it before building to it.");
		return ChoiceResult.Error;
	}
	cached(() => timed(() => submoduleLoader.execute(t, input)));
	if(!serverStarted)
	{
		t.writelnHighlighted("Attempt to start WebAssembly development server.");
		startServer();
		t.writelnSuccess("Development started at localhost:9000");
	}
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);
	putResourcesIn(t, getHipPath("build", "wasm", "build", "assets"));


	runEngineDScript(t, "gendir.d", 
		getHipPath("build", "release_game", "assets"),
		getHipPath("build", "wasm", "generated")
	);
	cached(() => timed(() => outputTemplateForTarget(t)));
	//The template may not be present
	outputTemplate(t, configs["gamePath"].str);

	environment["DFLAGS"] = 
		"-I="~getHipPath("modules", "d_std", "source") ~" "~
		"-I="~getHipPath("dependencies", "runtime", "druntime", "arsd-webassembly") ~" " ~
		"-L-allow-undefined -d-version=CarelessAlocation";

	with(WorkingDir(getHipPath))
	{
		if(timed(() =>waitDubTarget(t, "wasm", DubArguments()
			.command("build").compiler("ldc2").build("debug")
			.arch("wasm32-unknown-unknown-wasm").opts(cOpts))) != 0)
		{
			t.writelnError("Could not build for WebAssembly.");
			return ChoiceResult.Error;
		}
		environment["DFLAGS"]= "";
		timed(() => waitDub(t, DubArguments().command("run wasm-sourcemaps").runArgs("bin/hipreme_engine.wasm --include-sources=true")));

		foreach(file; ["hipreme_engine.wasm", "hipreme_engine.wasm.map"])
			std.file.rename(buildPath("bin", file), buildPath("build", "wasm", "build", file));
		t.writelnSuccess("Succesfully built for WebAssembly. Listening on http://localhost:9000");
		pushWebsocketMessage("reload");
		cached(() => cast(void)openDefaultBrowser("http://localhost:9000"));
	}

	return ChoiceResult.None;
}