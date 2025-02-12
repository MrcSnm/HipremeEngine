module project.gen;
import std.path:buildNormalizedPath;
import std.file;
import std.format:format;
import std.process;
import std.array:join,split,array;

struct TemplateInfo
{
	string initMethod=q{
		setFont(HipDefaultAssets.getDefaultFontWithSize(62));
	},
	update="",
	render=q{
		drawText("You can start using the D Scripting API Here!", 400, 300, HipColor.white,
			HipTextAlign.CENTER,  HipTextAlign.CENTER
		);
	},
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
module gamescript.entry;
import hip.api;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene, IHipPreloadable
{
	mixin Preload;

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
	override void onResize(uint width, uint height){}
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

string generateDubProject(DubProjectInfo info)
{
	import std.conv;
	import std.uni:toLower;
	import std.algorithm:map;
	dstring outputName = info.projectName.split(" ").join("_").array;
	dstring name = outputName.map!(character => character.toLower).array;

	return format!`{
	"$schema": "https://raw.githubusercontent.com/Pure-D/code-d/master/json-validation/dub.schema.json",
	"authors": ["%s"],
	"description" : "%s",
	"license": "proprietary",
	"targetName" : "%s",
	"name" : "%s",
	"engineModules": [
		"util",
		"timer",
		"tween",
		"data",
		"math",
		"game2d"
	],
	"stringImportPaths": ["#PROJECT/ct_assets"],
	"dflags-ldc": ["--disable-verify", "--oq"],
	"plugins": {
		"getmodules": "#HIPREME_ENGINE/tools/internal/plugins/getmodules"
	},
	"preBuildPlugins": {
		"getmodules": ["#PROJECT/ct_assets/scriptmodules.txt"]
	},
	"configurations":
	[
		{
			"name" : "script",
			"targetType": "dynamicLibrary",
			"dflags-ldc": ["-link-defaultlib-shared=true"],
			"dependencies": {
				"hipengine_api": {"path": "#HIPREME_ENGINE/api"}
			},
			"lflags-windows-ldc": [
                "/WHOLEARCHIVE:hipengine_api_bindings",
                "/WHOLEARCHIVE:hipengine_api_interfaces"
            ],
			"versions": ["ScriptAPI"],
			"lflags-windows": ["/WX"]
		},
		{
			"name": "release",
			"targetType": "staticLibrary"
		},
		{
			"name": "release-wasm",
			"targetType": "executable",
			"dependencies": {"hipreme_engine": {"path": "#HIPREME_ENGINE"}},
			"subConfigurations": {
				"hipreme_engine": "wasm",
				"game2d": "direct"
			}
		},
		{
			"name": "appleos",
			"targetType": "staticLibrary",
			"dependencies": {"hipreme_engine": {"path": "#HIPREME_ENGINE"}},
			"subConfigurations": {"hipreme_engine": "appleos", "game2d": "direct"}
		},
		{
			"name": "ios",
			"targetType": "staticLibrary",
			"dependencies": {"hipreme_engine": {"path": "#HIPREME_ENGINE"}},
			"subConfigurations": {"hipreme_engine": "ios", "game2d": "direct"}
		},
		{
			"name": "android",
			"targetType": "dynamicLibrary",
			"dependencies": { "hipreme_engine": {"path": "#HIPREME_ENGINE"} },
			"subConfigurations": {"hipreme_engine": "android", "game2d": "direct"}
		},
		{
			"name": "uwp",
			"dflags-ldc": ["-link-defaultlib-shared=true"],
			"targetType": "dynamicLibrary",
			"dependencies": {"hipreme_engine": {"path": "#HIPREME_ENGINE"}},
			"subConfigurations": {"hipreme_engine": "uwp", "game2d": "direct"}
		},
		{
			"name": "psvita",
			"targetType": "staticLibrary",
			"subConfigurations": {"hipreme_engine": "psvita", "game2d": "direct"}
		},
		{
			"name": "run",
			"targetType": "dynamicLibrary",
			"lflags-windows": [
				"/WX"
			],
			"postGenerateCommands-windows": ["cd /d #HIPREME_ENGINE && redub -c script -- $PACKAGE_DIR"],
			"postGenerateCommands-linux": ["cd #HIPREME_ENGINE && redub -c script -- $PACKAGE_DIR"]
		}
	]
}
`(info.author, info.desc, outputName, name);
}

string generateReadmeContent(string projectName)
{
	return "# "~projectName~"\n"~projectName~" is made using Hipreme Engine.\n" ~
		"## Building Instructions \n" ~
		"1. Run `dub hipreme_engine:hbuild`\n" ~
		"2. Select 'Select Game'\n" ~
		"3. Select the folder containing "~projectName~"\n"~
		"4. Now you can simply choose the platform to build for";
}

string generateVSCodeDebuggerLaunch(string enginePath)
{
	import std.system;
	string hipEnginePath = enginePath;
	string hipEngineExecutable = (buildNormalizedPath(hipEnginePath, "bin", "desktop", "hipreme_engine") ~ ((os == OS.linux) ? "" : ".exe")).escapeWindowsPathSep;
	return format!q{
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
	// Auto Generated by HipremeEngine project generator.
	// Automatically handle SIGUSR1 and SIGUSR2 as they are currently used in semaphore.wait
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug",
            "type": "gdb",
            "request": "launch",
            "target": "%s",
            "cwd": "${workspaceRoot}",
            "arguments": "${workspaceRoot}",
            "debugger_args": [
                "-ex", "handle SIGUSR1 noprint",
                "-ex", "handle SIGUSR2 noprint"
            ]
        }
    ]
}
}(hipEngineExecutable);
}

import commons;
bool generateProject(ref Terminal t, string projectPath, string enginePath,
DubProjectInfo dubInfo, TemplateInfo templateInfo)
{
	string dubProj = generateDubProject(dubInfo);
	string codeTemplate = generateCodeTemplate(templateInfo);
	string debugLauncher = generateVSCodeDebuggerLaunch(enginePath);

	try
	{
	    //Project folder
		t.writeln("Creating project folder");
		mkdirRecurse(projectPath);
		//Source Folder
		t.writeln("Creating scripts folder");
		mkdirRecurse(buildNormalizedPath(projectPath, "source", "gamescript"));
		//Assets Folder
		t.writeln("Creating assets folder");
		mkdirRecurse(buildNormalizedPath(projectPath, "assets"));
		//Compilation Time Assets folder
		t.writeln("Creating Compilation Time Assets folder");
		mkdirRecurse(buildNormalizedPath(projectPath, "ct_assets"));
		//VSCode Folder
		t.writeln("Creating vscode folder");
		mkdirRecurse(buildNormalizedPath(projectPath, ".vscode"));

		t.writeln("Writing code template for gamescript/entry.d");
		std.file.write(buildNormalizedPath(projectPath, "source", "gamescript", "entry.d"), codeTemplate);
		t.writeln("Writing dub.template.json");
		std.file.write(buildNormalizedPath(projectPath, "dub.template.json"), dubProj);
		t.writeln("Writing README.md");
		std.file.write(buildNormalizedPath(projectPath, "README.md"), generateReadmeContent(dubInfo.projectName));
		t.writeln("Writing VSCode debug launcher");
		std.file.write(buildNormalizedPath(projectPath, ".vscode", "launch.json"), debugLauncher);

		t.writeln("Writing .gitignore");
		std.file.write(buildNormalizedPath(projectPath, ".gitignore"),  q{
dub.selections.json
dub.json
.DS_Store
.dub
.history
.vs
bin
*.exe
*.exp
*.lnk
*.dll
*.dll_hiptempdll
*.so
*.lib
*.a
*.pdb
});
	}
	catch(Exception e)
	{
		t.writelnError(e.toString);
		return false;
	}
	import commons;
	return writeTemplate(t, projectPath, enginePath);
}