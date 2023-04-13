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

size_t selectChoiceBase(ref Terminal terminal, ref RealTimeConsoleInput input, Choice[] choices, 
	string selectionTitle, size_t selectedChoice = 0)
{
	bool exit;
	enum ArrowUp = 983078;
	enum ArrowDown = 983080;
	while(!exit)
	{
		terminal.color(Color.DEFAULT, Color.DEFAULT);
		if(selectionTitle.length != 0)
			terminal.writeln(selectionTitle);
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
				inputLoop = false;
				exit = true;
			}
			else
				ch =input.getch;
		}
		terminal.clear();
	}
	return selectedChoice;
}

Choice selectChoice(ref Terminal terminal, ref RealTimeConsoleInput input, Choice[] choices)
{
	size_t selectedChoice = selectChoiceBase(
		terminal, input, choices, "Select a target platform to build.", 
		configs["selectedChoice"].integer);

	configs["selectedChoice"] = selectedChoice;
	std.file.write(ConfigFile, toJSON(configs));
	return choices[ret];
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

void prepareLinux(Choice* c, ref Terminal t)
{
	if(!std.file.exists("/usr/include/GL/gl.h"))
	{
		t.writelnError("/usr/include/GL/gl.h wasn't found in your system. This is required for the OpenGL implementation.");
		t.writelnHighlighted("\t The following command will be executed to install it: sudo apt-get install libgl1-mesa-dev");
		t.flush;
		wait(spawnShell("sudo apt-get install libgl1-mesa-dev"));
	}
	auto pid = spawnShell("cd ../../../ && dub");
	wait(pid);
}

string selectInFolder(string directory, ref Terminal t, ref RealTimeConsoleInput input)
{
	Choice[] choices;
	foreach(std.file.DirEntry e; std.file.dirEntries(directory, std.file.SpanMode.shallow))
		choices~= Choice(e.name, null);
	size_t choice;
	choice = selectChoiceBase(t, input, choices, "Select the NDK which you want to use. Remember that only NDK <= 21 is supported.");

	return choices[choice].name;
}

enum FindAndroidNdkResult
{
	NotFound,
	Found,
	MustInstallSdk,
	MustInstallNdk
}

FindAndroidNdkResult tryFindAndroidNDK(ref Terminal t, ref RealTimeConsoleInput input)
{
	if("ANDROID_NDK_HOME" in environment)
	{
		configs["androidNdkPath"] = environment["ANDROID_NDK_HOME"];
		return FindAndroidNdkResult.Found;
	}
	bool isValidNDK(string chosenNDK)
	{
		import std.conv:to;
		int ndkVer = chosenNDK[0..2].to!int;
		return ndkVer <= 21;
	}
	version(Windows)
	{
		string locAppData = environment["LOCALAPPDATA"];
		if(locAppData == null)
		{
			t.writelnError("Could not find %LOCALAPPDATA% in your Windows.");
			t.flush;
			return FindAndroidNdkResult.NotFound;
		}
		string tempNdkPath = buildNormalizedPath(locAppData, "Android", "Sdk");
		if(!std.file.exists(tempNdkPath))
		{
			t.writelnError("Could not find ", tempNdkPath, ". You need to install Android SDK.");
			t.flush;
			return FindAndroidNdkResult.MustInstallSdk;
		}
		tempNdkPath = buildNormalizedPath(tempNdkPath, "ndk");
		if(!std.file.exists(tempNdkPath))
		{
			t.writelnError("Could not find ", tempNdkPath, ". You need to have at least one NDK installed.");
			t.flush;
			return FindAndroidNdkResult.MustInstallNdk;
		}
		do
		{
			string ndkPath = selectInFolder(tempNdkPath, t, input);
			if(isValidNDK(ndkPath))
			{
				tempNdkPath = ndkPath;
				break;
			}
			t.writelnError("Please select a valid NDK (<= 21)");
		} while(true);
		t.writelnSuccess("Chosen "~ tempNdkPath~ " as your NDK.");
		environment["androidNdkPath"] = tempNdkPath;
		return FindAndroidNdkResult.Found;
	}
	else version(linux)
	{
		return FindAndroidNdkResult.NotFound;
	}

}

void prepareAndroid(Choice* c, ref Terminal t)
{

	environment["DFLAGS"]= "-gcc="~configs["androidNdkPath"].str~"toolchains/llvm/prebuild/windows-x86_64/bin/aarch64-linux-android21-clang.cmd " ~
		"-linker="~configs["androidNdkPath"].str~"toolchains/llvm/prebuild/windows-x86_64/bin/aarch64-linux-android-ld.bfd.exe";
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
	version(linux) choices~= Choice("Linux", &prepareLinux);

	
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
