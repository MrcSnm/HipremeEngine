module targets.wasm;
import commons;

ChoiceResult prepareWASM(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(!hasLdc)
	{
		t.writelnError("WASM build requires ldc2 in path. Please install it before building to it.");
		return ChoiceResult.Error;
	}
	cached(() => timed(() => loadSubmodules(t, input)));
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);
	putResourcesIn(t, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "wasm", "build", "assets"));
	environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;


	runEngineDScript(t, "gendir.d", 
		buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "release_game", "assets"),
		buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "wasm", "generated")
	);
	cached(() => timed(() => outputTemplateForTarget(t)));
	//The template may not be present
	outputTemplate(configs["gamePath"].str);

	environment["DFLAGS"] = 
		"-I="~buildNormalizedPath(configs["hipremeEnginePath"].str, "modules", "d_std", "source") ~" "~
		"-I="~buildNormalizedPath(configs["hipremeEnginePath"].str, "dependencies", "runtime", "druntime", "arsd-webassembly") ~" " ~
		"-preview=shortenedMethods -L-allow-undefined -d-version=CarelessAlocation";

	std.file.chdir(configs["hipremeEnginePath"].str);
	if(timed(() =>waitDubTarget(t, "wasm", "build --parallel --compiler=ldc2 --build=debug --arch=wasm32-unknown-unknown-wasm"~cOpts.getDubOptions)) != 0)
	{
		t.writelnError("Could not build for WebAssembly.");
		return ChoiceResult.Error;
	}
	environment["DFLAGS"]= "";
	timed(() => waitDub(t, "run wasm-sourcemaps -- hipreme_engine.wasm --include-sources=true"));

	version(Posix) //Seems like dub is not detectign -posix in macOS
	{
		wait(spawnShell("mv hipreme_engine.wasm* ./build/wasm/build/"));
	}
	else version(Windows)
	{
		wait(spawnShell("move /Y hipreme_engine.wasm* .\\build\\wasm\\build\\"));
	}
	t.writelnSuccess("Succesfully built for WebAssembly.");
	t.writelnHighlighted("Run `dub` at $HIPREME_ENGINE/build/wasm, for starting a local server for the game.
Your link should be in localhost:9000");

	return ChoiceResult.None;
}