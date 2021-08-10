#!/usr/bin/rdmd
import std;
/**
*	This will probably not change any soon
**/
string compiler = "ldc2";
/**
*	Where the object(*.o) will be output
*/
string objectDir = "obj";

string outputPath = "./SDL2/android-project/app/src/main/jniLibs/";
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
static enum string[string] archFolders =
{
	string[string] _;
	_["aarch64"] = "arm64-v8a";
	_["armv7a"]  = "armeabi-v7a";
	_["x86_64"]  = "x86_64";
	_["i686"]    = "x86";
	return _;
}();

/**
*	If you need to add a new source
**/
string[] sourcePaths = 
[
	"source/",
	"jni/",
	"bindbc-loader/source",
	"bindbc-sdl/source"
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
	"SDL_2012",
	"BindSDL_Mixer", 
	"BindSDL_TTF", 
	"BindSDL_Image"
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
string[] libraries = 
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

void buildProgram(string arch, string[] sources) 
{
	string[] command = [compiler];

	foreach (sourcePath; sourcePaths)
		command ~= format!"-I%s"(sourcePath);

	foreach (version_; versions)
		command ~= format!"-d-version=%s"(version_);
	foreach (debug_; debugs)
		command ~= format!"-d-debug=%s"(debug_);
	foreach (library; libraries)
		command ~= format!"-L=-l%s"(library); //-L= for using GNU Linker(ld)

	//Select architecture
	command ~= format!"-mtriple=%s-%s"(arch, tripleSystem);

	//Built as shared library
	command ~= "--shared";
	
	//Output object
	command~= format!"--od=%s/%s"(objectDir, archFolders[arch]);
	//Output file
	command ~= format!"--of=%s/%s/libmain.so"(outputPath, archFolders[arch]);

	string androidLibs = format!"%s/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/%s%s/%s/"(environment["ANDROID_NDK_HOME"], arch, tripleSystem, ndkApiLevel);
	command ~= format!"-L=-L%s"(androidLibs)~" ";

	foreach(source; sources)
		command~= source;
	

	Pid pid = spawnProcess("/bin/echo" ~ command);
	// Pid pid = spawnProcess(command);
	pid.wait;
	writefln("Compiled %s, output at: %s", arch, outputPath~archFolders[arch]);
}

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
		writeln("Please, run setupsdl.d first by calling 'rdmd setupsdl.d'\nIf you're running on Windows, run it as admin.");
		return;
	}

	string[] architectures;
	if(args.length == 1) //Default is 1
		architectures = archs;
	//Get cli options
	auto helpInfo = getopt(args, 
	"aarch", &architectures);

	//Check if no architecture provided or help wanted
	if(helpInfo.helpWanted || architectures.length == 0)
		writefln("%s: Adds an architercutre to compile. Supported values are:\naarch64, armv7a, x86_64, i686 ", "--aarch");
	else
	{
		//Check for architecture validity
		string error = checkArchitectureMatch(architectures);
		if(error != "")
		{
			writeln(error~" is not a supported option for --aarch");
			return;
		}
		string[] sources;
		foreach (sourcePath; sourcePaths)
			sources ~= sourcePath.getSources;
		foreach (arch; architectures)
			buildProgram(arch, sources);
	}
}