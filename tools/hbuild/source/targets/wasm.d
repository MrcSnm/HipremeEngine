module targets.wasm;
import features.git;
import commons;
import global_opts;
import server;
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

	inParallel(
		cached(() => timed(t, submoduleLoader.execute(t, input))),
		putResourcesIn(t, getHipPath("build", "wasm", "build", "assets")),
		generateDirectoriesJSON(
			getHipPath("build", "release_game", "assets"),
			getHipPath("build", "wasm", "generated")
		),
		//The template may not be present
		outputTemplate(t, configs["gamePath"].str),
	);


	environment["DFLAGS"] = 
		"-I="~getHipPath("modules", "d_std", "source") ~" "~
		"-I="~getHipPath("dependencies", "runtime", "druntime", "arsd-webassembly") ~" " ~
		"-I="~getHipPath("dependencies", "runtime", "druntime", "source") ~" " ~
		"-L-allow-undefined -d-version=CarelessAlocation";


	with(WorkingDir(configs["gamePath"].str))
	{
		ProjectDetails project;
		if(waitRedub(t, DubArguments()
			.command("build").compiler("ldc2").build("debug").configuration("release-wasm")
			.arch("wasm32-unknown-unknown-wasm").opts(cOpts), project ) != 0)
		{
			t.writelnError("Could not build for WebAssembly.");
			return ChoiceResult.Error;
		}
		import wasm_sourcemaps.generate;

		///In the current status, wasm sourcemap generation invalidates cache, but since the compilation is really fast right now
		///We can keep that
		// string[] out_Errors;
		// if(!timed(t, "Generating WASM Sourcemaps ", generateSourceMaps(null, getHipPath("hipreme_engine.wasm"), "D:", shouldEmbed: false, includeSources:true, out_Errors)))
		// 	t.writelnError(out_Errors);
		// if(out_Errors.length) foreach(err; out_Errors)
		// 	t.writelnError(err);

		string file = project.getOutputFile();
		if(std.file.exists(file))
		{
			t.writelnHighlighted("Renaming ", file, " to hipreme_engine.wasm for compatibility");
			std.file.rename(file, getHipPath("build", "wasm", "build", "hipreme_engine.wasm"));
		}
	}
	if(!serverStarted)
	{
		t.writelnHighlighted("Attempt to start WebAssembly development server.");
		startServer(&gameServerPort);
		t.writelnSuccess("Development started at localhost:"~gameServerPort.to!string);
		cached(() => cast(void)openDefaultBrowser("http://localhost:"~gameServerPort.to!string));
	}
	else
	{
		t.writelnSuccess("Succesfully built for WebAssembly. Listening on http://localhost:"~gameServerPort.to!string);
		pushWebsocketMessage("reload");
	}



	return ChoiceResult.None;
}