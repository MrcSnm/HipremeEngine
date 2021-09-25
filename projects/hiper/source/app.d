module app;
import projectgen;
import std.stdio;
import std.path;
import std.array;

int main(string[] args)
{
	assert(args.length > 1, "Arguments must receive a target project name");
	writeln("Generating project at path ", args[1]);

	string projName = pathSplitter(args[1]).array[$-1];
	generateProject(args[1], DubProjectInfo("HipremeEngine", projName), TemplateInfo());
	return 0;
}