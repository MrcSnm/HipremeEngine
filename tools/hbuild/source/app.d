import std.datetime.stopwatch;
import std.getopt;
import std.conv:to;
import commons;
import global_opts;
import game_selector;

import feature;
import features.hipreme_engine;
import features.ldc;
import features.dmd;

import targets.windows;
import targets.android;
import targets.appleos;
import targets.ios;
import targets.uwp;
import targets.linux;
import targets.wasm;
import targets.psvita;



mixin StartFeatures!([
	"_7zip",
	"dmd",
	"git",
	"hipreme_engine",
	"ldc",
	"java_jdk",
	"android_ldc",
	"android_ndk",
	"android_sdk",
	"msvclinker",
	"vs_buildtools_installer",
	"nuget",
	"vcruntime140"
]);


bool isChoiceAutoSelectable(string selected)
{
	switch(selected)
	{
		version(Windows) case "Windows": return true;
		version(OSX) case "AppleOS": return true;
		version(linux) case "Linux": return true;
		case "Android": return true;
		case "WebAssembly": return true;
		default: return false;
	}
}

Choice* selectChoice(ref Terminal terminal, ref RealTimeConsoleInput input, Choice[] choices)
{
	string currentGame = "Current Game: ";
	if("gamePath" in configs)
		currentGame~= configs["gamePath"].str;

	size_t selectedChoice;
	if("selectedChoice" in configs)
		selectedChoice = configs["selectedChoice"].integer;

	if(autoSelect && autoSelect.isChoiceAutoSelectable)
	{
		import std.algorithm.searching:countUntil;
		selectedChoice = countUntil!"a.name == b"(choices, autoSelect);
	}
	else
	{
		selectedChoice = selectChoiceBase(
			terminal, input, choices, "Select a target platform to build.\n\t"~currentGame~
			(serverStarted ? "\n\tWebAssembly server running at http://"~gameServerHost~":"~gameServerPort.to!string : ""),
			selectedChoice);
	}

	if(!choices[selectedChoice].disableSelectedConfigCache)
	{
		configs["selectedChoice"] = cast(long)selectedChoice;
		updateConfigFile();
	}
	return &choices[selectedChoice];
}

struct Section{string name;}

///Meta struct for the time.
struct EngineVariables
{
	@Section("Android")
	{
		@("SDK Path both found or manually downloaded")
		string androidSdkPath;
		@("NDK Path usually set up after android installation")
		string androidNdkPath;
		@("Java is required for building to Android (Gradle)")
		string javaHome;
	}


	@Section("Compilers")
	{
		@Section("DMD")
		{
			@("Path where DMD is located")
			string dmdPath;
			@("The current DMD path is treated as version")
			string dmdVersion;

			@("Which dub will be used to compile. Useful for dub development test. Automatically inferred from LDC")
			string dubPath;
		}
		@Section("LDC")
		{
			@("Path for the ldc compiler")
			string ldcPath;
			@("The current DMD path is treated as version")
			string ldcVersion;
			@("Required for extracting ldc2 on Windows")
			string _7zip;
		}
		@Section("Tools")
		{
			@("Path where RDMD is located. May be changed to rund or deprecated in the future")
			string rdmdPath;

		}
	}

	@Section("AppleOS")
	{
		@("When true, it executes some special configurations")
		bool firstiOSRun;

		@("When the user change, it may need to let it become the firstiOSRun to be true for removing cache")
		string lastUser;

		@("Required for compiling the XCode project.")
		string phobosLibPath;
	}

	@Section("PSVita")
	{
		@("Used when it was the first time trying to build to PSVita")
		bool firstPsvConfig;

		@("Port in which the PSVita is listening to remote commands. Make the game auto restart when building")
		string psvCmdPort;

		@("IP to use when developing for PSVita for faster iteration when sending files via FTP")
		string psvIp;
	}

	@Section("Engine")
	{
		@("Required for compiling your game together with the engine")
		string gamePath;

		@("Required for putting the copying the game folder to the engine build path")
		string hipremeEnginePath;

		@("Paths which will be shown in the 'Select Game' command. You may add it manually")
		string[] projectsAvailable;

		@("Which source code editor must be opened whenever you select a game to build")
		string sourceCodeEditor;

		@Section("Autos")
		{
			@("Which compiler is currently being used")
			Compilers selectedCompiler;

			@("Cache for last selected choice")
			uint selectedChoice;
		}
	}
}
string repeat(string a, long n)
{
    if(n <= 0) return "";
    char[] ret = new char[](n*a.length);
    foreach(time; 0..n)
    {
        ret[time*a.length..(time+1)*a.length] = a[];
    }
    return cast(string)ret;
}

string generateHelp(T)()
{
	static string generated;
	if(generated is null)
	{
        string[16] sectionCacheCheck;
		int identLevel = 0;
		static foreach(member; __traits(allMembers, T))
        {{
            alias mem = __traits(getMember, T, member);
            alias att = __traits(getAttributes, mem);
            alias sections = att[0..$-1];
			static foreach(i; 0..sections.length)
            {
               	if(sectionCacheCheck[i] != sections[i].name)
                {
               		generated~= "\t".repeat(i) ~ " -- " ~ sections[i].name;
                    sectionCacheCheck[i] = sections[i].name;
	                generated ~= "\n";
                }
            }
            identLevel = sections.length;
            generated~= "\n"~"\t".repeat(identLevel) ~ typeof(mem).stringof~ " "~member ~ "\n" ~ "\t".repeat(identLevel+1) ~ att[$-1]~"\n";
        }}
	}
	return generated;
}

void promptForConfigCreation(ref Terminal t)
{
	string gamePath = buildNormalizedPath(configs["hipremeEnginePath"].str, "projects", "start_here");
	string phobosLibPath;
	version(OSX)
	{
		if(std.file.exists("/Library/D/dmd/lib/"))
		{
			phobosLibPath = "/Library/D/dmd/lib/";
			t.writelnHighlighted("Found phobosLibPath in /Library/D/dmd/lib. `which` won't be executed.");
			goto saveConfig;
		}
	}
	if(!phobosLibPath)
		phobosLibPath = findProgramPath("dmd");
	if(!phobosLibPath)
	{
		t.writeln("Phobos path wasn't found in dmd, searching for ldc.");
		phobosLibPath = findProgramPath("ldc2");
		if(!phobosLibPath)
		{
			phobosLibPath = getValidPath(t, "Phobos path wasn't found in ldc, type your path manually: ");
			goto saveConfig;
		}
	}

	///Strip Exe from findProgramPath
	phobosLibPath = buildNormalizedPath(phobosLibPath, "../../");
	phobosLibPath = getFirstExisting(phobosLibPath, "lib", "lib64");

	saveConfig:

	configs["gamePath"] = gamePath;
	configs["phobosLibPath"] = phobosLibPath;
	configs["selectedChoice"] = 0;
	t.writeln("Saving your ", ConfigFile);
	updateConfigFile();
}

ChoiceResult createProject(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	import project.folder_selector;
	import project.gen;
	import std.array;

	string projectPath, err;
	if(!selectFolderForProject(t, projectPath, err))
	{
		t.writelnError(err);
		return ChoiceResult.Back;
	}
	string projName = pathSplitter(projectPath).array[$-1];
	if(generateProject(t, projectPath, configs["hipremeEnginePath"].str, DubProjectInfo("HipremeEngine", projName), TemplateInfo()))
	{
		if(!("projectsAvailable" in configs))
			configs["projectsAvailable"] = [projectPath];
		else
			configs["projectsAvailable"].array ~= JSONValue(projectPath);
	}

	changeGamePath(t, projectPath);
	configs["selectedChoice"] = 0;
	updateConfigFile();
	return ChoiceResult.Back;
}

ChoiceResult releaseGame(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	import std.net.curl;
	outputTemplate(t, buildPath(configs["hipremeEnginePath"].str, "tools", "build", "targets", "uwp"));
	downloadFileIfNotExists("Visual C Redist.", "https://aka.ms/vs/17/release/vc_redist.x64.exe", "target.exe", t, input);
	std.file.remove("target.exe");

	return ChoiceResult.Continue;
}

ChoiceResult changeCompiler(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(("selectedCompiler" in configs) is null)
		configs["selectedCompiler"] = 0;
	configs["selectedCompiler"] = (configs["selectedCompiler"].get!int + 1) % compilers.length;
	c.name = c.updateChoice();
	updateConfigFile();
	return ChoiceResult.Back;
}

string updateSelectedCompiler()
{
	if(!("selectedCompiler" in configs))
		configs["selectedCompiler"] = 0, updateConfigFile();
	return "Selected Compiler: "~compilers[configs["selectedCompiler"].get!uint];
}

ChoiceResult exitFn(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	return ChoiceResult.Continue;
}

CompilationOptions cOpts;

bool scriptOnly;
string autoSelect;
string createProjectToFolder;

void main(string[] args)
{
	Terminal terminal;
	RealTimeConsoleInput input;
	try
	{
		terminal = Terminal(new arsd.terminal.Terminal(ConsoleOutputType.linear));
		input = RealTimeConsoleInput(new arsd.terminal.RealTimeConsoleInput(terminal.arsdTerminal, ConsoleInputFlags.raw));
	}
	catch(Exception e)
	{
		terminal = Terminal.init;
		input = RealTimeConsoleInput.init;
		terminal.writeln("This terminal will only be able to output... No interaction will be available");
	}
	terminal.clear();
	if(!("PATH" in environment))
		environment["PATH"] = "";
	pathBeforeNewLdc = environment["PATH"];


	if(!LDCFeature.getFeature(terminal, input, TargetVersion.fromGameBuild("ldcVersion")))
	{
		terminal.writelnError("HipremeEngine needs LDC");
		return;
	}
	if(!DMDFeature.getFeature(terminal, input, TargetVersion.fromGameBuild("dmdVersion")))
	{
		terminal.writelnError("HipremeEngine needs DMD");
		return;
	}
	if(!HipremeEngineFeature.getFeature(terminal, input))
	{
		terminal.writelnError("HipremeEngine needs a copy of its repository to run.");
		return;
	}
	if(("hipremeEnginePath" in configs) is null ||
	   ("gamePath" in configs) is null ||
	   ("phobosLibPath" in configs) is null || 
	   ("selectedChoice" in configs) is null)
	{
		terminal.writelnError("ConfigFile is corrupted. Requesting reconfiguration.");
		terminal.flush;
		promptForConfigCreation(terminal);
	}
	engineConfig["builderPath"] = args[0];
	updateEngineFile();

	if(args.length > 1)
	{
		auto opts = getopt(args, 
			"force", "Force for a recompilation", &cOpts.force,
			"dubVerbose", "Builds with --verbose in dub", &cOpts.dubVerbose,
			"projectPath", "Path where the project will be generated. If no path is given, this program will popup a window prompting for selection.",&createProjectToFolder,
			"scriptOnly", "Only the script will be built, internally used for rebuilding", &scriptOnly,
			"appleClean", "Used to clean appleos/ios build. Useful for when your build is failing", &appleClean,
			"autoSelect", "Execute a compilation option without needing to select", &autoSelect,
		);
		if(opts.helpWanted)
		{
			char[] output = new char[](8196);
			output[] = 0;
			defaultGetoptFormatter(output, "Operate the builder without selecting", opts.options);

			terminal.writeln("gamebuild.json documentation:\n" ~ generateHelp!EngineVariables);
			terminal.writeln(output);

			return;
		}
	}
	if(!("DUB" in environment))
		environment["DUB"] = getDubPath();
	Choice[] choices;
	version(Windows)
	{
		choices~= Choice("Windows", &prepareWindows, false, null, scriptOnly);
		choices~= Choice("UWP", &prepareUWP, true);
	}
	version(OSX) 
	{
		choices~= Choice("AppleOS", &prepareAppleOS, false, null, scriptOnly);
		choices~= Choice("iOS", &prepareiOS, false, null, scriptOnly);
	}
	version(linux) choices~= Choice("Linux", &prepareLinux, false, null, scriptOnly);

	choices~=[
		Choice("Android", &prepareAndroid, true),
		Choice("WebAssembly", &prepareWASM, true),
		Choice("PSVita", &preparePSVita, true),
		Choice("Create Project", &createProject),
		Choice("Select Game", &selectGameFolder),
		Choice("Release Game", &releaseGame),
		Choice("Selected Compiler: ", &changeCompiler, false, &updateSelectedCompiler),
		Choice("Exit", &exitFn, false, null, false, true)
	];

	bool usesDflags = "DFLAGS" in environment;
	string preDflags = usesDflags ? environment["DFLAGS"] : null;
	StopWatch sw = StopWatch(AutoStart.yes);
	while(true)
	{
		Choice* selection = selectChoice(terminal, input, choices);
		if(selection.shouldTime)
			sw.reset();
	
		ChoiceResult res;
		try
		{
			res = selection.onSelected(selection, terminal, input, cOpts);
		}
		catch(Exception e)
		{
			terminal.flush;
			terminal.writelnError(e.toString);
		}

		if(usesDflags) environment["DFLAGS"] = preDflags;
		else environment.remove("DFLAGS");

		if(selection.shouldTime)
		{
			import std.conv:to;
			terminal.writelnSuccess("Completed ", selection.name," in ", sw.peek.total!"msecs".to!string, " ms");
		}
		if(selection.name.isChoiceAutoSelectable)
		{
			engineConfig["buildCmd"] = args[0]~" --autoSelect="~selection.name~" --scriptOnly";
			updateEngineFile();
		}
		if(res != ChoiceResult.Continue)
		{
			if(selection.onSelected != &changeCompiler && !autoSelect)
			{
				terminal.writeln("Press Enter to continue");
				while(input.getch != '\n'){}
			}
		}
		else break;
	}
	exitServer(terminal);
	destroy(terminal);
	import core.stdc.stdlib;
	exit(0);
}
