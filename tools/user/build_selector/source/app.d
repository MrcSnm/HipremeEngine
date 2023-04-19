import arsd.terminal;
import commons;
import d_getter;
import targets.android;
import targets.appleos;
import targets.linux;
import targets.wasm;


Choice selectChoice(ref Terminal terminal, ref RealTimeConsoleInput input, Choice[] choices)
{
	size_t selectedChoice = selectChoiceBase(
		terminal, input, choices, "Select a target platform to build.", 
		configs["selectedChoice"].integer);

	configs["selectedChoice"] = selectedChoice;
	std.file.write(ConfigFile, configs.toPrettyString);
	return choices[selectedChoice];
}

///Meta struct for the time.
struct EngineVariables
{
	///Required for putting the copying the game folder to the engine build path
	string hipremeEnginePath;
	///Required for compiling the XCode project.
	string phobosLibPath;
	///Required for compiling your game together with the engine
	string gamePath;
	///Unused yet.
	string androidNdkPath;
}

void promptForConfigCreation(ref Terminal t)
{
	string hipremeEnginePath;
	if("HIPREME_ENGINE" in environment)
	{
		hipremeEnginePath = environment["HIPREME_ENGINE"];
		t.writelnHighlighted("Using existing environment variable 'HIPREME_ENGINE' for hipremeEnginePath");
	}
	else
		hipremeEnginePath = getValidPath(t, "HipremeEngine path: ");
	string gamePath 		 = getValidPath(t, "Your game path: ");
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
	hipremeEnginePath = hipremeEnginePath.replace("\\", "\\\\");
	gamePath = gamePath.replace("\\", "\\\\");
	phobosLibPath = phobosLibPath.replace("\\", "\\\\");


	configs["hipremeEnginePath"] = hipremeEnginePath;
	configs["gamePath"] = gamePath;
	configs["phobosLibPath"] = phobosLibPath;
	configs["selectedChoice"] = 0;
	t.writeln("Saving your ", ConfigFile);
	updateConfigFile();
}


CompilationOptions cOpts;
void main(string[] args)
{
	auto terminal = Terminal(ConsoleOutputType.linear);
	auto input = RealTimeConsoleInput(&terminal, ConsoleInputFlags.raw);
	terminal.clear();
	pathBeforeNewLdc = environment["PATH"];
	if(std.file.exists(ConfigFile))
		configs = parseJSON(std.file.readText(ConfigFile));
	else
		configs = parseJSON("{}");

	if(!setupD(terminal, input))
	{
		terminal.writelnError("D needs to be installed to use Build Selector.");
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
		configs = parseJSON(std.file.readText(ConfigFile));
	}

	if(args.length > 1)
	{
		cOpts = CompilationOptions(args[1] == "--force");
	}
	Choice[] choices;
	version(OSX) choices~= Choice("AppleOS", &prepareAppleOS);
	version(linux) choices~= Choice("Linux", &prepareLinux);

	
	Choice selection = selectChoice(terminal, input, choices~[
		// Choice("PSVita"),
		// Choice("Xbox Series"),
		Choice("Android", &prepareAndroid),
		// Choice("Windows"),
		// Choice("Linux"),
		Choice("WebAssembly", &prepareWASM)
	]);
	if(selection.onSelected) selection.onSelected(&selection, terminal, input, cOpts);

}
