import std.datetime.stopwatch;
import std.getopt;
import std.conv:to;
import commons;
import d_getter;
import game_selector;
import engine_getter;
import targets.windows;
import targets.android;
import targets.appleos;
import targets.linux;
import targets.wasm;
import targets.psvita;


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
			terminal, input, choices, "Select a target platform to build.\n\t"~currentGame, 
			selectedChoice);
	}


	configs["selectedChoice"] = cast(long)selectedChoice;
	updateConfigFile();
	return &choices[selectedChoice];
}


///Meta struct for the time.
struct EngineVariables
{
	///Required for extracting ldc2 on Windows
	string _7zip;

	///Required for putting the copying the game folder to the engine build path
	string hipremeEnginePath;
	///Required for compiling the XCode project.
	string phobosLibPath;
	///Required for compiling your game together with the engine
	string gamePath;

	///Some may want a custom dub path for executing engine, dub may be installed
	///separately in future for bug fixes
	string dubPath;

	///Path for the ldc compiler
	string ldcPath;
	///Save the ldc version here for checking up to date compiler
	string ldcVersion;


	
	///SDK Path both found or manually downloaded
	string androidSdkPath;
	///NDK Path usually set up after android installation
	string androidNdkPath;
	///Java is required for building to Android (Gradle)
	string javaHome;

	///Cache for last selected choice
	uint selectedChoice;
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

	import std.array:replace;
	gamePath = gamePath.replace("\\", "\\\\");
	phobosLibPath = phobosLibPath.replace("\\", "\\\\");


	configs["gamePath"] = gamePath;
	configs["phobosLibPath"] = phobosLibPath;
	configs["selectedChoice"] = 0;
	t.writeln("Saving your ", ConfigFile);
	updateConfigFile();
}

ChoiceResult createProject(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	string currDir = std.file.getcwd();
	std.file.chdir(buildNormalizedPath(configs["hipremeEnginePath"].str, "tools", "user", "hiper"));
	waitDub(t, DubArguments().runArgs("--engine="~configs["hipremeEnginePath"].str));
	std.file.chdir(currDir);
	configs["selectedChoice"] = 0;
	updateConfigFile();
	return ChoiceResult.Back;
}

ChoiceResult releaseGame(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	import std.net.curl;
	outputTemplate(buildPath(configs["hipremeEnginePath"].str, "tools", "build", "targets", "uwp"));
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
	configs["selectedChoice"] = 0;
	updateConfigFile();
	return ChoiceResult.Continue;
}

CompilationOptions cOpts;

bool scriptOnly;
string autoSelect;

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


	if(!setupD(terminal, input))
	{
		terminal.writelnError("D needs to be installed to use Build Selector.");
		return;
	}
	if(!setupEngine(terminal, input))
	{
		terminal.writelnError("HipremeEngine needs Git.");
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
			"skipRegistry", "Skips dub registry with --skip-registry=all", &cOpts.skipRegistry,
			"scriptOnly", "Only the script will be built, internally used for rebuilding", &scriptOnly,
			"autoSelect", "Execute a compilation option without needing to select", &autoSelect,
			"tempBuild", "Executes dub with --temp-build", &cOpts.tempBuild
		);
		if(opts.helpWanted)
		{
			defaultGetoptPrinter("Operate the builder without selecting", opts.options);
			return;
		}
	}
	if(!("DUB" in environment))
		environment["DUB"] = getDubPath();
	Choice[] choices;
	version(Windows) choices~= Choice("Windows", &prepareWindows, false, null, scriptOnly);
	version(OSX) choices~= Choice("AppleOS", &prepareAppleOS, false, null, scriptOnly);
	version(linux) choices~= Choice("Linux", &prepareLinux, false, null, scriptOnly);

	choices~=[
		// Choice("Xbox Series"),
		Choice("Android", &prepareAndroid, true),
		Choice("WebAssembly", &prepareWASM, true),
		Choice("PSVita", &preparePSVita, true),
		Choice("Create Project", &createProject),
		Choice("Select Game", &selectGameFolder),
		Choice("Release Game", &releaseGame),
		Choice("Selected Compiler: ", &changeCompiler, false, &updateSelectedCompiler),
		Choice("Exit", &exitFn)
	];

	StopWatch sw = StopWatch(AutoStart.yes);
	while(true)
	{
		Choice* selection = selectChoice(terminal, input, choices);
		if(selection.shouldTime)
			sw.reset();
		ChoiceResult res = selection.onSelected(selection, terminal, input, cOpts);
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
}