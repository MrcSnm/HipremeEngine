import arsd.terminal;
static import std.file;
import std.array:join, split;
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
	size_t selectedChoice = configs["selectedChoice"].integer;

	Choice ret;
	enum ArrowUp = 983078;
	enum ArrowDown = 983080;

	while(!exit)
	{
		terminal.color(Color.DEFAULT, Color.DEFAULT);
		terminal.writeln("Select an option by using W/S or Arrow Up/Down and choose it by pressing Enter.");
		foreach(i, choice; choices)
		{
			if(i == selectedChoice)
			{
				terminal.color(Color.green, Color.DEFAULT);
				terminal.writeln(">> ", choice.name);
			}
			else
			{
				terminal.color(Color.DEFAULT, Color.DEFAULT);
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
	configs["selectedChoice"] = selectedChoice;
	std.file.write(ConfigFile, toJSON(configs));
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

void writelnHighlighted(ref Terminal t, scope string[] what...)
{
	t.color(Color.yellow, Color.DEFAULT);
	t.writeln(what.join());
	t.color(Color.DEFAULT, Color.DEFAULT);
}

void writelnSuccess(ref Terminal t, scope string[] what...)
{
	t.color(Color.green, Color.DEFAULT);
	t.writeln(what.join());
	t.color(Color.DEFAULT, Color.DEFAULT);
}

void writelnError(ref Terminal t, scope string[] what...)
{
	t.color(Color.red, Color.DEFAULT);
	t.writeln(what.join());
	t.color(Color.DEFAULT, Color.DEFAULT);
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


	t.writeln("Saving your ", ConfigFile);
	std.file.write(ConfigFile, 
		"{ \"hipremeEnginePath\": \"" ~ hipremeEnginePath ~ "\"," ~
		"\"gamePath\": \"" ~ gamePath ~ "\","~
		"\"phobosLibPath\": \"" ~ phobosLibPath ~
		"\", \"selectedChoice\": 0}"
	);
}

void loadSubmodules(ref Terminal t)
{
	import std.process;
	if(!findProgramPath("git"))
		throw new Error("Git wasn't found. Git is necessary for loading the engine submodules.");
	t.writelnSuccess("Updating Git Submodules");
	t.flush;
	executeShell("git submodule update --init --recursive");
}


__gshared JSONValue configs;

void runEngineDScript(ref Terminal t, string script, scope string[] args...)
{
	t.writeln("Executing engine script ", script, " with arguments ", args);
	t.flush;
	auto output = execute(["rdmd", buildNormalizedPath(configs["hipremeEnginePath"].str, "tools", "build", script)] ~ args);
	if(output.status)
	{
		t.writelnError("Script ", script, " failed with: ", output.output);
		t.flush;
		throw new Error("Failed on engine script");
	}
}

void putResourcesIn(ref Terminal t, string where)
{
	runEngineDScript(t, "copyresources.d", buildNormalizedPath(configs["gamePath"].str, "assets"), where);
}

void prepareWASM(Choice* c, ref Terminal t)
{

	if(findProgramPath("ldc2") == null)
	{
		t.writelnError("WASM build requires ldc2 in path. Please install it before building to it.");
		return;
	}
	loadSubmodules(t);
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


void prepareAppleOS(Choice* c, ref Terminal t)
{
	loadSubmodules(t);
	string phobosLib = configs["phobosLibPath"].str.getFirstExisting("libphobos2.a", "libphobos.a");
	if(phobosLib == null) throw new Error("Could not find your phobos library");
	string outputPhobos = buildNormalizedPath(
		configs["hipremeEnginePath"].str, 
		"build", "appleos", "HipremeEngine D",
		"static"
	);
	std.file.mkdirRecurse(outputPhobos);
	outputPhobos = buildNormalizedPath(outputPhobos, phobosLib.baseName);
	t.writelnSuccess("Copying phobos to XCode ", phobosLib, "->", outputPhobos);
	t.flush;
	std.file.copy(phobosLib, outputPhobos);
	putResourcesIn(t, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "appleos", "assets"));
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);

	environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;

	t.writelnSuccess("Building your game for AppleOS");
	t.flush;

	string script = import("appleosbuild.sh");
	t.writeln("Executing script appleosbuild.sh");
	t.flush;

	auto pid = spawnShell(script);
	wait(pid);
}

void main()
{
	auto terminal = Terminal(ConsoleOutputType.linear);
	auto input = RealTimeConsoleInput(&terminal, ConsoleInputFlags.raw);
	terminal.clear();

	if(!std.file.exists(ConfigFile))
		promptForConfigCreation(terminal);
	configs = parseJSON(std.file.readText(ConfigFile));
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
	Choice[] choices;
	version(OSX) choices~= Choice("AppleOS", &prepareAppleOS);

	
	Choice selection = selectChoice(terminal, input, choices~[
		// Choice("PSVita"),
		// Choice("Xbox Series"),
		// Choice("Android"),
		// Choice("Windows"),
		// Choice("Linux"),
		Choice("WebAssembly", &prepareWASM)
	]);
	if(selection.onSelected) selection.onSelected(&selection, terminal);

}
