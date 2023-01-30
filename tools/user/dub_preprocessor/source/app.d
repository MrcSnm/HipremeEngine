import std.stdio;
import std.algorithm;
import std.file;
import std.json;
import std.path;
import std.uni;
import core.stdc.stdlib;


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

string stripParams(string input)
{
	long index = input.countUntil("\"params\"");
	long end = findMatching(input, '{', '}', index);
	assert(end != -1, "Malformed dub.template.json");
	
	long optComma = input[end..$].countUntil(end, ",");
	if(optComma != -1)
	{
		end = end+optComma;
	}
	return input[0..index]~input[end+1..$];
}



string processFile(string f, string[string] variables)
{
	long getVariableName(in string str, long start, out string varName)
	{
		assert(str[start] == '$');
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
	
	f = stripParams(f);
	for(size_t i = 0; i < f.length; i++)
	{
		if(f[i] == '$')
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
		case "$CD":
			return globals.projectPath;
		default:
			return inputValue;
	}
}

string processTemplate(string templatePath)
{
	string file = cast(string)read(templatePath);
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
	json["params"] = null;
	file = processFile(file, variables);
	return file;
}


struct Globals
{
	string projectPath;
}
Globals globals;

/**
*	Expects path/to/folder/containing/ (dub.template.json)
*/
int main(string[] args)
{
	if(args.length < 2)
	{
		writeln("Expected to receive argument as a path to folder containing a dub.template.json");
		return EXIT_FAILURE;
	}
	string processedPath = args[1];
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

	
	globals.projectPath = processedPath;
	string processedFile = processTemplate(templatePath);
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
