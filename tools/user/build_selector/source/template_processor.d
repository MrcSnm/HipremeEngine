module template_processor;
import std.typecons:Flag,Yes,No;
import std.file;
import std.json;
import std.path;
import std.uni;


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

A dub.template.json can have a parent dub.json(or dub.template.json), this is used for separating some
configurations, such as the release one, since things can get hairy quite fast if not done.
```json
"$extends": "#HIPREME_ENGINE/dub.json"
```

## Adding the engine optional modules 
This can be done by using engineModules property. They will automatically
use the absolute path and be added to the linkedDependencies on the current section. It is checked on
both root and configurations.

Another important feature of it is that the engine distributed modules requires a special distribution of hipengine_api.
This distribution is hipengine_api:direct. This module optimizes the function calls to instead of using function pointers,
it uses extern definitions, this way, it can be built as a static library.
This way, it is checked inside the "release" configuration, for making every of them use the subConfiguration of
"direct".

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

private immutable string[] systems = 
[
	"windows",
	"linux"
];

private enum VariableType
{
	_default,
	currentSystem,
	otherSystem
}

private VariableType getType(string keyName)
{
	import std.algorithm.searching : countUntil;
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

bool moduleHasDirect(string moduleName)
{
	switch(moduleName)
	{
		case "game2d":return true;
		default: return false;
	}
}


/** 
 * 
 * Params:
 *   str = Any string
 *   start = Where the check will start
 *   varName = Out variable containing the variable name found
 * Returns: The index where the search stopped
 */
private long getVariableName(in string str, long start, out string varName)
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


private string processString(JSONValue json, string str)
{
	import std.exception:enforce;
	string returnString;
	size_t lastStop = 0;
	for(size_t i = 0; i < str.length; i++)
	{
		if(str[i] == '#')
		{
			returnString~= str[lastStop..i];
			string varName;
			i = getVariableName(str, i, varName);
			enforce(varName in json["params"], "Variable "~varName~" not found");
			returnString~= json["params"][varName].str;
			lastStop = i;
			i--; //For not updating too much
		}
	}
	if(lastStop != str.length) returnString~= str[lastStop..$];
	return returnString;
}

/** 
 * 
 * Params:
 *   f = The file
 *   variables = Variables to replace in the #VARIABLE text.
 * Returns: File with replaced text.
 */
private string processFile(string f, string[string] variables)
{
	string output = "";
	size_t lastStop = 0;
	for(size_t i = 0; i < f.length; i++)
	{
		if(f[i] == '#')
		{
			output~= f[lastStop..i];
			string varName;
			i = getVariableName(f, i, varName);
			assert(varName in variables, "Variable "~varName~" not found");
			output~= variables[varName];
			lastStop = i;
			i--; //For not updating too much
		}
	}
	if(lastStop != f.length) output~= f[lastStop..$];
	return output;
}

/** 
 * 
 * Params:
 *   json = The parsed dub.template.json
 * Returns: The variables inside "params".
 */
private string[string] getParamsInTemplate(JSONValue json)
{
	string[string] variables;
	if(const(JSONValue)* params = "params" in json)
	{
		foreach(key, value; params.object)
		{
			switch(getType(key))
			{
				case VariableType.currentSystem:
				{
					foreach(sysKey, sysValue; value.object)
						variables[sysKey] = sysValue.str;
					break;
				}
				case VariableType._default:
				{
					if((key in variables) is null)
						variables[key] = value.str;
					break;
				}
				default:break;
			}
		}
	}
	return variables;
}

private string escapeWindowsSep(string thePath)
{
	string ret;
	foreach(ch; thePath)
		if(ch == '\\')
			ret~= "\\\\";
		else ret~= ch;
	return ret;
}

/** 
 * Saves the current system variables in the cache.
 * Saves the default type in the cache too.
 * Params:
 *   templatePath = Where the file containing the template json is.
 *   projectPath = The path where the project is contained. Used for the reserved #PROJECT
 *	 enginePath = Path where the engine is located. Used for the reserved #HIPREME_ENGINE
 *   settings = Extra settings that will be processed inside the template.
 *   extraVariables = Optional variables which are always defined.
 * Returns: THe resulting string
 */
private string processTemplateImpl(string templatePath, string projectPath, string enginePath, const AdditionalSetting[] settings,
in string[string] extraVariables)
{
	string file = readText(templatePath);
	JSONValue json = parseJSON(file);
	string[string] variables = getParamsInTemplate(json);
	string hipremeEngine = enginePath.absolutePath.escapeWindowsSep;
	string project = projectPath.absolutePath.escapeWindowsSep;
	if(!("params" in json))
		json.object["params"] = emptyObject;
	json["params"].object["HIPREME_ENGINE"] = hipremeEngine;
	json["params"].object["PROJECT"] = project;
	foreach(k, v; extraVariables) json["params"].object[k] = v;


	foreach(op; settings)
	{
		JSONValue inherited = emptyObject;
		if(op.name in json)
		{
			inherited = json;
			op.handler(json, emptyObject);
		}
		if("configurations" in json)
		{
			foreach(cfg; json["configurations"].array)
			{
				op.handler(cfg, inherited);
				cfg.object.remove(op.name);
			}
		}
		if(op.name in json)
		{
			json.object.remove(op.name);
		}
	}
	variables["PROJECT"] = projectPath.absolutePath.escapeWindowsSep;
	variables["HIPREME_ENGINE"] = hipremeEngine;
	foreach(k, v; extraVariables) variables[k] = v;
	json.object.remove("params");
	json.object.remove("$schema");
	file = processFile(json.toPrettyString(JSONOptions.doNotEscapeSlashes), variables);
	return file;
}


private struct AdditionalSetting
{
	string name;
	JSONValue delegate(JSONValue dubFile, JSONValue inherited = emptyObject) handler;
	Flag!"configAvailable" config = Yes.configAvailable;
}
private enum emptyObject = JSONValue(string[string].init);
private enum emptyArray = JSONValue(JSONValue[].init);

enum TemplateProcessorResult
{
    notFound,
    invalid,
    success
}

JSONValue getDubFromTemplate(string templatePath, string enginePath)
{
	string out_jsonFile;
	if(processTemplate(templatePath, enginePath, out_jsonFile) != TemplateProcessorResult.success)
		throw new JSONException("Could not succesfully process template at path "~templatePath);
	return parseJSON(out_jsonFile);
}

/** 
 * 
 * Params:
 *   templatePath = path/to/folder/with/dub.template.json
 *   enginePath = The engine path which will be used for the configuration engineModules
 *   templateResult = The resulting string which can be used to cache internally or even save a file.
 *	 additionalVariables = Additional variables that may come as an always defined. Used internally
 * Returns: The result of the operation
 */
TemplateProcessorResult processTemplate(string templatePath, string enginePath, out string templateResult,
in string[string] additionalVariables = string[string].init)
{
    string processedPath = templatePath;
    processedPath = processedPath.absolutePath;
    if(!exists(templatePath))
	{
		templateResult = "Path received '" ~ templatePath ~"' does not exists";
		return TemplateProcessorResult.notFound;
	}
    templatePath = buildPath(templatePath, templateName);
    if(!exists(templatePath))
	{
		templateResult = "File "~ templatePath~ " does not exists";
		return TemplateProcessorResult.notFound;
	}
    AdditionalSetting[] additionals = [
		{"$extends", (JSONValue json, JSONValue inherited)
		{
			import std.exception:enforce;
			if(!("$extends" in json))
				return json;
			string parentDub = json["$extends"].str;
			string[] options = [
				parentDub,
				buildPath(parentDub, "dub.json"),
				buildPath(parentDub, "dub.template.json")
			];
			string[] excludeKeys = ["configurations", "subPackages"];
			JSONValue parentJson;
			foreach(i, opt; options)
			{
				opt = processString(json, opt);
				enforce(opt != templatePath, "Parent can't point to itself.");
				if(exists(opt))
				{
					if(i == 2)
						parentJson = getDubFromTemplate(opt, enginePath);
					else
						parentJson = parseJSON(cast(string)read(opt));
					break;
				}
			}
			import std.conv:to;
			enforce(parentJson != JSONValue.init, "Could not find json in paths "~options.to!string);
			foreach(key, value; parentJson.object)
			{
				import std.algorithm.searching : countUntil;
				if(excludeKeys.countUntil(key) == -1)
				{
					if(!(key in json)) json.object[key] = parentJson[key];
					else
					{
						enforce(parentJson[key].type == json[key].type);
						//New values that aren't array or object will be overridden
						switch(json[key].type)
						{
							case JSONType.array:
							{
								JSONValue[] arr = parentJson[key].array;
								foreach(parentValue; arr)
									json[key].array ~= parentValue;
								break;
							}
							case JSONType.object:
							{
								foreach(parentKey, parentValue; parentJson[key].object)
								{
									if(!(parentKey in json[key]))
										json[key].object[parentKey] = parentValue;
								}
								break;
							}
							//If both define, child json overrides it.
							default: continue;
						}
					}
				}
			}

			return json;
		}, No.configAvailable},
		{"engineModules", (JSONValue json, JSONValue inherited) 
		{
			if("engineModules" in json)
			foreach(mod; json["engineModules"].array)
			{
				if(!("linkedDependencies" in json))
					json.object["linkedDependencies"] = emptyObject;
				json["linkedDependencies"].object[mod.str] = ["path": buildPath(enginePath, "modules", mod.str)];
			}
			if(json["name"].str == "release")
			{
				if(!("subConfigurations" in json))
					json["subConfigurations"] = emptyObject;
				
				static void putDirectSubconfiguration(ref JSONValue input, ref JSONValue fromCfg)
				{
					if("engineModules" in fromCfg) 
					foreach(mod; fromCfg["engineModules"].array) 
					{
						if(moduleHasDirect(mod.str))
							input["subConfigurations"][mod.str] = "direct";
					}
				}
				///Put direct from inherited
				putDirectSubconfiguration(json, inherited);
				putDirectSubconfiguration(json, json);
			}
			return json;
		}},
		{"linkedDependencies", (JSONValue json, JSONValue inherited)
		{
			if(!("linkedDependencies" in json))
				return json;
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
		{"unnamedDependencies", (JSONValue json, JSONValue inherited)
		{
			if(!("unnamedDependencies" in json))
				return json;
			foreach(unnamedDep; json["unnamedDependencies"].array)
			{
				import std.stdio;
				import std.exception:enforce;
				string endingPath;
				JSONValue* subConfiguration;
				if(unnamedDep.type == JSONType.object)
				{
					enforce("path" in unnamedDep, "Unnamed dependencies with type object must contain a \"path\"");
					endingPath = unnamedDep["path"].str;
					subConfiguration = ("subConfiguration" in unnamedDep);
					if(subConfiguration && !("subConfigurations" in json))
						json.object["subConfigurations"] = emptyObject;
				}
				else
					endingPath = unnamedDep.str;

				endingPath = processString(json, endingPath);
				import std.algorithm.searching : find;
				
				string[] dubPath = find!((string f) => exists(f))(
				[
					buildPath(processedPath, endingPath, "dub.json"),
					buildPath(processedPath, endingPath, "dub.template.json")
				]);

				if(dubPath.length)
				{
					if(!("dependencies" in json))
						json.object["dependencies"] = emptyObject;
					JSONValue dubJson = parseJSON(readText(dubPath[0]));
					string packageName = dubJson["name"].str;
					enforce(!(packageName in json["dependencies"]), "Package "~packageName~" from path "~endingPath~" is already present in the dependencies.");
					json["dependencies"][packageName] = ["path": endingPath];
					if(subConfiguration)
						json["subConfigurations"].object[packageName] = subConfiguration.str;
				}
				else
					writeln("Warning: Unnamed dependency at path ", endingPath, " not found");
			}
			return json;
		}}
	];

    templateResult = processTemplateImpl(templatePath, processedPath, enginePath, additionals, additionalVariables);
    return TemplateProcessorResult.success;
}