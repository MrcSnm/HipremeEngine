module projectgen;
import std.path:buildNormalizedPath;
import std.file;
import std.format:format;
import std.process;
import std.array:join,split,array;

struct TemplateInfo
{
	string initMethod="",
	update="",
	render="",
	dispose="";
}

struct DubProjectInfo
{
	string author = "HipremeEngine";
	string projectName = "Hipreme Engine Test";
	string desc = "Hipreme Engine test scene";
}

string generateCodeTemplate(TemplateInfo info = TemplateInfo())
{
	return format!q{
module script.entry;
import hip.api;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene
{
	
	/** Constructor */
	override void initialize()
	{
		%s
	}
	/** Called every frame */
	override void update(float dt)
	{
		%s
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		%s
	}
	/** Pre destroy */
	override void dispose()
	{
		%s
	}

	void pushLayer(Layer l){}
	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	}(info.initMethod, info.update, info.render, info.dispose);
}


string escapeWindowsPathSep(string input)
{
	string output = "";
	foreach(ch; input)
		if(ch == '\\')
			output~="\\\\";
		else
			output~= ch;
	return output;
}

string generateDubProject(DubProjectInfo info, string projectPath)
{
	import std.conv;
	import std.uni:toLower;
	import std.algorithm:map;
	dstring outputName = info.projectName.split(" ").join("_").array;
	dstring name = outputName.map!(character => character.toLower).array;

	string hipEnginePath = environment["HIPREME_ENGINE"].escapeWindowsPathSep;
	projectPath = projectPath.escapeWindowsPathSep;


	return format!q{
{
	"authors": ["%s"],
	"description" : "%s",
	"license": "proprietary",
	"targetName" : "%s",
	"name" : "%s",
	"sourcePaths"  : ["source"],
	"dependencies": 
	{
		"hipengine_api": {"path": "%s/api"},
		"math": {"path": "%s/modules/math"}
	},
	"configurations": 
	[
		{
			"name" : "script",
			"targetType": "dynamicLibrary",
			"versions": ["Script"],
			"lflags-windows": [
				"/WX"
			]
		},
		{
			"name": "ldc",
			"targetType": "dynamicLibrary",
			"versions": ["Script"],
			"dflags": [
				"-link-defaultlib-shared=false"
			],
			"lflags-windows": [
				"/WX"
			]
		},
		{
			"name": "run",
			"targetType": "dynamicLibrary",
			"versions": ["Script"],
			"lflags-windows": [
				"/WX"
			],
			"postBuildCommands": ["cd %s && dub -c script -- %s"]
		}
	],
	"versions" : [
		"HipremeRenderer",
		"HipGraphicsAPI",
		"HipImageAPI",
		"HipInputAPI",
		"HipAudioAPI",
		"HipMathAPI",
		"HipremeAudio",
		"HipremeG2D",
		"HipDataStructures"
	]
}
	}(info.author, info.desc, outputName, name, hipEnginePath, hipEnginePath, hipEnginePath, projectPath);
}

void generateProject(string projectPath,
DubProjectInfo dubInfo, TemplateInfo templateInfo)
{
	string dubProj = generateDubProject(dubInfo, projectPath);
	string codeTemplate = generateCodeTemplate(templateInfo);

	try
	{
	    //Project folder
		mkdirRecurse(projectPath);
		//Source Folder
		mkdirRecurse(buildNormalizedPath(projectPath, "source", "script"));
		//Assets Folder
		mkdirRecurse(buildNormalizedPath(projectPath, "assets"));

		std.file.write(buildNormalizedPath(projectPath, "source", "script", "entry.d"), codeTemplate);
		std.file.write(buildNormalizedPath(projectPath, "dub.json"), dubProj);
		std.file.write(buildNormalizedPath(projectPath, "README.md"), dubInfo.projectName~" made using Hipreme Engine");

		std.file.write(buildNormalizedPath(projectPath, ".gitignore"),  q{
.dub
.vs
bin
*.exe
*.dll
*.dll_hiptempdll
*.so
*.lib
*.pdb
});
	}
	catch(Exception e)
	{
		import std.stdio;
		writeln(e.toString);
	}
}