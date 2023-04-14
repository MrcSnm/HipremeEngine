module targets.wasm;
import commons;

void prepareWASM(Choice* c, ref Terminal t, ref RealTimeConsoleInput input)
{

	if(findProgramPath("ldc2") == null)
	{
		t.writelnError("WASM build requires ldc2 in path. Please install it before building to it.");
		return;
	}
	loadSubmodules(t);
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);
	putResourcesIn(t, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "wasm", "build", "assets"));
	environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;


	runEngineDScript(t, "gendir.d", 
		buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "release_game", "assets"),
		buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "wasm", "generated")
	);

	environment["DFLAGS"] = 
		"-I="~buildNormalizedPath(configs["hipremeEnginePath"].str, "modules", "d_std", "source") ~" "~
		"-I="~buildNormalizedPath(configs["hipremeEnginePath"].str, "dependencies", "runtime", "druntime", "arsd-webassembly") ~" " ~
		"-preview=shortenedMethods -L-allow-undefined -d-version=CarelessAlocation";

	std.file.chdir(configs["hipremeEnginePath"].str);
	wait(spawnShell("dub build --compiler=ldc2 --build=debug -c wasm --arch=wasm32-unknown-unknown-wasm"));

	version(Posix) //Seems like dub is not detectign -posix in macOS
	{
		wait(spawnShell("export DFLAGS=\"\" && dub run wasm-sourcemaps -- hipreme_engine.wasm --include-sources=true"));
		wait(spawnShell("mv hipreme_engine.wasm* ./build/wasm/build/"));
	}
	else version(Windows)
	{
		wait(spawnShell("set DFLAGS=\"\" && dub run wasm-sourcemaps -- hipreme_engine.wasm --include-sources=true"));
		wait(spawnShell("move /Y hipreme_engine.wasm* .\\build\\wasm\\build\\"));
	}
}