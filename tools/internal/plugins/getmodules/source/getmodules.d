module getmodules;
import redub.plugin.api;


class GetModulePlugin : RedubPlugin
{

    void preGenerate()
    {

    }

    void postGenerate()
    {

    }
	/**
	* Simple utility file to get the source files used for a game project in Hipreme Engine.
	* This utility may be replaced in the future to prefer dub describe --data=source-files
	*/
    extern(C) ref RedubPluginStatus preBuild(RedubPluginData input, out RedubPluginData output, const ref string[] args, ref return RedubPluginStatus status)
    {
		import std.file;
		import std.path;
		import std.array:replace;

		if(args.length != 1)
			return status = RedubPluginStatus(RedubPluginExitCode.error, "Usage: \"gemodules\": [\"outputFileName\"]");
		string outputPath = args[0];

		if(exists(outputPath) && isDir(outputPath))
			return status = RedubPluginStatus(RedubPluginExitCode.error, "Invalid output path '"~outputPath~"', the output path is a directory");
		if(outputPath.length == 0)
			return status = RedubPluginStatus(RedubPluginExitCode.error, "Invalid output path '"~outputPath~"', the output path is empty.");

		string getModulesFile;

		foreach(string inputPath; input.sourcePaths)
		foreach(DirEntry e; dirEntries(inputPath, "*.d", SpanMode.depth))
		{
			string file = e.name;
			if(getModulesFile != "")
				getModulesFile~="\n";
			//Remove .d, change / or \ to .

			file = relativePath(file, inputPath)[0..$-2];

			getModulesFile~= file.replace('/', '.').replace('\\', '.');
		}

		string outDir = dirName(outputPath);
		if(!std.file.exists(outDir))
			std.file.mkdirRecurse(outDir);

		std.file.write(outputPath, getModulesFile);
		return status = RedubPluginStatus(RedubPluginExitCode.success, "getModule plugin generated file "~outputPath);
    }

    void postBuild()
    {

    }
}

mixin PluginEntrypoint!(GetModulePlugin);