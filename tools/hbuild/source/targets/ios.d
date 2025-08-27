module targets.ios;
import common_macos;
import commons;
import global_opts;

enum DefaultIphone = "iPhone 14";
enum DefaultIphoneOS = "16";
enum TARGET_TYPE = "simulator";
string getTargetArchitecture(bool isSimulator)
{
	import hconfigs;
	if(isSimulator)
	{
		static if(isARM)
			return "arm64";
		else
			return "x86_64";
	}
	return "arm64";
}

string getExtraCommand(string type)
{
	if(type == "simulator") return " -sdk iphonesimulator ";
	return " -sdk iphoneos";
}


/**
*	Supports up to 99.9
*/
int iosVersionToInt(string v)
{
	ulong power = 2;
	int ret = 0;
	foreach(ch; v)
	{
        if(ch == '.')
			continue;
		ret+= (ch - '0') * 10^^power;
		power--;
	}
	return ret;
}

string versionFromInt(long input)
{
    ulong value = input;
    char[] v;
    
    do
    {
        char rest = cast(char)(value % 10);
        v~= '0' + rest;
        value -= rest;
        value/= 10;
    }
    while(value >= 1);
    if(!v.length)
        return null;
    
    
    for(int i = 0; i < v.length / 2; i++)
    {
        char first = v[i];
        int last = i + (cast(int)v.length - 1);
        v[i] = v[last];
        v[last] = first;
    }
	if(v[$-1] != '0')
		return cast(string)v[0..$-1] ~ "." ~ v[$-1];
	else
		return cast(string)v[0..$-1];
}

string trimCharacters(string input)
{
	import std.string;
	import std.ascii;
	input = input.chomp;
	int lower = 0;
	int upper = (cast(int)input.length - 1);
	if(!input.length)
		return input;
	while(lower < upper && !input[lower].isDigit)
		lower++;
	while(upper > lower && !input[upper].isDigit)
		upper--;
	if(upper - lower != 0)
		return input[lower..upper+1];
	return null;
}

unittest
{
	assert(trimCharacters("16e") == "16");
	assert(iosVersionToInt("18.2") == 182);
	assert(versionFromInt(182) == "18.2");
}

private string getDestination()
{
	// return "-destination 'generic/platform=iOS' ";
	return "-destination 'platform=iOS Simulator,name="~
	configs["iosDevice"].str ~
	",OS=" ~configs["iosVersions"].array[0].integer.versionFromInt ~ "' ";
}
private string getIosTriple(string arch, bool isSimulator)
{
	import hconfigs;
	static if(isARM)
	{
		if(isSimulator)
			return "arm64-apple-ios14.0-simulator";
	}
	return arch~"-apple-ios14.0";
}

string getIosLibFolder(bool isSimulator)
{
	version(X86_64)
	{
		if(isSimulator)
			return "ios-x86_64";
	}
	else
	{
		if(isSimulator)
			return "ios-arm64-simulator";
	}
	return "ios-arm64";
}
ChoiceResult putInstalledDeviceInformation(ref Terminal t)
{
	import std.process;
	import std.json;
	import commons;
	///A way to get which devices are registered in the user PC
	auto res = executeShell("xcrun simctl list runtimes --json");
	if(res.status)
	{
		t.writelnError("No iOS runtime found? Please try opening XCode and installing the iOS runtime.");
		return ChoiceResult.Error;
	}
	JSONValue json = parseJSON(res.output);
	int[] iosVersions;
	int bestVersion = 0;

	foreach(JSONValue v; json["runtimes"].array)
	{
		import std.string;
		import std.conv;
		if(!v["isAvailable"].boolean || v["platform"].str != "iOS")
			continue;
		iosVersions~= v["version"].str.iosVersionToInt;
		
		foreach(JSONValue device; v["supportedDeviceTypes"].array)
		{
			if(device["productFamily"].str != "iPhone" || !device["identifier"].str.startsWith("com.apple.CoreSimulator.SimDeviceType"))
				continue;
			string[] nameParts = device["name"].str.split(" ");
			if(nameParts.length < 2)
				continue;
			nameParts[1] = nameParts[1].trimCharacters;
			if(nameParts[1].length)
			{
				int currVersion = nameParts[1].to!int;
				bestVersion = currVersion > bestVersion ? currVersion : bestVersion;
			}
		}
	}
	import std.algorithm.sorting;
	import std.array;
	import std.conv;

	configs["iosVersions"] = JSONValue(iosVersions.sort.array);
	configs["iosDevice"] = JSONValue("iPhone " ~ bestVersion.to!string);
	updateConfigFile();

	return ChoiceResult.Continue;
}

ChoiceResult prepareiOS(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	bool isSimulator = TARGET_TYPE == "simulator";
	string arch = getTargetArchitecture(isSimulator);
	prepareAppleOSBase(c,t,input);

	string out_extraLinkerFlags;
	setupPerCompiler(t, "ldc2", getIosLibFolder(isSimulator), out_extraLinkerFlags);
	injectLinkerFlagsOnXcode(t, input, out_extraLinkerFlags);
	if(!("lastUser" in configs))
	{
		configs["lastUser"] = environment["USER"];
		configs["firstiOSRun"] = true;
	}
	if(environment["USER"] != configs["lastUser"].str)
	{
		configs["firstiOSRun"] = true;
	}
	if("iosDevice" !in configs || "iosVersions" !in configs || !configs["iosVersions"].array.length)
		putInstalledDeviceInformation(t);
	
	appleClean = configs["firstiOSRun"].boolean;

	string codeSignCommand = getCodeSignCommand(t);
	string extraCommands = getExtraCommand(TARGET_TYPE);

	with(WorkingDir(configs["gamePath"].str))
	{
		cleanAppleOSLibFolder();
		ProjectDetails d;
		if(waitRedub(t, DubArguments().
			command("build").configuration("ios").arch(getIosTriple(arch, isSimulator)).compiler("ldc2").opts(cOpts),
			d,
			getHipPath("build", "appleos", XCodeDFolder, "libs")) != 0)
		{
			t.writelnError("Could not build for AppleOS.");
			return ChoiceResult.Error;
		}
		string clean = appleClean ? "clean " : "";

		with(WorkingDir(getHipPath("build", "appleos")))
		{
			t.wait(spawnShell(
				"xcodebuild -jobs 8 -configuration Debug -scheme 'HipremeEngine iOS' " ~
				clean ~
				"build CONFIGURATION_BUILD_DIR=\"bin\" "~ 
				codeSignCommand ~ extraCommands ~
				getDestination()
			));

			t.wait(spawnShell(
				"open -a Simulator && "~
				"xcrun simctl install booted " ~ getHipPath("build", "appleos", "bin", "HipremeEngine.app") ~ " && " ~
				"xcrun simctl launch --console booted hipreme.HipremeEngine"
			));
		}
	}
	if(configs["firstiOSRun"].boolean)
	{
		configs["firstiOSRun"] = false;
		updateConfigFile();
	}
	return ChoiceResult.None;
}
