module projectgen;
import std.path:buildNormalizedPath;
import std.file;
import std.format:format;
import std.array:join,split,array;

struct TemplateInfo
{
	string init=q{
		//NEVER REMOVE THAT LINE
		initializeHip();
		initConsole();
		initG2D();
	},
	update="",
	render="",
	dispose="";
}

struct DubProjectInfo
{
	string author="HipremeEngine",
	projectName="Hipreme Engine Test",
	desc = "Hipreme Engine test scene";
}

string generateCodeTemplate(TemplateInfo info = TemplateInfo())
{
	return format!q{
module script.entry;
import hipengine;

class MainScene : IScene
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
	}(info.init, info.update, info.render, info.dispose);
}

string generateDubProject(DubProjectInfo info)
{
	import std.uni:toLower;
	import std.algorithm:map;
	string outputName = info.projectName.split(" ").join("_").array;
	string name = outputName.map!(character => character.toLower);
	return format!q{
{
	"authors": ["%s"],
	"description" : "%s",
	"license": "proprietary",
	"targetName" : "%s",
	"name" : "%s",
	"sourcePaths"  : ["source"],
	"configurations": 
	[
		{
			"name" : "script",
			"targetType": "dynamicLibrary",
			"dependencies": {"hipengine_api": {"path": "../../api"}},
			"subConfigurations": {"hipengine_api" : "script"},
			"versions": ["Script"]
		}
	],
	"versions" : [
		"HipremeRenderer",
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

    //Project folder
    mkdirRecurse(projectPath);
    //Source Folder
    mkdirRecurse(buildNormalizedPath(projectPath, "source"));
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