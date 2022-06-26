module app;
import projectgen;
import arsd.minigui;
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
	return name != "" && name != "hiper";
}

int main(string[] args)
{
	string path;
	if(args.length < 2)
	{
		bool hasCancel = false;
		while(path == null && !hasCancel)
		{
			getSaveFileName((string folderName)
			{
				if(folderName.hasSpace)
				{
					messageBox("Save Project Error", "Your project name should not contain spaces", MessageBoxStyle.OK, MessageBoxIcon.Error);
					return;
				}
				path = folderName;
				if(path[$-1] == '\0')
					path = path[0..$-1];
			}, "Name of your project(Should not contain spaces)", ["HipremeProject"], (){hasCancel = true;});
		}

	}
	else
	{
		writeln("Getting the path from argument ", args[1]);
		path = args[1];
	}

	if(path == "")
	{
		writeln("No folder selected");
		return 1;
	}

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