import arsd.terminal;
static import std.file;
import std.json;
import std.path;
import std.process;

enum ConfigFile = "gamebuild.json";

struct Choice
{
	string name;
	void function(Choice* self, ref Terminal t) onSelected;
	bool opEquals(string choiceName) const
	{
		return name == choiceName;	
	}
}

Choice selectChoice(ref Terminal terminal, ref RealTimeConsoleInput input, Choice[] choices)
{
	bool exit = false;
	size_t selectedChoice = 0;

	Choice ret;
	enum ArrowUp = 983078;
	enum ArrowDown = 983080;

	while(!exit)
	{
		terminal.writeln("Select an option by using W/S or Arrow Up, or Arrow Down and choose it by pressing Enter.");
		foreach(i, choice; choices)
		{
			if(i == selectedChoice)
			{
				terminal.color(Color.green, Color.black);
				terminal.writeln(">> ", choice.name);
			}
			else
			{
				terminal.color(Color.white, Color.black);
				terminal.writeln(choice.name);
			}
		}
		dchar ch;
		bool inputLoop = true;
		while(inputLoop)
		{
			if(ch == 'w' || ch == 'W' || ch == ArrowUp)
			{
				inputLoop = false;
				if(selectedChoice == 0) selectedChoice = choices.length - 1;
				else selectedChoice--;
			}
			else if(ch == 's' || ch == 'S' || ch == ArrowDown)
			{
				selectedChoice = (selectedChoice+1) % choices.length;
				inputLoop = false;
			}
			else if(ch == '\n')
			{
				ret = choices[selectedChoice];
				inputLoop = false;
				exit = true;
			}
			else
				ch =input.getch;
		}
		terminal.clear();
	}
	return ret;
}


string getValidPath(ref Terminal t, string pathRequired)
{
	string path;
	while(true)
	{
		path = t.getline(pathRequired);
		if(std.file.exists(path))
			return path;
	}
}

void checkForEngineVariables()
{
	///Required for putting the copying the game folder to the engine build path
	string hipremeEnginePath;
	///Required for compiling the XCode project.
	string phobosLibPath;
	///Required for compiling your game together with the engine
	string gamePath;
}

string getFirstExisting(string basePath, scope string[] tests...)
{
	foreach(t; tests)
	{
		auto temp = buildNormalizedPath(basePath, t);
		if(std.file.exists(temp)) return temp;
	}
	return "";
}

string findProgramPath(string program)
{
	import std.algorithm:countUntil;
	import std.process;
	string searcher;
	version(Windows) searcher = "where";
	else version(Posix) searcher = "which";
	else static assert(false, "No searcher program found in this OS.");
	auto shellRes = execute([searcher, program]);
    if(shellRes.output)
		return shellRes.output[0..shellRes.output.countUntil("\n")];
   	return null;
}

void writelnHighlighted(ref Terminal t, string what)
{
	t.color(Color.yellow, Color.black);
	t.writeln(what);
	t.color(Color.white, Color.black);
}

void promptForConfigCreation(ref Terminal t)
{
	string hipremeEnginePath;
	if(environment["HIPREME_ENGINE"])
	{
		hipremeEnginePath = environment["HIPREME_ENGINE"];
		t.writelnHighlighted("Using existing environment variable 'HIPREME_ENGINE' for hipremeEnginePath");
	}
	else
		getValidPath(t, "HipremeEngine path: ");
	string gamePath 		 = getValidPath(t, "Your game path: ");
	string phobosLibPath = findProgramPath("dmd");
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


	t.writeln("Saving your ", ConfigFile);
	std.file.write(ConfigFile, 
		"{ \"hipremeEnginePath\": \"" ~ hipremeEnginePath ~ "\"," ~
		"\"gamePath\": \"" ~ gamePath ~ "\","~
		"\"phobosLibPath\": \"" ~ phobosLibPath ~ "\"}"
	);
}

void loadSubmodules()
{
	import std.process;
	if(!findProgramPath("git"))
		throw new Error("Git wasn't found. Git is necessary for loading the engine submodules.");
	execute("git submodule update --init --recursive");
}


__gshared JSONValue configs;

void prepareWASM(Choice* c, ref Terminal t)
{
	loadSubmodules();
}

void putResourcesIn(string where)
{
	execute([
		"rdmd", 
		buildNormalizedPath(configs["hipremeEnginePath"].str, "tools", "build", "copyresources.d"), 
		configs["gamePath"].str,
		where
	]);
}

void runEngineDScript(string script, scope string[] args...)
{
	execute(["rdmd", buildNormalizedPath(configs["hipremeEnginePath"].str, "tools", "build", script)] ~ args);
}

void prepareAppleOS(Choice* c, ref Terminal t)
{
	loadSubmodules();
	string phobosLib = configs["phobosLibPath"].str.getFirstExisting("libphobos2.a", "libphobos.a");
	if(!phobosLib)  throw new Error("Could not find your phobos library");
	std.file.copy(phobosLib, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "appleos", "HipremeEngine D", phobosLib.baseName));
	putResourcesIn(buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "appleos", "assets"));

	if(!environment["HIPREME_ENGINE"])
		environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;
	runEngineDScript("releasegame.d", configs["gamePath"].str);
}

void main()
{
	auto terminal = Terminal(ConsoleOutputType.linear);
	auto input = RealTimeConsoleInput(&terminal, ConsoleInputFlags.raw);

	if(!std.file.exists(ConfigFile))
		promptForConfigCreation(terminal);

	configs = parseJSON(std.file.readText(ConfigFile));
	Choice[] choices;
	version(OSX) choices~= Choice("AppleOS", &prepareAppleOS);

	
	selectChoice(terminal, input, choices~[
		// Choice("PSVita"),
		// Choice("Xbox Series"),
		// Choice("Android"),
		// Choice("Windows"),
		// Choice("Linux"),
		Choice("WebAssembly", &prepareWASM)
	]);

}
