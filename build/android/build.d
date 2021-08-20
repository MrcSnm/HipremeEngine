#!/usr/bin/rdmd
import std.string;
import std.path;
import core.time;
import std.conv:to;
import std.json;
import std.getopt;
import std.file;
import std.stdio;
import std.array;
import std.algorithm;
import std.datetime.stopwatch;
import std.process;
/**
*	This will probably not change any soon
**/
string compiler = "ldc2";
/**
*	Where the object(*.o) will be output
*/
string objectDir = "obj";

string outputPath = "./SDL2/android-project/app/src/main/jniLibs/";

version(Windows){string os = "windows";}
else{string os = "linux";}

/**
*	If you need to add a new architecture to output
**/
string[] archs = 
[
	"aarch64",
	"armv7a",
	"x86_64",
	"i686"
];

/**
* This is an android convetion. It will automatically load the shared library in the correct folder
*/
static enum string[string] archFolders =
[
	"aarch64" : "arm64-v8a",
	"armv7a"  : "armeabi-v7a",
	"x86_64"  : "x86_64",
	"i686"    : "x86",
];

/**
*	If you need to add a new source, just include it here.
* 	It is the source paths not included in the parent folder dub.json
**/
string[] sourcePaths = 
[
	"source/"
];
string[] dependencies = 
[
	"BindBC-Loader", 
	"BindBC-SDL"
];
/**
*	Versions for the ldc compiler
**/
string[] versions = 
[
	"dll",
	"SDL_208",
	"BindSDL_Mixer",
	"BindSDL_TTF",
	"BindSDL_Image",
	"GL_45",
	"GL_ARB"
];
/**
*	Debug options
**/
string[] debugs = 
[

];

/**
*	Android libraries taken from NDK
**/
string[] ndkLibraries = 
[
	"log"
];


/**
*	NDK Api Level, the first number(major) on the Android/Sdk/ndk/(major.minor)
**/
enum ndkApiLevel = 21;
/**
*	If you're compiling it from windows or Mac, you will need to change this tripleSystem
**/
enum tripleSystem = "-linux-android";

string getDubArgs(string arch)
{
	return format!"-a %s --compiler=%s --parallel "(arch~"-"~tripleSystem, compiler);
}


string checkArchitectureMatch(string[] a)
{
	bool hasPassed = false;
	foreach(check; a)
	{
		hasPassed = false;
		foreach(arch; archs)
		{
			if(check == arch)
			{
				hasPassed = true;
				break;
			}
		}
		if(!hasPassed)
			return check;
	}
	return "";
}

string[] getSources(string path) 
{
	string[] files;
	foreach (DirEntry e; path.dirEntries(SpanMode.depth).filter!(f => f.name.endsWith(".d")))
		files ~= e.name;
	return files;
}

string getDubPackagesPath()
{
	version(Windows)
	{
		string appdata = environment["APPDATA"];
		return asNormalizedPath(appdata~"/../Local/dub/packages/").array;
	}
	else{return "";}
}

string getDubPackageFolder(string dubPackagesPath, string dubPackageName, string versionValue)
{
	long subPackageIndex = dubPackageName.lastIndexOf(':');
	if(subPackageIndex != -1)
		dubPackageName = dubPackageName[0..cast(uint)subPackageIndex];
	if(versionValue != "")
	{
		if(versionValue[0..2] == "~>")
		{
			versionValue = versionValue[2..$];
			string majorVer = versionValue[0..versionValue.lastIndexOf('.')];
			int maxVer = to!int(versionValue[versionValue.lastIndexOf('.')+1..$]);
			string nameToStart = (dubPackagesPath~"/"~dubPackageName~"-"~majorVer).asNormalizedPath.array;
			foreach(DirEntry e; dubPackagesPath.dirEntries(SpanMode.shallow)
								.filter!(f => f.name.startsWith(nameToStart)))
			{
				string fName = e.name;
				int fVer = to!int(fName[fName.lastIndexOf('.')+1..$]);
				if(fVer > maxVer)
				{
					maxVer = fVer;
					versionValue = majorVer~"."~to!string(maxVer);
					dubPackageName = e.name[0..e.name.lastIndexOf("-")].pathSplitter.back;
				}
			}
		}
	}
	return (dubPackagesPath~"/"~dubPackageName~"-"~versionValue~"/"~dubPackageName~"/").asNormalizedPath.array;
}


Pid execCompilationCommand(string depAbsolutePath, string depName)
{
	
	bool isSubPackage = depName.countUntil(":") != -1;
	writeln("cd ",depAbsolutePath);
	chdir(depAbsolutePath);
	string command;
	if(isSubPackage)
		command = "dub build "~ depName[depName.countUntil(":")..$];
	else
		command = "dub build ";

	return spawnShell(command ~ getDubArgs("aarch64"));
}

Pid[] buildDependencies(string dubJsonPath, string dubPackagesPath = getDubPackagesPath())
{
	string dubPath = dubJsonPath.asAbsolutePath.asNormalizedPath.array;
	dubJsonPath = asAbsolutePath(dubJsonPath~"/dub.json").asNormalizedPath.array;
	JSONValue json = parseJSON(readText(dubJsonPath));
	JSONValue* deps = cast(JSONValue*)("dependencies" in json);

	Pid[] ret;

	if(deps != null)
	{
		foreach (string depName, JSONValue depValue; deps.object)
		{
			string depAbsolutePath;
			if(depValue.type() == JSONType.object)
				depAbsolutePath = (dubPath~"/"~depValue["path"].str).asNormalizedPath.array;
			else
				depAbsolutePath = getDubPackageFolder(dubPackagesPath, depName, depValue.str);

			ret~= execCompilationCommand(depAbsolutePath, depName);
			break;
		}
	}
	return ret;
}

void buildProgram(string arch, string[] sources) 
{
	string[] command = [compiler];

	foreach (sourcePath; sourcePaths)
		command ~= format!"-I%s"(sourcePath);

	foreach (version_; versions)
		command ~= format!"-d-version=%s"(version_);
	foreach (debug_; debugs)
		command ~= format!"-d-debug=%s"(debug_);
	foreach (library; ndkLibraries)
		command ~= format!"-L=-l%s"(library); //-L= for using GNU Linker(ld)

	//Select architecture
	command ~= format!"-mtriple=%s-%s"(arch, tripleSystem);

	//Built as shared library
	command ~= "--shared";
	
	//Output object
	command~= format!"--od=%s/%s"(objectDir, archFolders[arch]);
	//Output file
	command ~= format!"--of=%s/%s/libmain.so"(outputPath, archFolders[arch]);

	string androidLibs = format!"%s/toolchains/llvm/prebuilt/%s-x86_64/sysroot/usr/lib/%s%s/%s/"(environment["ANDROID_NDK_HOME"],
	arch, os, tripleSystem, ndkApiLevel);
	command ~= format!"-L=-L%s"(androidLibs)~" ";

	foreach(source; sources)
		command~= source;
	

	Pid pid = spawnProcess("/bin/echo" ~ command);
	// Pid pid = spawnProcess(command);
	pid.wait;
	writefln("Compiled %s, output at: %s", arch, outputPath~archFolders[arch]);
}


string dubPath = "";

void main(string[] args) 
{
	// For debuging
	
	//Check for NDK
	try{environment["ANDROID_NDK_HOME"];}
	catch(Exception e){throw new Error("You must define on your environment the variable ANDROID_NDK_HOME");}
	writeln("Getting NDK from: " ~ environment["ANDROID_NDK_HOME"]~"/");

	//Check for setup
	if(!exists("./SDL2/"))
	{
		writeln("Please, run preparesdl.d first by calling 'rdmd preparesdl.d'\nIf you're running on Windows, run it as admin.");
		return;
	}

	string[] architectures;
	if(args.length == 1) //Default is 1
		architectures = archs;
	//Get cli options
	auto helpInfo = getopt(args, 
	"arch", &architectures,
	"dub", &dubPath);
	//Check if no architecture provided or help wanted
	if(helpInfo.helpWanted || architectures.length == 0)
		writefln("\n___Help info___\n\n%s: Adds an architercutre to compile. Supported values are:\naarch64, armv7a, x86_64, i686 
%s: Uses dub located on the parent folder
Usage: rdmd build.d --arch=armv7a --arch=aarch64 --dub=../../", "--arch", "--dub");
	else
	{
		//Check for architecture validity
		string error = checkArchitectureMatch(architectures);
		if(error != "")
		{
			writeln(error~" is not a supported option for --arch");
			return;
		}

		StopWatch sw = StopWatch(AutoStart.yes);
		Pid[] ret = buildDependencies(((dubPath != "") ? dubPath :"../../"));
		foreach (Pid t; ret)
			t.wait;
		writeln("Finished building dependencies with ", sw.peek.total!"msecs", "ms");

		// string[] sources;
		// foreach (sourcePath; sourcePaths)
		// 	sources ~= sourcePath.getSources;
		// foreach (arch; architectures)
		// 	buildProgram(arch, sources);
	}
}