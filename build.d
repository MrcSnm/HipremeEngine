#!/usr/bin/rdmd
import std;

string compiler = "ldc2";
string[] archs = ["aarch64","armv7a","x86_64","i686"];

string[] sourcePaths = [
	"source/",
	// These should be local git submodules or something instead of getting them from the ~/.dub/packages
	"bindbc-loader/source",
	"bindbc-sdl/source"
];
string[] dependencies = ["BindBC-Loader", "BindBC-SDL"];
string[] versions = ["SDL_2012", "BindSDL_Mixer", "BindSDL_TTF", "BindSDL_Image"];
string[] debugs = [];
string[] libraries = ["log"];

enum ndkApiLevel = 21;
enum tripleSystem = "-linux-android";

string[] getSources(string path) {
	string[] files;
	foreach (DirEntry e; path.dirEntries(SpanMode.depth).filter!(f => f.name.endsWith(".d")))
		files ~= e.name;
	return files;
}

void buildProgram(string arch, string[] sources) {
	string[] command = [compiler];

	foreach (sourcePath; sourcePaths)
		command ~= format!"-I%s"(sourcePath);

	foreach (version_; versions)
		command ~= format!"-d-version=%s"(version_);
	foreach (debug_; debugs)
		command ~= format!"-d-debug=%s"(debug_);
	foreach (library; libraries)
		command ~= format!"-l%s"(library);

	command ~= format!"-mtriple=%s-%s"(arch, tripleSystem);
	command ~= "--shared";
	command ~= "--of=libmain.so";

	string androidLibs = format!"%s/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/%s%s/%s/"(environment["ANDROID_NDK_HOME"], arch, tripleSystem, ndkApiLevel);
	command ~= format!"-L%s"(androidLibs);

	Pid pid = spawnProcess("/bin/echo" ~ command);
	pid.wait;
}

void main() {
	// For debuging
	environment["ANDROID_NDK_HOME"] = "derp";

	string[] sources;
	foreach (sourcePath; sourcePaths)
		sources ~= sourcePath.getSources;

	foreach (arch; archs)
		buildProgram(arch, sources);
}