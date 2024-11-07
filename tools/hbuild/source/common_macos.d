module common_macos;
import commons;
import features.git;
import tools.releasegame;
enum XCodeDFolder = "D";

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
    cached(() => timed(t, submoduleLoader.execute(t, input)));
    putResourcesIn(t, getHipPath("build", "appleos", "assets"));

	// executeGameRelease(t);
    //The template may not be present
	cached(() => timed(t, outputTemplate(t, configs["gamePath"].str)));
}

void cleanAppleOSLibFolder()
{
    string targetDir = getHipPath("build", "appleos", XCodeDFolder, "libs");
    if(std.file.exists(targetDir))
        std.file.rmdirRecurse(targetDir);
    std.file.mkdirRecurse(targetDir);
}


import features.ruby_gem;
Feature[] requiredGems;

static this()
{
	requiredGems = [
		FeatureMakeRubyGem("xcodeproj", "Used for updating HipremeEngine.xcodeproj with the current project libraries and compiler"),
		FeatureMakeRubyGem("json", "Used for updating HipremeEngine.xcodeproj with the current project libraries and compiler"),
	];

}

void injectLinkerFlagsOnXcode(ref Terminal t, ref RealTimeConsoleInput input, string extraLinkerFlags)
{
	with(WorkingDir(getHipPath("build", "appleos")))
	{
		foreach(ref Feature gem; requiredGems)
			if(!gem.getFeature(t, input))
				throw new Error("Gem is required for continuing building");
		if(t.wait(spawnShell("ruby injectLib.rb "~extraLinkerFlags)) != 0)
			throw new Error("ruby injectLib.rb with flags "~extraLinkerFlags~" failed.");
	}
}


private __gshared string codeSignUuid;
/** 
 * No need to codesign a non release version.
 */
string getCodeSignCommand(ref Terminal t, bool isReleaseVersion = false)
{
	if(isReleaseVersion)
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
	else 
		return "CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ALLOWED=NO";
}

