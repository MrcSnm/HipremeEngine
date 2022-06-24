module app;
import projectgen;
import std.file;
import std.stdio;
import std.path;
import std.array;

bool isProjectNameValid(string name)
{
	return name != "" && name != "hiper";
}

int main(string[] args)
{
	string path;
	if(args.length < 2)
	{
		writeln("Write a project path. Its directory name will be considered the project name.");
		path = readln()[0..$-1];
	}
	else
		path = args[1];

	path = absolutePath(path);
	if(path.exists)
	{
		writeln("Can't generate project at path ", path, ". Folder already exists.");
		return 1;
	}
	writeln("Generating project at path ", path);

	string projName = pathSplitter(path).array[$-1];
	generateProject(path, DubProjectInfo("HipremeEngine", projName), TemplateInfo());
	return 0;
}