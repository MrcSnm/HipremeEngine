module app;
import projectgen;
import ui;
import std.file;
import std.stdio;
import std.path;
import std.array;

bool hasSpace(string name)
{
	foreach(ch; name)
		if(ch == ' ')
			return true;
	return false;
}

bool isProjectNameValid(string name)
{
	return name != "";
}

bool isFolderEmpty(string folderPath)
{
	foreach (DirEntry e; dirEntries(folderPath, SpanMode.shallow))
		return false;
	return true;
}

int onPathSelected(string path, string enginePath)
{
	if(path == "")
	{
		writeln("No folder selected");
		return 1;
	}

	path = absolutePath(path);
	if(path.exists && isDir(path) && !isFolderEmpty(path))
	{
		writeln("Can't generate project at path ", path, ". Please select an inexistent folder or an empty one.");
		return 1;
	}
	writeln("Generating project at path ", path);

	string projName = pathSplitter(path).array[$-1];
	generateProject(path, enginePath, DubProjectInfo("HipremeEngine", projName), TemplateInfo());
	return 0;
}

int popupForProjectName(string enginePath)
{
	string folderName = showSaveFileDialog("Name of your project(Should not contain spaces)", ["HipremeProject"]);
	if(folderName.length == 0)
	{
		writeln("Execution cancelled. No project will be created.");
		return 1;
	}
	else if(folderName.hasSpace)
	{
		showErrorMessage("Save Project Error", "Your project name '"~folderName~"' should not contain spaces");
		return popupForProjectName(enginePath);
	}
	else if(folderName[$-1] == '\0')
		folderName = folderName[0..$-1];
	return onPathSelected(folderName, enginePath);
}

int main(string[] args)
{
	import std.getopt;
	struct Args
	{
		string projectPath;
		string enginePath;
	}
	Args a;
	GetoptResult helpInfo = getopt(args,
		"path", "Path where the project will be generated. If no path is given, this program will popup a window prompting for selection.",&a.projectPath,
		"engine", "Path where the engine is located. Always required", &a.enginePath
	);
	if(helpInfo.helpWanted || a.enginePath == "")
	{
		if(a.enginePath == "")
			writeln("Path to the engine with the argument --engine is required.");
		defaultGetoptPrinter("How to use Hiper - Hipreme Engine Project Generator.", helpInfo.options);
		return -1;
	}
	if(a.projectPath == "")
		return popupForProjectName(a.enginePath);
	else
	{
		writeln("Getting the path from argument ", a.projectPath);
	}
	return onPathSelected(a.projectPath, a.enginePath);
}