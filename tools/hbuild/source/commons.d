module commons;
public import arsd.terminal : Color, ConsoleOutputType, ConsoleInputFlags;
public static import arsd.terminal;
public import std.array:join, split;
public import std.json;
public import std.path;
public import std.process;
public static import std.file;
public import default_handlers;


enum hipremeEngineRepo = "https://github.com/MrcSnm/HipremeEngine.git";
enum ConfigFile = "gamebuild.json";

JSONValue engineConfig;
Config configs;

string pathBeforeNewLdc;

struct Terminal
{
	import std.stdio;
	arsd.terminal.Terminal* arsdTerminal;
	this(arsd.terminal.Terminal* arsdTerminal)
	{
		this.arsdTerminal = arsdTerminal;
	}

	void color(Color main, Color secondary){if(arsdTerminal) arsdTerminal.color(main, secondary);}
	int cursorY()
	{
		if(arsdTerminal) return arsdTerminal.cursorY;
		return 0;
	}
	string getline(string message)
	{
		if(arsdTerminal) return arsdTerminal.getline(message); 
		std.stdio.writeln("Can't get line with message [", message, "]");
		return "";
	}
	void moveTo(int x, int y){if(arsdTerminal) arsdTerminal.moveTo(x, y);}
	void clear(){if(arsdTerminal) arsdTerminal.clear();}
	void write(T...)(T args)
	{
		if(arsdTerminal) arsdTerminal.write(args);
		else std.stdio.write(args);
	}
	void flush()
	{
		if(arsdTerminal) arsdTerminal.flush();
	}
	void hideCursor(){ if(arsdTerminal) arsdTerminal.hideCursor();}
	void showCursor(){ if(arsdTerminal) arsdTerminal.showCursor();}
	void clearToEndOfLine(){ if(arsdTerminal) arsdTerminal.clearToEndOfLine();}

	void writeln(T...)(T args)
	{
		if (arsdTerminal) arsdTerminal.writeln(args);
		else std.stdio.writeln(args);
	}
	~this()
	{
		if(arsdTerminal) destroy(*arsdTerminal);
	}
}

struct RealTimeConsoleInput
{
	private arsd.terminal.RealTimeConsoleInput* input;
	this(arsd.terminal.RealTimeConsoleInput* input){this.input = input;}
	dchar getch()
	{
		if(input) return input.getch();
		return '\0';
	}
	~this()
	{
		if(input) destroy(*input);
	}
}

struct TerminalColors
{
	private Terminal* _t;
	this(Color main, Color secondary, ref Terminal terminal)
	{
		_t = &terminal;
		_t.color(main, secondary);
	}
	~this()
	{
		_t.color(Color.DEFAULT, Color.DEFAULT);
	}
}

struct WorkingDir
{
	private string _currDir;
	this(string targetDir)
	{
		_currDir = std.file.getcwd();
		std.file.chdir(targetDir);
	}
	~this(){std.file.chdir(_currDir);}
}

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
	string function() updateChoice;
	bool scriptOnly;

	this(string name,
	ChoiceResult function(Choice* self, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions opts) onSelected,
	bool shouldTime = false,
	string function() updateChoice = null, bool scriptOnly = false)
	{
		this.name = updateChoice ? updateChoice() : name;
		this.onSelected = onSelected;
		this.shouldTime = shouldTime;
		this.updateChoice = updateChoice;
		this.scriptOnly = scriptOnly;
	}

	bool opEquals(ref const Choice other) const 
	{
		return name == other.name;
	}
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

	ref auto opIndexAssign(T)(T value, string obj)
	{
		version(Windows){return cfg["windows"][obj] = value;}
		else version(Posix){return cfg["posix"][obj] = value;}
		else static assert(false, "OS not supported");
	}

	ref auto opIndex(string obj)
	{
		version(Windows){return cfg["windows"][obj];}
		else version(Posix){return cfg["posix"][obj];}
		else static assert(false, "OS not supported");
	}
}

struct CompilationOptions
{
	bool dubVerbose;
	bool force;
	bool tempBuild;
	string getDubOptions() const
	{
		string ret;
		if(force) ret~= " --force";
		if(tempBuild) ret~= " --temp-build";
		if(dubVerbose) ret~= " --verbose";
		return ret;
	}
}

T[] unique(T)(T[] input)
{
	bool[T] seen;
	T[] ret;
	foreach(v; input)
	{
		if(!(v in seen))
		{
			seen[v] = true;
			ret~= v;
		}
	}
	return ret;
}

size_t selectChoiceBase(ref Terminal terminal, ref RealTimeConsoleInput input, Choice[] choices, 
	string selectionTitle, size_t selectedChoice = 0)
{
	bool exit;
	enum ArrowUp = 983078;
	enum ArrowDown = 983080;
	enum SelectionHint = "Select an option by using W/S or Arrow Up/Down and choose it by pressing Enter.";
	terminal.clear();
	terminal.color(Color.DEFAULT, Color.DEFAULT);
	terminal.writelnHighlighted(selectionTitle);
	terminal.writeln(SelectionHint);

	static void changeChoice(ref Terminal t, Choice[] choices, string title, Choice current, Choice next, int nextCursorOffset)
	{
		int currCursor = t.cursorY;
		t.moveTo(0, currCursor);
		t.clearToEndOfLine();
		t.write(current.name);

		t.moveTo(0, currCursor+nextCursorOffset);
		t.clearToEndOfLine();
		with(TerminalColors(Color.green, Color.DEFAULT, t))
			t.write(">> ", next.name);
		t.flush;
	}

	static void changeChoiceClear(ref Terminal t, Choice[] choices, string title, Choice current, Choice next, int nextCursorOffset)
	{
		t.color(Color.DEFAULT, Color.DEFAULT);
		t.clear();
		t.writelnHighlighted(title);
		t.writeln(SelectionHint);
		foreach(i, c; choices)
		{
			if(c.name == next.name) with(TerminalColors(Color.green, Color.DEFAULT, t))
				t.writeln(">> ", c.name);
			else t.writeln(c.name);
		}
		t.flush;
	}

	int startLine = terminal.cursorY;
	terminal.color(Color.DEFAULT, Color.DEFAULT);

	foreach(i, choice; choices)
		terminal.write(choice.name, i == choices.length - 1 ? "" : "\n");
	terminal.flush();

	terminal.moveTo(0, startLine + cast(int)selectedChoice);
	terminal.hideCursor();


	size_t oldChoice = selectedChoice;
	while(!exit)
	{
		changeChoiceClear(terminal, choices, selectionTitle, choices[oldChoice], choices[selectedChoice], cast(int)(cast(long)selectedChoice-oldChoice));
		oldChoice = selectedChoice;
		CheckInput: switch(input.getch)
		{
			case 'w', 'W', ArrowUp:
				selectedChoice = (selectedChoice + choices.length - 1) % choices.length;
				break;
			case 's', 'S', ArrowDown:
				selectedChoice = (selectedChoice+1) % choices.length;
				break;
			case '\n':
				exit = true;
				break;
			default: goto CheckInput;
		}
	}
	terminal.moveTo(0, cast(int)startLine);
	foreach(i; 0..choices.length)
		terminal.moveTo(0, cast(int)(startLine+i)), terminal.clearToEndOfLine();
	terminal.moveTo(0, cast(int)startLine);
	terminal.writelnSuccess(">> ", choices[selectedChoice].name);

	terminal.showCursor();
	return selectedChoice;
}

string[] getProjectsAvailable()
{
	import std.array;
	import std.algorithm;
	if(!("projectsAvailable" in configs))
		return [];
	return (configs["projectsAvailable"].array.map!((JSONValue v) => v.str)).array;
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

bool dbgExecuteShell(scope const(char)[] command, ref Terminal t, const string[string] env = null)
{
	t.writeln("Executing command: ", command);
	auto ret = executeShell(command, env);
	if(ret.status)
	{
		t.writelnError(cast(string)("Command '"~command~"' failed with: "~ ret.output));
		t.flush;
	}
	return ret.status == 0;
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
	with(TerminalColors(Color.yellow, Color.DEFAULT, t))
		t.writeln(what.join());
}

void writelnSuccess(ref Terminal t, scope string[] what...)
{
	with(TerminalColors(Color.green, Color.DEFAULT, t))
		t.writeln(what.join());
}

void writelnError(ref Terminal t, scope string[] what...)
{
	with(TerminalColors(Color.red, Color.DEFAULT, t))
		t.writeln(what.join());
}

auto timed(T)(ref Terminal t, scope lazy T val){return timed(t, "", val);}
auto timed(T)(ref Terminal t, string measuringWhat, scope lazy T val)
{
	import std.datetime.stopwatch;
	StopWatch sw = StopWatch(AutoStart.yes);
	static if(is(T == void))
	{
		val;
		t.writeln(measuringWhat, sw.peek.total!"msecs", "ms");
	}
	else 
	{
		auto ret = val;
		t.writeln(measuringWhat, sw.peek.total!"msecs", "ms");
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

/** 
 * Clears all cache.
 * This may be useful after a dub.template.json was already generated.
 * Or for example, after changing the current game.
 */
void clearCache()
{
	session.cache.clear;
}

bool pollForExecutionPermission(ref Terminal t, ref RealTimeConsoleInput input, string operation)
{
	t.writelnHighlighted(operation~" [Y]es/[N]o");
	t.flush;
	while(true)
	{
		switch(input.getch)
		{
			case 'y', 'Y': return true;
			case 'n', 'N': return false;
			default: break;
		}
	}
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


bool isCompactedFile(string fileName)
{
	import std.path;
	switch(fileName.extension)
	{
		case ".gz", ".xz", ".zip", ".7zip", ".7z": return true;
		default: return false;
	}
}


bool extractToFolder(string zPath, string outputDirectory, ref Terminal t, ref RealTimeConsoleInput input)
{
	import features._7zip;
	import std.path;
	switch(zPath.extension)
	{
		case ".gz", ".xz":
			version(Posix)
			{
				return extractTarGzToFolder(zPath, outputDirectory, t);
			}
			else assert(false, "No .tar.gz support on non Posix");
		case ".zip":
			return extractZipToFolder(zPath, outputDirectory, t);
		case ".7zip", ".7z":
			return extract7ZipToFolder.execute(t, input, zPath, outputDirectory);
		default:
			t.writelnError("Could not detect compressed archive type for "~zPath);
			return false;
	}
}

string executableExtension(string path)
{
	version(Windows) return path~".exe";
	return path;
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
	std.file.mkdirRecurse(outputDirectory);
	return dbgExecuteShell("tar -xf "~tarGzPath~" -C "~outputDirectory, t);
}

bool isRecognizedExtension(string ext)
{
	switch(ext)
	{
		case ".7z", ".7zip", ".tar", ".xz", ".zf", ".bz", ".gz", ".zip": return true;
		default: return false;
	}
}

/** 
 * Removes the extension (while keeping numeric extensions such as dmd-2.105.0)
 * Params:
 *   input = Input to remove extension
 * Returns: 
 */
string removeExtension(string input)
{
	import std.string:isNumeric;
	string ext;
	while((ext = input.extension).length && ext.isRecognizedExtension)
		input = input.setExtension("");
	return input;
}

/** 
 * 
 * Params:
 *   purpose = A message for the user to understand what is happening
 *   link = The link to file which will be downloaded to a temp dir
 *   outputName = A file name with a compressed archive extension (e.g: .zip, .7z, .tar.xz)
 *   outputDirectory = Where the file from outputName will be extracted
 *   t = Terminal 
 *   input = RealTimeInput
 * Returns: 
 */
bool installFileTo(string purpose, string link, string outputName,
string outputDirectory, ref Terminal t, ref RealTimeConsoleInput input)
{
	string downloadDir = buildNormalizedPath(std.file.tempDir, outputName);
	if(!downloadFileIfNotExists(purpose, link, downloadDir, t, input))
	{
		t.writelnError("Download failed");
		t.flush;
		return false;
	}


	outputName = outputName.removeExtension;

	string installDir = buildNormalizedPath(outputDirectory, outputName);
	if(!extractToFolder(downloadDir, installDir, t, input))
	{
		t.writelnError("Could not extract ",downloadDir, " to ", installDir);
		return false;
	}

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
	import std.conv:to;
	string theDir = dirName(outputName);
	if(!std.file.exists(theDir))
		std.file.mkdirRecurse(theDir);
	if(!std.file.exists(outputName))
	{
		if(!pollForExecutionPermission(t, input, "Your system will download a file: "~ purpose~"("~link~")"))
			return false;
		t.writelnHighlighted("Download started.");
		t.flush;
		size_t time = downloadWithProgressBar(t, link, outputName);
		t.writelnSuccess("\nDownload succeeded after ", time.to!string, " msecs!");
		t.flush;
	}
	return true;
}

private void terminalProgressBar(ref Terminal t, float percentage, ubyte ticksCount = 32)
{
	assert(percentage <= 1.0 && percentage >= 0, "Invalid percentage.");

	ubyte drawnTicks = cast(ubyte)(ticksCount*percentage);
	int line = t.cursorY;
	t.moveTo(0, line);
	t.clearToEndOfLine();
	t.write("<");
	foreach(int i; 0..ticksCount)
	{
		t.color(i < drawnTicks ? Color.green : Color.red, Color.DEFAULT);
		t.write(i < drawnTicks ? "=" : ".");
	}
	t.color(Color.DEFAULT, Color.DEFAULT);
	t.write("> (", percentage*100, "%)");
	t.flush();
}

///Adds a path to PATH
void addToPath(string pathToAdd)
{
	import std.array:join;
	string concatPath = ":";
    version(Windows) concatPath = ";";
    environment["PATH"] = join([
		pathToAdd,
        environment["PATH"]
    ], concatPath);
}

size_t downloadWithProgress(string url, string saveToPath, void delegate(float t) onProgress, size_t updateDelay = 125)
{
	import std.net.curl:HTTP;
	import core.time:dur;
	import std.datetime.stopwatch:StopWatch, AutoStart;
	import std.stdio : File;
	size_t received, contentLength;
	HTTP conn = HTTP();
	conn.url = url;

	string targetDir = dirName(saveToPath);
	if(!std.file.exists(targetDir))
		std.file.mkdirRecurse(targetDir);

	static void writer(string path)
	{
		auto f = File(path, "wb");
		while(true)
		{
			immutable(ubyte)[] data = receiveOnly!(immutable(ubyte)[]);
			if(data.length == 0)
				break;
			f.rawWrite(data);
		}
		ownerTid.send(true);
	}
	auto writerTid = spawn(&writer, saveToPath);
	StopWatch updateDelayChecker = StopWatch(AutoStart.yes);
	size_t downloadTime;
	conn.onReceive = (ubyte[] data)
	{
		import std.conv:to;
		import std.stdio;
		if(contentLength == 0)
			contentLength = conn.responseHeaders["content-length"].to!size_t;
		received+= data.length;
		if(updateDelayChecker.peek.total!"msecs" >= updateDelay || received == contentLength)
		{
			downloadTime+= updateDelayChecker.peek.total!"msecs";
			onProgress(cast(float)received/contentLength);
			updateDelayChecker.reset();
		}
		send(writerTid, data.idup);
		return data.length;
	};
	conn.perform();
	send(writerTid, (immutable(ubyte)[]).init);
	receiveTimeout(dur!"msecs"(1000), (bool){}); //Block until finish
	return downloadTime; 
}

/**
*	Same as std.net.curl.download
*	Difference is that it shows a progress bar while downloading.
*	Returns the time needed to download.
*/
size_t downloadWithProgressBar(ref Terminal t, string url, string saveToPath, size_t updateDelay = 125)
{
	t.hideCursor();
	scope(exit)
	{
		t.showCursor();
		t.writeln("");
	}
	return downloadWithProgress(url, saveToPath, (float progress)
	{
		terminalProgressBar(t, progress);
	});
}


private string getConfigPath()
{
	import core.runtime;
	static string cfgPath;
	if(cfgPath == "")
		cfgPath = buildNormalizedPath(Runtime.args[0].dirName, ConfigFile);
	return cfgPath;
}
private string getEngineConfigPath()
{
	return getHipPath("bin" ,"desktop", "engine_opts.json");
}
void updateEngineFile()
{
	std.file.write(getEngineConfigPath, engineConfig.toPrettyString());
}
void updateConfigFile()
{
	std.file.write(getConfigPath, configs.toString());
}
string getSourceCodeEditor(string projectPath)
{
	if(!("sourceCodeEditor" in configs) || configs["sourceCodeEditor"].str.length == 0)
	{
		string out_Editor;
		if(getDefaultSourceEditor(buildNormalizedPath(projectPath, "source", "gamescript", "entry.d"), out_Editor))
			configs["sourceCodeEditor"] = out_Editor;
		else
			configs["sourceCodeEditor"] = "";
		updateConfigFile();
	}

	return configs["sourceCodeEditor"].str;
}

bool openSourceCodeEditor(string projectPath)
{
	string sourceEditor = getSourceCodeEditor(projectPath);
	if(!sourceEditor.length)
		return false;

	return executeShell(sourceEditor.escapeShellCommand~" "~projectPath.escapeShellCommand).status == 0;
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



private ChoiceResult _backFn(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	return ChoiceResult.Back;
}
Choice getBackChoice()
{
	return Choice("Back", &_backFn);
}


string getDubPath()
{
	string dub = buildNormalizedPath(configs["dubPath"].str, "dub");
	version(Windows) dub = dub.setExtension("exe");
	return dub;
}

private int execDubBase(ref Terminal t, in DubArguments dArgs)
{
	import std.conv:to;
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
		try std.file.write("dub.json", out_DubFile);
		catch(Exception e){
			t.writelnError("Could not write dub.json");
			return -1;
		}
	}
	return 0;
}


mixin template BuilderPattern(Struct)
{
	static foreach(mem; __traits(allMembers, Struct))
	{
		import std.traits:isFunction;
		static if(!isFunction!(__traits(getMember, Struct, mem)) && mem[0] == '_')
		{
			mixin(typeof(__traits(getMember, Struct, mem)), " ", mem[1..$], "() { return ", mem, ";}",
			Struct, " ", mem[1..$], "(", typeof(__traits(getMember, Struct, mem)), " arg )",
			"{this.",mem, " = arg; return this;}");
		}
	}
}

enum Compilers
{
	automatic = 0,
	ldc2,
	dmd
}


immutable string[] compilers = ["auto", "ldc2", "dmd"];
string getSelectedCompiler()
{
	const(JSONValue)* c = "selectedCompiler" in configs;
	if(!c) return "auto";
	return compilers[c.get!uint];
}


struct DubArguments
{
	string _command;
	string _configuration;
	CompilationOptions _opts;
	string _dir;
	string _preCommands;
	string _compiler = "auto";
	string _arch;
	string _build;
	string _recipe;
	string _runArgs;
	bool _confirmKey;
	bool _deep;
	bool _parallel = true;

	mixin BuilderPattern!(DubArguments);

	string getCompiler()
	{
		if(_compiler == "auto" && _arch)
			_compiler = "ldc2";
		if(_compiler == "ldc2")
			_compiler = buildNormalizedPath(configs["ldcPath"].str, "bin", "ldc2".executableExtension);
		if(_compiler == "auto")
		{
			string ret = getSelectedCompiler();
			return ret == "auto" ? "" : ret;
		}
		return _compiler;
	}
	
	string getDubRunCommand()
	{
		string dub = getDubPath();
		string a = command; ///Arguments
		compiler = getCompiler();
		if(parallel)      a~= " --parallel";
		if(recipe)        a~= " --recipe="~recipe;
		if(build)         a~= " --build="~build;
		if(arch)          a~= " --arch="~arch;
		if(compiler != "")a~= " --compiler="~compiler;
		if(deep)		  a~= " --deep";
		if(configuration) a~= " -c "~configuration;
		if(opts != CompilationOptions.init) a~= opts.getDubOptions();
		if(runArgs)       a~= " -- "~runArgs;


		version(Windows)
		{
			if(confirmKey) a~= " && pause";
		}
		else version(Posix)
		{
			if(confirmKey) a~= " && read -p \"Press any key to continue... \" -n1 -s";
		}
		return preCommands~dub~" "~a;
	}
}

int waitRedub(ref Terminal t, DubArguments dArgs, string copyLinkerFilesTo = null)
{
	import redub.api;
	import redub.logging;
	if(execDubBase(t, dArgs) == -1) return -1;

	setLogLevel(dArgs._opts.dubVerbose ? LogLevel.verbose : LogLevel.info);
	ProjectDetails d = resolveDependencies(
		dArgs._opts.force,
		os,
		CompilationDetails(dArgs.getCompiler(), dArgs._arch),
		ProjectToParse(dArgs._configuration, std.file.getcwd(), null, dArgs._recipe),
		InitialDubVariables.init,
		BuildType.debug_
	);
	if(buildProject(d).error) return 1;
	if(copyLinkerFilesTo.length)
	{
		import tools.copylinkerfiles;
		string[] linkerFiles;
		timed(t, "Copying Linker Files ",
		{
			d.getLinkerFiles(linkerFiles);
			copyLinkerFiles(linkerFiles, copyLinkerFilesTo);
		}());
	}
	return 0;
}

void inParallel(scope void delegate()[] args...)
{
	import std.parallelism;
	foreach(action; parallel(args, 1))
		action();

}

int waitDub(ref Terminal t, DubArguments dArgs, string copyLinkerFilesTo = null)
{
	///Detects the presence of a template file before executing.
	if(dArgs._command.length >= 3 && dArgs._command[0..3] != "run") return waitRedub(t, dArgs, copyLinkerFilesTo);
	if(execDubBase(t, dArgs) == -1) return -1;
	string toExec = dArgs.getDubRunCommand();
	t.writeln(toExec);
	t.flush;
	return wait(spawnShell(toExec));
}

int waitDubTarget(ref Terminal t, string target, DubArguments dArgs, string copyLinkerFilesTo = null)
{
	return waitDub(t, dArgs.recipe(buildPath(getBuildTarget(target), "dub.json")), copyLinkerFilesTo);
}

int waitAndPrint(ref Terminal t, Pid pid)
{
	return wait(pid);
}

public import std.concurrency;
bool waitOperations(immutable bool delegate()[] operations)
{
	foreach(op; operations)
	{
		spawn((bool delegate() targetOperation)
		{
			ownerTid.send(targetOperation());
		}, op);
	}

	foreach(i; 0..operations.length)
		if(!receiveOnly!bool) 
			return false;
	return true;
}


void putResourcesIn(ref Terminal t, string where)
{
	import tools.copyresources;
	copyResources(t, buildNormalizedPath(configs["gamePath"].str, "assets"), where, false);
}

void executeGameRelease(ref Terminal t)
{
	import tools.releasegame;
	releaseGame(t, configs["gamePath"].str, getHipPath("build", "release_game"), false);
}



string selectInFolder(string selectWhat, string directory, ref Terminal t, ref RealTimeConsoleInput input, 
scope string[] extFilters = [".DS_Store"])
{
	import std.string;
	Choice[] choices;
	LISTING_FILE: foreach(std.file.DirEntry e; std.file.dirEntries(directory, std.file.SpanMode.shallow))
	{
		foreach(f; extFilters)
			if(e.name.endsWith(f)) continue LISTING_FILE;
		choices~= Choice(e.name, null);
	}
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
return scope Choice[] choices, scope Choice[] extraChoices, scope string[] extFilters = [".DS_Store"])
{
	import std.string;
	LISTING_FILES: 
	foreach(std.file.DirEntry e; std.file.dirEntries(directory, std.file.SpanMode.shallow))
	{
		foreach(f; extFilters) if(e.name.endsWith(f)) continue LISTING_FILES;
		choices~= Choice(e.name, null);
	}
	choices = (choices ~ extraChoices).unique;
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
	import std.string:split;
	import std.exception:enforce;
	target = target.split(".")[$-1];
	string path = getHipPath("tools", "internal", "targets");
	enforce(std.file.exists(path = buildPath(path, target)), "Target "~target~" does not exists.");
	return path;
}

void outputTemplate(ref Terminal t, string templatePath)
{
	import template_processor;
	string out_templ;
	
	switch(processTemplate(templatePath, configs["hipremeEnginePath"].str, out_templ, [
		"TARGET_PROJECT": configs["gamePath"].str
	]))
	{
		case TemplateProcessorResult.invalid:
			t.writelnError("Could not process template from path ",templatePath);
			throw new Error("Can't build with invalid template.");
		case TemplateProcessorResult.notFound:
			t.writelnHighlighted("Template at ", templatePath, " not found, your game may use dub.json instead.");
			break;
		default: case TemplateProcessorResult.success:
			t.writelnSuccess("Template at path ", templatePath, " successfully generated");
			std.file.write(buildPath(templatePath, "dub.json"), out_templ);
			break;
	}
}

void outputTemplateForTarget(ref Terminal t, string target = __MODULE__)
{
	import std.array:split;
	///If it is the default, the target will be "targets.wasm", so, split and get the last.
	string buildTarget = getBuildTarget(target.split(".")[$-1]);
	t.writeln("Regenerating buildscript for target ", buildTarget);
	outputTemplate(t, buildTarget);
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
	configs = std.file.exists(getConfigPath) ? Config(parseJSON(std.file.readText(getConfigPath))) : Config(parseJSON("{}"));
	try engineConfig = std.file.exists(getEngineConfigPath) ? parseJSON(std.file.readText(getEngineConfigPath)) : parseJSON("{}");
	catch(Exception e) engineConfig = parseJSON("{}");
}