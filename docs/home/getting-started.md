# Getting Started

Hipreme Engine is made in the D language. Since building is one of the most complex matters in native programming languages, the engine handles all itself. The way it uses, is by using the program called `hbuild`. You can take a look below into how to get the engine:

### Getting the Engine

1. Go into _Github Releases_ and download the build\_selector program for your target platform: https://github.com/MrcSnm/HipremeEngine/releases/tag/BuildAssets.v1.0.0

> The build\_selector will automatically get you the D language, Dub, all in the most compatible version with the game engine.

2. While running the program, simply accept the download of the tools and follow the instructions in the program.

> The tool will: Get all the development tools for you: Clone the engine repository, setup the internal variables, and also download relevant SDKs when required.

3. You can start running your game by simply selecting your target platform, the engine comes with a default project called **projects/start\_here**, which should show some stuff in your screen when run.

### Creating a new project

1. Run the build\_selector tool
2. Select the option of `Create Project`.
3. Make sure your project name has no space on it.
4. If you want to change the current project, you have 2 options: Use the option `Select Game`, or simply take a look into the file called `gamebuild.json` and change the `"gamePath"` to point to your game.

### Adding a dependency to your project

* On Windows: Add in dub.json of your project the dependency as one would normally do. After that, you need to setup inside your `dflags-windows-ldc` a new entry with the same name of your dependency, for example, if your dependency is named `util`, you need to add `/WHOLEARCHIVE:util`

### Usage Tutorials:

* [Asset Loading](https://github.com/MrcSnm/HipremeEngine/wiki/Assets#hipassets-and-its-usages)
* [Do not use std](https://github.com/MrcSnm/HipremeEngine/wiki/Do-not-use-std)
* [Game 2D Module](https://github.com/MrcSnm/HipremeEngine/wiki/Game-2D-Module)

### Getting Realtime Help

Enter in Hipreme Engine Discord server: [**Hipreme Entertainment**](https://discord.gg/DkGeYwsPXe). Currently, I'm fully dedicated in providing as much support as needed. That way we can make it become better for everyone.

#### Engine Level Coding

Whenever you just execute `dub` on HipremeEngine, it will automatically open TestScene. If you wish, you can modify that part of the code to use lower level features such as directly controlling Sprite Batches or other things. Keep in mind that doing this is out of scope from HipremeEngine project, the Scripting API should be the default way to code for it.
