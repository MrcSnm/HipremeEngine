start_here made using Hipreme Engine

This file contains the same information found on [Getting Started](https://github.com/MrcSnm/HipremeEngine/wiki/Getting-Started)

# Getting Started

For getting started into using Hipreme Engine, there is 2 ways to do that.

## Building Instructions \n ~
1. Run `hipreme_engine:build_selector`
2. Select 'Create Project'
    1. Now, select the path in which you want to create it
    2. The directory must be empty
    3. The selected path should not contain spaces
3. Select 'Select Game'
4. Select the folder containing your project name
5. Now you can simply choose the platform to build for. After the game is built, dub.json will be generated.
> The project will be built as a Shared Library on Windows and Linux. 
It will then automatically execute `dub -c script -- YOUR_PROJECT_PATH` to the Hipreme Engine. Which then will load your project as a game.
6. Code and iterate through your code by pressing F5 on HipremeEngine window, it will recompile and reload your code.
    1. If your project is WebAssembly, it will automatically reload after building.
# Warning
The recommended way to build your project is to **ALWAYS** use `build_selector`


## Engine Level Coding

Whenever you just execute `dub` on HipremeEngine, it will automatically open TestScene. If you wish, you can modify that part of the code to use lower level features such as directly controlling Sprite Batches or other things. Keep in mind that doing this is out of scope from HipremeEngine project, the Scripting API should be the default way to code for it.


## Scripting API Sample Project
If you don't want to generate a project by using the Hiper, just enter **projects/start_here** and execute `dub -c run`. You're free to modify this project at your own call.
