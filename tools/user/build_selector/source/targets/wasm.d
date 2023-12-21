module targets.wasm;
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
	cached(() => timed(() => loadSubmodules(t, input)));
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

	std.file.chdir(configs["hipremeEnginePath"].str);
	if(timed(() =>waitDubTarget(t, "wasm", DubArguments()
		.command("build").compiler("ldc2").build("debug")
		.arch("wasm32-unknown-unknown-wasm").opts(cOpts))) != 0)
	{
		t.writelnError("Could not build for WebAssembly.");
		return ChoiceResult.Error;
	}
	environment["DFLAGS"]= "";
	timed(() => waitDub(t, DubArguments().command("run wasm-sourcemaps").runArgs("hipreme_engine.wasm --include-sources=true")));

	int mvStatus;
	version(Posix) //Seems like dub is not detectign -posix in macOS
	{
		mvStatus = wait(spawnShell("mv hipreme_engine.wasm* ./build/wasm/build/"));
	}
	else version(Windows)
	{
		mvStatus = wait(spawnShell("move /Y hipreme_engine.wasm* .\\build\\wasm\\build\\"));
	}
	if(mvStatus)
	{
		t.writelnError("Could not move hipreme_engine.wasm file to build\\wasm\\build\\");
	}
	t.writelnSuccess("Succesfully built for WebAssembly. Listening on http://localhost:9000");
	pushWebsocketMessage("reload");

	return ChoiceResult.None;
}