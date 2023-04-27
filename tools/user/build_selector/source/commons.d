module commons;
public import arsd.terminal;
public import std.array:join, split;
public import std.json;
public import std.path;
public import std.process;
public static import std.file;


enum hipremeEngineRepo = "https://github.com/MrcSnm/HipremeEngine.git";
enum ConfigFile = "gamebuild.json";
__gshared JSONValue configs;

string pathBeforeNewLdc;

struct Choice
{
	string name;
	void function(Choice* self, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions opts) onSelected;
	bool opEquals(string choiceName) const
	{
		return name == choiceName;	
	}
}

struct CompilationOptions
{
	bool force;
	string getDubOptions() const
	{
		return force? " --force" : "";
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

string getFirstExisting(string basePath, scope string[] tests...)
{
	foreach(t; tests)
	{
		auto temp = buildNormalizedPath(basePath, t);
		if(std.file.exists(temp)) return temp;
	}
	return "";
}



bool hasLdc()
{
	return ("ldcPath" in configs) !is null;
}

string findProgramPath(string program)
{
	import std.algorithm:countUntil;
	import std.process;
	string searcher;
	version(Windows) searcher = "where";
	else version(Posix) searcher = "which";
	else static assert(false, "No searcher program found in this OS.");
	auto shellRes = executeShell(searcher ~" " ~ program,
	[
		"PATH": environment["PATH"]
	]);
    if(shellRes.status == 0)
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

bool pollForExecutionPermission(ref Terminal t, ref RealTimeConsoleInput input, string operation)
{
	dchar shouldPermit;
	t.writelnHighlighted(operation);
	t.flush;
	while(true)
	{
		shouldPermit = input.getch;
		if(shouldPermit == 'y' || shouldPermit == 'Y') break;
		else if(shouldPermit == 'n' || shouldPermit == 'N') return false;
	}
	return true;
}

bool extractZipToFolder(string zipPath, string outputDirectory, ref Terminal t)
{
	import std.zip;
	ZipArchive zip = new ZipArchive(std.file.read(zipPath));
	if(!std.file.exists(outputDirectory))
	{
		t.writeln("Creating directory ", outputDirectory);
		t.flush;
		std.file.mkdirRecurse(outputDirectory);
	}
	foreach(fileName, archiveMember; zip.directory)
	{
		string outputFile = buildNormalizedPath(outputDirectory, fileName);
		if(!std.file.exists(outputFile))
		{
			if(archiveMember.expandedSize == 0)
				std.file.mkdirRecurse(outputFile);
			else
			{
				string currentDirName = outputFile;
				///For some reason on linux it thinks that .a files are directories
				t.writeln("Extracting ", fileName);
				t.flush;
				currentDirName = currentDirName.dirName;
				if(!std.file.exists(currentDirName))
					std.file.mkdirRecurse(currentDirName);
				std.file.write(outputFile, zip.expand(archiveMember));
			}
		}
	}
	return true;
}


bool extract7ZipToFolder(string zPath, string outputDirectory, ref Terminal t)
{
	if(!std.file.exists(zPath)) 
	{
		t.writelnError("File ", zPath, " does not exists.");
		return false;
	}
	t.writeln("Extracting ", zPath, " to ", outputDirectory);
	t.flush;
	return executeShell(configs["7zip"].str ~ " x -o"~outputDirectory~ " "~zPath).status == 0;
}

version(Posix)
bool extractTarGzToFolder(string tarGzPath, string outputDirectory, ref Terminal t)
{
	if(!std.file.exists(tarGzPath))
	{
		t.writelnError("File ", tarGzPath, " does not exists.");
		return false;
	}
	t.writeln("Extracting ", tarGzPath, " to ", outputDirectory);
	t.flush;
	if(!std.file.exists(outputDirectory))
		std.file.mkdirRecurse(outputDirectory);
	if(executeShell("tar -xf "~tarGzPath~" -C "~outputDirectory).status != 0)
		return false;
	return true;
}

bool makeFileExecutable(string filePath)
{
	version(Windows) return true;
	version(Posix)
	{
		if(!std.file.exists(filePath)) return false;
		import std.conv:octal;
		std.file.setAttributes(filePath, octal!700);
		return true;
	}
}

bool downloadFileIfNotExists(
	string purpose, string link, string outputName,
	ref Terminal t, ref RealTimeConsoleInput input
)
{
	import std.net.curl;
	string theDir = dirName(outputName);
	if(!std.file.exists(theDir))
		mkdirRecurse(theDir);
	if(!std.file.exists(outputName))
	{
		if(!pollForExecutionPermission(t, input, "Your system will download a file: "~ purpose~" [Y]es/[N]o"))
			return false;
		t.writelnHighlighted("Download started.");
		t.flush;
		download(link, outputName);
		t.writelnSuccess("Download succeeded!");
		t.flush;
	}
	return true;
}

void updateConfigFile()
{
	std.file.write(ConfigFile, configs.toPrettyString());
}

string getGitExec()
{
	if("git" in configs)
	{
		version(Windows) return buildNormalizedPath(configs["git"].str, "git.exe");
		else return buildNormalizedPath(configs["git"].str, "git");
	}
	return "git ";
}

bool hasGit()
{
	if(findProgramPath("git")) return true;
	return ("git" in configs) != null;
}

void loadSubmodules(ref Terminal t, ref RealTimeConsoleInput input)
{
	import std.process;
	if(!hasGit)
	{
		if(!installGit(t, input))
			throw new Error("Git wasn't found. Git is necessary for loading the engine submodules.");
	}
	t.writelnSuccess("Updating Git Submodules");
	t.flush;
	executeShell("cd "~ configs["hipremeEnginePath"].str ~ " && " ~ getGitExec~" submodule update --init --recursive");
}

bool install7Zip(string purpose, ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!("7zip" in configs))
	{
		version(Windows)
		{
			if(!downloadFileIfNotExists("Needs 7zip for "~purpose, "https://www.7-zip.org/a/7zr.exe", 
				buildNormalizedPath(std.file.getcwd(), "7z.exe"), t, input
			))
				return false;

			string outFolder = buildNormalizedPath(std.file.getcwd(), "buildtools");
			std.file.mkdirRecurse(outFolder);
			std.file.rename(buildNormalizedPath(std.file.getcwd(), "7z.exe"), buildNormalizedPath(outFolder, "7z.exe"));
			configs["7zip"] = buildNormalizedPath(outFolder, "7z.exe");
			updateConfigFile();
		}
	}
	return true;
}


private string getGitDownloadLink()
{
	version(Windows) return "https://github.com/git-for-windows/git/releases/download/v2.40.1.windows.1/MinGit-2.40.1-64-bit.zip";
	else return "";
}




bool installGit(ref Terminal t, ref RealTimeConsoleInput input)
{
	version(Windows)
	{
		if(!("git" in configs))
		{
			if(!downloadFileIfNotExists("Download Git for getting HipremeEngine's source code.", getGitDownloadLink(), 
			buildNormalizedPath(std.file.tempDir(), "git.zip"), t, input))
			{
				t.writelnError("Could not download git.");
				return false;
			}
			string gitPath = buildNormalizedPath(std.file.getcwd(), "buildtools", "git");
			if(!extractZipToFolder(buildNormalizedPath(std.file.tempDir, "git.zip"), gitPath, t))
			{
				t.writelnError("Could not extract git.");
				return false;
			}
			configs["git"] = buildNormalizedPath(gitPath, "cmd");
			updateConfigFile();
		}
		return true;
	}
	else version(Posix)
	{
		t.writelnError("Please install Git to use build_selector.");
		return false;
	}
}


void runEngineDScript(ref Terminal t, string script, scope string[] args...)
{
	import std.array;
	t.writeln("Executing engine script ", script, " with arguments ", args);
	t.flush;
	string rdmd = buildNormalizedPath(configs["ldcPath"].str, "bin", "rdmd");
	version(Windows) rdmd = rdmd.setExtension("exe");

	auto exec = executeShell(rdmd ~ " " ~ buildNormalizedPath(configs["hipremeEnginePath"].str, "tools", "build", script)~" " ~ args.join(" "), 
	environment.toAA);
	if(exec.status)
	{
		t.writelnError("Script ", script, " failed with: ", exec.output);
		t.flush;
		throw new Error("Failed on engine script");
	}
}


private string getDubRunCommand(string commands, string preCommands = "", bool confirmKey = false)
{
	string dub = buildNormalizedPath(configs["ldcPath"].str, "bin", "dub");
	version(Windows)
	{
		dub = dub.setExtension("exe");
		if(confirmKey)
			commands~= " && pause";
	}
	else version(Posix)
	{
		if(confirmKey) commands~= " && read -p \"Press any key to continue... \" -n1 -s";
	}
	
	return preCommands~dub~" "~commands;
}

Pid runDub(string commands, string preCommands = "", bool confirmKey = false)
{
	return spawnShell(getDubRunCommand(commands, preCommands, confirmKey));
}

int waitDub(ref Terminal t, string commands, string preCommands = "", bool confirmKey = false)
{
	string toExec = getDubRunCommand(commands, preCommands, confirmKey);
	t.writeln(toExec);
	return wait(spawnShell(toExec));
}

int waitAndPrint(ref Terminal t, Pid pid)
{
	return wait(pid);
}


void putResourcesIn(ref Terminal t, string where)
{
	runEngineDScript(t, "copyresources.d", buildNormalizedPath(configs["gamePath"].str, "assets"), where);
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