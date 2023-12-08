module common_macos;
import commons;
enum XCodeDFolder = "HipremeEngine_D";

void setupPerCompiler(ref Terminal t, string compiler, string arch, out string extraLinkerFlags)
{
	switch(compiler)	
	{
		default:
		case "auto", "ldc2":
		{
			string outputDruntime = getHipPath("build", "appleos", XCodeDFolder, "static", "libdruntime-ldc.a");
			string ldcLibPath = buildNormalizedPath(configs["ldcPath"].str, "lib-"~arch);
			string druntimeLib = ldcLibPath.getFirstExisting("libdruntime-ldc.a");
			if(druntimeLib == null) 
				throw new Error("DRuntime Library not found on path "~configs["ldcPath"].str);
			t.writelnSuccess("Copying druntime to XCode ", druntimeLib, " -> ", outputDruntime);
			t.flush;
			std.file.copy(druntimeLib, outputDruntime);

			string phobosLib = ldcLibPath.getFirstExisting("libphobos2.a", "libphobos.a", "libphobos2-ldc.a");
			if(phobosLib == null) throw new Error("Could not find your phobos library");
			string outputPhobos = getHipPath("build", "appleos", XCodeDFolder,"static");
			std.file.mkdirRecurse(outputPhobos);
			outputPhobos = buildNormalizedPath(outputPhobos, "libphobos2.a");
			t.writelnSuccess("Copying phobos to XCode ", phobosLib, "->", outputPhobos);
			t.flush;
			std.file.copy(phobosLib, outputPhobos);

			extraLinkerFlags = "-ldruntime-ldc ";
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


void prepareAppleOSBase(Choice* c, ref Terminal t, ref RealTimeConsoleInput input)
{
    cached(() => timed(() => loadSubmodules(t, input)));
    putResourcesIn(t, getHipPath("build", "appleos", "assets"));
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);
    //The template may not be present
	cached(() => timed(() => outputTemplate(t, configs["gamePath"].str)));
}

void cleanAppleOSLibFolder()
{
    string targetDir = getHipPath("build", "appleos", XCodeDFolder, "libs");
    if(std.file.exists(targetDir))
        std.file.rmdirRecurse(targetDir);
    std.file.mkdirRecurse(targetDir);
}

void injectLinkerFlagsOnXcode(ref Terminal t, ref RealTimeConsoleInput input, string extraLinkerFlags)
{
	string[] gemsToInstall = ["xcodeproj", "json"];
	static void installGem(ref Terminal t, ref RealTimeConsoleInput input, string gem)
	{
		if(executeShell("gem list | grep "~gem).status)
		{
			if(!pollForExecutionPermission(t, input ,"Ruby `gem` called '"~gem~"' is not installed, attempt to install?"))
				throw new Error("Can't update HipremeEngine.xcodeproj without installing dependency for ruby script.");
			wait(spawnShell("sudo gem install "~gem));
		}
	}
	with(WorkingDir(getHipPath("build", "appleos")))
	{
		foreach(gem; gemsToInstall)
			installGem(t, input, gem);
		spawnShell("ruby injectLib.rb "~extraLinkerFlags);
	}
}

private __gshared string codeSignUuid;
string getCodeSignCommand(ref Terminal t)
{
	cached(
	{
		auto res = executeShell("security find-identity -v -p codesigning");
		if(res.status)
			throw new Error("Could not get codesigning UUID for building to iOS");
		import std.string:indexOf, chomp;
		string uuid = res.output;
		codeSignUuid = uuid[uuid.indexOf(')')+1..uuid.indexOf('"')].chomp;
		t.writelnHighlighted("CodeSign UUID: ", codeSignUuid);	
	});
	return "PROVISIONING_PROFILE='"~codeSignUuid~"' ";
}