# Hipreme Engine Tools

Some tools are required for making your project work. Here is a summary of what they do if you intend to debug some step in your project or if you wish to contribute.

* **insertresourcesuwp.d**: Put all the game assets inside a visual studio project for generating the UWP version of the game. Automatic.
* **copyresources.d**: A tool that create files copy from other place to another with cache. Automatic.
* **releasegame.d**: Tool for inputting your project path, will put a copy of your project inside a release folder in the engine and setup some versions so you won't have indirect calls to engine functionality. Automatic.
* **gendir.d**: A tool which gets a folder as input and generates a JSON which describes that folder directories and files (describing only size for the time). Required for dealing with the WebAssembly release. Automatic.
* **copylinkerfiles.d**: A tool which will execute `dub describe --data=linker-files` and then will output all libraries on a target directory. Required for dealing with AppleOS and PS Vita.
