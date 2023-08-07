import std.stdio;
import std.getopt;
import std.algorithm;
import std.file;
import std.json;
import std.path;
import std.uni;
import core.stdc.stdlib;



/** 
dub.template.json reference:

The params part is checked only once. Keep it at the top of the file.
For not conflicting with dub's internal parameters, it uses the syntax #PARAMETER
```json
 "params": {
	"windows": {
		//Defines windows specific parameters
	},
	"linux": {
		//Defines linux specific parameters
	},
	"SOME_GLOBAL_VAR": "This parameter can be used anywhere here by simply using #SOME_GLOBAL_VAR"
 }
```



Adding the engine separate modules can be done by using engineModules. They will automatically
use the absolute path and be added to the linkedDependencies on the current section. Also checked in configurations.
```json
 "engineModules": [
	"util",
	"game2d",
	"math"
 ]
```

Those in linkedDependencies will automatically be added a linker flag called 
/WHOLEARCHIVE:depName for windows on ldc compiler. 
Since this is an error prone operation, it may be handled by the templater.
Also checked in configurations.
```json
"linkedDependencies": {
	"someDubDep": {"path": "the/path/to/dep"},
	"arsd:anything": "11.0"
 }
```

Those in unnamed dependencies will automatically be added to the "dependencies" section.
If the path does not exists, it will be ignored and simply do nothing. Also checked in configurations.
```json
"unnamedDependencies": [
	"some/path/to/dep"
]
```
*/


enum string templateName = "dub.template.json";

immutable string[] systems = 
[
	"windows",
	"linux"
];

enum VariableType
{
	_default,
	currentSystem,
	otherSystem
}

VariableType getType(string keyName)
{
	string currentSystem = "unknown";
	version(Windows)
		currentSystem = "windows";
	else version(Posix)
		currentSystem = "linux";
	
	if(keyName == currentSystem)
		return VariableType.currentSystem;
	else if(systems.countUntil(keyName) != -1)
		return VariableType.otherSystem;
	return VariableType._default;
}

long findMatching(in string str, char matchLeft, char matchRight, long start = 0)
{
	int openCount = 0;
	for(long i = start; i < str.length; i++)
	{
		if(str[i] == matchLeft)
			openCount++;
		else if(str[i] == matchRight)
		{
			openCount--;
			if(openCount == 0)
				return i;
		}
	}
	return -1;
}

/** 
 * 
 * Params:
 *   f = The file
 *   variables = Variables to replace in the $VARIABLE text.
 * Returns: File with replaced text.
 */
string processFile(string f, string[string] variables)
{
	long getVariableName(in string str, long start, out string varName)
	{
		assert(str[start] == '#');
		long curr = start+1;
		while(curr < str.length)
		{
			char ch = str[curr];
			if(!(ch.isNumber || ch.isAlpha || ch == '_'))
				break;
			curr++;
		}
		varName = str[start+1..curr];
		return curr;
	}

	string output = "";
	for(size_t i = 0; i < f.length; i++)
	{
		if(f[i] == '#')
		{
			string varName;
			i = getVariableName(f, i, varName);
			assert(varName in variables, "Variable "~varName~" not found");
			output~= variables[varName];
			i--; //For not updating too much
		}
		else
			output~= f[i];
	}
	return output;
}

string getVariableValue(string inputValue)
{
	switch(inputValue)
	{
		case "#CD":
			return globals.projectPath;
		default:
			return inputValue;
	}
}

/** 
 * Saves the current system variables in the cache.
 * Saves the default type in the cache too.
 * Params:
 *   templatePath = 
 * Returns: 
 */
string processTemplate(string templatePath, const AdditionalSetting[] settings)
{
	string file = readText(templatePath);
	JSONValue json = parseJSON(file);
	string[string] variables;

	if(const(JSONValue)* params = "params" in json)
	{
		foreach(key, value; params.object)
		{
			VariableType type = getType(key);
			
			if(type == VariableType.currentSystem)
			{
				foreach(sysKey, sysValue; value.object)
					variables[sysKey] = getVariableValue(sysValue.str);
			}
			else if(type == VariableType._default)
			{
				if((key in variables) is null)
					variables[key] = getVariableValue(value.str);
			}
		}
	}
	json.object.remove("params");
	foreach(op; settings)
	{
		if(op.name in json)
		{
			op.handler(json);
			json.object.remove(op.name);
		}
		foreach(cfg; json["configurations"].array) if(op.name in cfg)
		{
			op.handler(cfg);
			cfg.object.remove(op.name);
		}
	}


	file = processFile(json.toPrettyString(JSONOptions.doNotEscapeSlashes), variables);
	return file;
}


struct Globals
{
	string enginePath;
	string projectPath;
}

struct AdditionalSetting
{
	string name;
	JSONValue function(JSONValue dubFile) handler;
}
Globals globals;

enum emptyObject = JSONValue(string[string].init);
enum emptyArray = JSONValue(JSONValue[].init);

/**
*	Expects path/to/folder/containing/ (dub.template.json)
*/
int main(string[] args)
{
	string processedPath;
	auto helpInfo = getopt(args, 
		"processedPath", "Path to a folder containing a dub.template.json", &processedPath,
		"enginePath", "Path to the HipremeEngine path. Used for engineModules", &globals.enginePath
	);
	if(helpInfo.helpWanted || !processedPath)
	{
		defaultGetoptPrinter("Dub Preprocessor reference:", helpInfo.options);
		return EXIT_FAILURE;
	}
	if(!exists(processedPath))
	{
		writeln("Path received '", processedPath, "' does not exists");
		return EXIT_FAILURE;
	}
	string templatePath = buildPath(processedPath, templateName);
	if(!exists(templatePath))
	{
		writeln("File ", templatePath, " does not exists");
		return EXIT_FAILURE;
	}

	globals.projectPath = processedPath.absolutePath;
	AdditionalSetting[] additionals = [
		{"engineModules", (JSONValue json) 
		{
			foreach(mod; json["engineModules"].array)
			{
				if(!("linkedDependencies" in json))
					json.object["linkedDependencies"] = emptyObject;
				json["linkedDependencies"].object[mod.str] = ["path": buildPath(globals.enginePath, "modules", mod.str)];
			}
			return json;
		}},
		{"linkedDependencies", (JSONValue json)
		{
			foreach(key, value; json["linkedDependencies"].object)
			{
				if(!("dependencies" in json))
					json.object["dependencies"] = emptyObject;
				if(!("lflags-windows-ldc" in json))
					json.object["lflags-windows-ldc"] = emptyArray;
				json["dependencies"].object[key] = value;
				json["lflags-windows-ldc"].array ~= JSONValue("/WHOLEARCHIVE:"~key);
			}
			return json;
		}},
		{"unnamedDependencies", (JSONValue json)
		{
			foreach(path; json["unnamedDependencies"].array)
			{
				string dubPath = buildNormalizedPath(globals.projectPath, path.str, "dub.json");
				if(exists(dubPath))
				{
					if(!("dependencies" in json))
						json.object["dependencies"] = emptyObject;
					JSONValue dubJson = parseJSON(readText(dubPath));
					string packageName = dubJson["name"].str;
					if(packageName in json["dependencies"])
						throw new Error("Package "~packageName~" from path "~path.str~" is already present in the dependencies.");
					

					json["dependencies"][packageName] = ["path": path.str];
				}
			}
			return json;
		}}
	];

	string processedFile = processTemplate(templatePath, additionals);
	string outputFilePath = buildPath(processedPath, "dub.json");


	try
	{
		std.file.write(outputFilePath, processedFile);
	}
	catch(Exception e)
	{
		writeln("Could not write to ", outputFilePath, " error: ", e.toString);
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;

}
