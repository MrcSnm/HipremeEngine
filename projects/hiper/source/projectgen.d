module projectgen;
import std.path:buildNormalizedPath;
import std.file;
import std.format:format;
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
import hip.hipengine;

class MainScene : AScene
{
	
	/** Constructor */
	override void init()
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

string generateDubProject(DubProjectInfo info)
{
	import std.uni:toLower;
	import std.algorithm:map;
	dstring outputName = info.projectName.split(" ").join("_").array;
	dstring name = outputName.map!(character => character.toLower).array;
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
		"hipengine_api": {"path": "../../api"},
		"math": {"path": "../modules/math"}
	},
	"configurations": 
	[
		{
			"name" : "script",
			"targetType": "dynamicLibrary",
			"subConfigurations": {"hipengine_api" : "script"},
			"versions": ["Script"]
		},
		{
			"name": "run",
			"postBuildCommands": ["set PROJECT=%CD% && cd %HIPREME_ENGINE% && dub -- %PROJECT%"]
		}
	],
	"versions" : [
		"HipGraphicsAPI",
		"HipInputAPI",
		"HipAudioAPI",
		"HipremeG2D",
		"HipremeAudio"
	]
}
	}(info.author, info.desc, outputName, name);
}

void generateProject(string projectPath,
DubProjectInfo dubInfo, TemplateInfo templateInfo)
{
	string dubProj = generateDubProject(dubInfo);
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

		std.file.write(buildNormalizedPath(projectPath, ".gitignore"),  q{
.dub
.vs
bin
*.exe
*.dll
*.so
*.lib
});
	}
	catch(Exception e)
	{
		import std.stdio;
		writeln(e.toString);
	}
}