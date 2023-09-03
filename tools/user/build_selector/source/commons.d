module commons;
public import arsd.terminal;
public import std.array:join, split;
public import std.json;
public import std.path;
public import std.process;
public static import std.file;


enum hipremeEngineRepo = "https://github.com/MrcSnm/HipremeEngine.git";
enum ConfigFile = "gamebuild.json";
__gshared Config configs;

string pathBeforeNewLdc;

enum ChoiceResult
{
	None,
	Continue,
	Error,
	Back,
}

struct Choice
{
	string name;
	ChoiceResult function(Choice* self, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions opts) onSelected;
	bool shouldTime;
	bool opEquals(string choiceName) const
	{
		return name == choiceName;	
	}
}

struct Config
{
	JSONValue cfg;

	this(JSONValue js)
	{
		cfg = js;
		if(!("windows" in cfg)) cfg.object["windows"] = JSONValue(string[string].init);
		if(!("posix" in cfg)) cfg["posix"] = JSONValue(string[string].init);
	}
	string toString()
	{
		return cfg.toPrettyString(JSONOptions.doNotEscapeSlashes);
	}

	auto opBinaryRight(string op, R)(const R rhs) const
	if(op == "in")
	{
		version(Windows){return rhs in cfg["windows"];}
		else version(Posix){return rhs in cfg["posix"];}
		else static assert(false, "OS not supported");
	}

	auto opIndexAssign(T)(T value, string obj)
	{
		version(Windows){return cfg["windows"][obj] = value;}
		else version(Posix){return cfg["posix"][obj] = value;}
		else static assert(false, "OS not supported");
	}

	auto opIndex(string obj)
	{
		version(Windows){return cfg["windows"][obj];}
		else version(Posix){return cfg["posix"][obj];}
		else static assert(false, "OS not supported");
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
			terminal.writelnHighlighted(selectionTitle);
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

bool filesExists(string basePath, scope immutable string[] files...)
{
	foreach(f; files)
	{
		auto temp = buildNormalizedPath(basePath, f);
		if(!std.file.exists(temp)) return false;
	}
	return true;
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

string getHipPath(scope string[] paths...)
{
	return buildPath([configs["hipremeEnginePath"].str] ~ paths);
}

string getFirstExistingVar(scope string[] vars...)
{
	foreach(variable; vars)
	{
		if(variable in environment)
			return environment[variable];
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

auto timed(T)(scope T delegate() dg)
{
	import std.datetime.stopwatch;
	import std.stdio;
	StopWatch sw = StopWatch(AutoStart.yes);
	static if(is(T == void))
	{
		dg();
		writeln(sw.peek.total!"msecs", "ms");
	}
	else 
	{
		auto ret = dg();
		writeln(sw.peek.total!"msecs", "ms");
		return ret;
	}
}

struct Session
{
	struct Cache
	{
		size_t line;
		string file;
	}
	bool[Cache] cache;
}
private __gshared Session session;

void cached(scope void delegate() dg, string f = __FILE__, size_t l = __LINE__)
{
	if(!(Session.Cache(l, f) in session.cache))
	{
		session.cache[Session.Cache(l, f)] = true;
		dg();
	}
}

bool pollForExecutionPermission(ref Terminal t, ref RealTimeConsoleInput input, string operation)
{
	dchar shouldPermit;
	t.writelnHighlighted(operation~" [Y]es/[N]o");
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


bool extract7ZipToFolder(string zPath, string outputDirectory, ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!install7Zip("Extracting the file at"~zPath, t, input))
	{
		t.writelnError("This operation requires a 7zip installation.");
		return false;
	}
	if(!std.file.exists(zPath)) 
	{
		t.writelnError("File ", zPath, " does not exists.");
		return false;
	}
	t.writeln("Extracting ", zPath, " to ", outputDirectory);
	t.flush;
	string cwd = std.file.getcwd();

	if(!std.file.exists(outputDirectory))
		std.file.mkdirRecurse(outputDirectory);
	
	std.file.chdir(outputDirectory);
	version(Windows)
		bool ret = executeShell(configs["7zip"].str ~ " x "~zPath~" -y").status == 0;
	else
		bool ret = executeShell("7za x "~zPath~" -y").status == 0;
	std.file.chdir(cwd);
	return ret;
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
		std.file.mkdirRecurse(theDir);
	if(!std.file.exists(outputName))
	{
		if(!pollForExecutionPermission(t, input, "Your system will download a file: "~ purpose))
			return false;
		t.writelnHighlighted("Download started.");
		t.flush;
		download(link, outputName);
		t.writelnSuccess("Download succeeded!");
		t.flush;
	}
	return true;
}


private string getConfigPath()
{
	import core.runtime;
	static string cfgPath;
	if(cfgPath == "")
		cfgPath = buildNormalizedPath(Runtime.args[0].dirName, ConfigFile);
	return cfgPath;
}

void updateConfigFile()
{
	std.file.write(getConfigPath, configs.toString());
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

	if(!("last"))
	executeShell("cd "~ configs["hipremeEnginePath"].str ~ " && " ~ getGitExec~" submodule update --init --recursive");

}

private bool install7Zip(string purpose, ref Terminal t, ref RealTimeConsoleInput input)
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
		else version(Posix)
		{
			configs["7zip"] = "7za";
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


private ChoiceResult _backFn(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	return ChoiceResult.Back;
}
Choice getBackChoice()
{
	return Choice("Back", &_backFn);
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
	import std.datetime.stopwatch;
	StopWatch sw = StopWatch(AutoStart.yes);
	t.writeln("Executing engine script ", script, " with arguments ", args);
	t.flush;
	auto exec = executeShell(configs["rdmdPath"].str ~ " " ~ buildNormalizedPath(configs["hipremeEnginePath"].str, "tools", "build", script)~" " ~ args.join(" "), 
	environment.toAA);
	t.writeln("    Finished in ", sw.peek.total!"msecs", "ms");
	t.writeln(exec.output);
	t.flush;
	if(exec.status)
	{
		t.writelnError("Script ", script, " failed with: ", exec.output);
		t.flush;
		throw new Error("Failed on engine script");
	}
}

string getDubPath()
{
	string dub = buildNormalizedPath(configs["dubPath"].str, "dub");
	version(Windows) dub = dub.setExtension("exe");
	return dub;
}


private string getDubRunCommand(string commands, string preCommands = "", bool confirmKey = false)
{
	string dub = getDubPath();
	version(Windows)
	{
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
	import std.conv:to;

	///Detects the presence of a template file before executing.
	if(absolutePath(configs["hipremeEnginePath"].str) != absolutePath(std.file.getcwd()))
	if(std.file.exists("dub.template.json"))
	{
	
		import template_processor;
		string out_DubFile;
		auto res = processTemplate(std.file.getcwd(), configs["hipremeEnginePath"].str, out_DubFile);
		if(res != TemplateProcessorResult.success)
		{
			t.writelnError(res.to!string, ":", out_DubFile);
			return -1;
		}
		else
		{
			try{std.file.write("dub.json", out_DubFile);}
			catch(Exception e){
				t.writelnError("Could not write dub.json");
				return -1;
			}
		}
	}
	string toExec = getDubRunCommand(commands, preCommands, confirmKey);
	t.writeln(toExec);
	return wait(spawnShell(toExec));
}

int waitDubTarget(ref Terminal t, string target, string commands, string preCommands = "", bool confirmKey = false)
{
	return waitDub(t, commands~" --recipe="~buildPath(getBuildTarget(target), "dub.json"), preCommands, confirmKey);
}

int waitAndPrint(ref Terminal t, Pid pid)
{
	return wait(pid);
}


void putResourcesIn(ref Terminal t, string where)
{
	runEngineDScript(t, "copyresources.d", buildNormalizedPath(configs["gamePath"].str, "assets"), where);
}



string selectInFolder(string selectWhat, string directory, ref Terminal t, ref RealTimeConsoleInput input)
{
	Choice[] choices;
	foreach(std.file.DirEntry e; std.file.dirEntries(directory, std.file.SpanMode.shallow))
		choices~= Choice(e.name, null);
	size_t choice;
	choice = selectChoiceBase(t, input, choices, selectWhat);

	return choices[choice].name;
}

/** 
 * Main difference from selectInFolder is that it returns the choice and also acacepts extra choices.
 * Params:
 *   selectWhat = Description
 *   directory = Directory to iterate
 *   t = 
 *   input = 
 *   extraChoices = May be used to go back or cancel process
 * Returns: Selected choice
 */
Choice* selectInFolderExtra(string selectWhat, string directory, ref Terminal t, ref RealTimeConsoleInput input,
scope Choice[] extraChoices)
{
	Choice[] choices;
	foreach(std.file.DirEntry e; std.file.dirEntries(directory, std.file.SpanMode.shallow))
		choices~= Choice(e.name, null);
	choices~= extraChoices;
	size_t choice;
	choice = selectChoiceBase(t, input, choices, selectWhat);

	return &choices[choice];
}



version(Windows)
{
	import std.windows.registry;
	Key windowsGetKeyWithPath(string[] path...)
	{
		Key hklm = Registry.localMachine;
		if(hklm is null) throw new Error("No HKEY_LOCAL_MACHINE in this system.");
		Key currKey = hklm;
		foreach(p; path)
		{
			try{
				currKey = currKey.getKey(p);
				if(currKey is null) return null;
			}
			catch(Exception e)
			{
				return null;
			}
		}
		return currKey;
	}
}

string getBuildTarget(string target = __MODULE__)
{
	import std.exception:enforce;
	string path = buildPath(configs["hipremeEnginePath"].str, "tools", "build", "targets");
	enforce(std.file.exists(path = buildPath(path, target)), "Target "~target~" does not exists.");
	return path;
}

void outputTemplate(string templatePath)
{
	import template_processor;
	string out_templ;
	processTemplate(templatePath, configs["hipremeEnginePath"].str, out_templ, [
		"TARGET_PROJECT": configs["gamePath"].str
	]);
	std.file.write(buildPath(templatePath, "dub.json"), out_templ);
}

void outputTemplateForTarget(ref Terminal t, string target = __MODULE__)
{
	import std.array:split;
	///If it is the default, the target will be "targets.wasm", so, split and get the last.
	string buildTarget = getBuildTarget(target.split(".")[$-1]);
	t.writeln("Regenerating buildscript for target ", buildTarget);
	outputTemplate(buildTarget);
}

void requireConfiguration(string cfgRequired, string purpose, ref Terminal t, ref RealTimeConsoleInput input)
{
	if(!(cfgRequired in configs))
	{
		configs[cfgRequired] = t.getline("Config '"~cfgRequired~"' is required for "~ purpose~ ". \n\tWrite here: ");
		updateConfigFile();
	}
}

/** 
* 
* Params:
*   original = The original path where the link will redirect
*   link = The path where the link will be created
*/
void symlink(string original, string link)
{
	version(Posix){
		std.file.symlink(original, link);
	}
	version(Windows)
	{
		import core.sys.windows.w32api:_WIN32_WINNT;
		static if(_WIN32_WINNT >= 0x600) //WindowsVista or later
		{
			import core.sys.windows.winbase;
			import core.sys.windows.windef:DWORD, MAX_PATH, LPWSTR;
			import std.utf:toUTF16z;
			import std.file:FileException;

			DWORD typeFlag = 0; //File
			if(std.file.isDir(original))
				typeFlag = SYMBOLIC_LINK_FLAG_DIRECTORY;
			typeFlag|= SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE;

			if(link.length > MAX_PATH) link = `\\?\`~link;
			if(original.length > MAX_PATH) original = `\\?\`~original;

			if(!CreateSymbolicLinkW(link.toUTF16z, original.toUTF16z, typeFlag))
			{
				LPWSTR strBuffer;
				DWORD length = FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, null, GetLastError(),0, cast(LPWSTR)&strBuffer, 0, null);
				wchar[] str = new wchar[length];
				str[] = strBuffer[0..str.length];
				LocalFree(strBuffer);
				import std.conv;
				throw new FileException(original, str.to!string);
			}
		}
	}
}


/** 
 * May be used in future. Kept for reference.
 */
private bool hasAdminRights()
{
	version(Windows)
	{
		///https://stackoverflow.com/questions/8046097/how-to-check-if-a-process-has-the-administrative-rights
		import core.sys.windows.windows;
		bool hasRights = false;
		HANDLE hToken = NULL;
		if( OpenProcessToken( GetCurrentProcess( ),TOKEN_QUERY,&hToken ) ) {
			TOKEN_ELEVATION Elevation;
			DWORD cbSize = TOKEN_ELEVATION.sizeof;
			if(GetTokenInformation(hToken, TOKEN_INFORMATION_CLASS.TokenElevation, &Elevation, Elevation.sizeof, &cbSize))
				hasRights = Elevation.TokenIsElevated == 1;
		}
		if(hToken) CloseHandle(hToken);
		return hasRights;
	}
	else return false;
}

static this()
{
	if(std.file.exists(getConfigPath))
		configs = Config(parseJSON(std.file.readText(getConfigPath)));
	else
		configs = Config(parseJSON("{}"));
}