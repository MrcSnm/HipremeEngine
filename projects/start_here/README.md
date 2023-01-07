start_here made using Hipreme Engine

This file contains the same information found on [Getting Started](https://github.com/MrcSnm/HipremeEngine/wiki/Getting-Started)

# Getting Started

For getting started into using Hipreme Engine, there is 2 ways to do that.

## Scripting API
For using the Scripting API, one need to: 
1. Enter **projects/hiper**, execute `dub` there and choose a folder and a project name. 
> Hiper is a project generator for Hipreme Engine. Keep in mind that for executing it, one must set the environment variable HIPREME_ENGINE with the path to the root of Hipreme Engine. 
>> The project generator will popup a dialog, choose somewhere nice in your PC and enter the project name there. 
2. Enter this project folder and execute `dub -c run`. 
> The project will be built as a Shared Library (.so on Linux or a .dll on Windows), it will then automatically execute `dub -c script -- YOUR_PROJECT_PATH` to the Hipreme Engine. Which then will load your project as a game.
3. Code and iterate through your code by pressing F5 on HipremeEngine window, it will recompile and reload your code.


## Engine Level Coding

Whenever you just execute `dub` on HipremeEngine, it will automatically open TestScene. If you wish, you can modify that part of the code to use lower level features such as directly controlling Sprite Batches or other things. Keep in mind that doing this is out of scope from HipremeEngine project, the Scripting API should be the default way to code for it.


## Scripting API Sample Project
If you don't want to generate a project by using the Hiper, just enter **projects/start_here** and execute `dub -c run`. You're free to modify this project at your own call.
