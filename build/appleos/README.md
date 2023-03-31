# Hipreme Engine MacOS Port


### Differences from Linux/Windows
- Hipreme Engine didn't focus on doing a MacOS first port. That happens the same reason why this folder is called `appleos`. It is not meant to be only a mac port, but a full apple port. This means this folder here implements support for macOS, iOS and tvOS. The iOS port will be only completed after LDC gets support to `extern(Objective-C)`.

- One big difference is that it does not generates executables automatically. A big advantage is that this project will be stable for a lot more time than a non XCode project. 


### Quick Start

- Go to the root folder and run `./appleosbuild.sh`. This will compile all Hipreme Engine's dependencies and move them to HipremeEngine D/lib folder.

- All the libs are manually listed in the XCode project, if your project is not working, please check that all the libs are listed in Frameworks.


### Fixing Assets problems

- As in every platform, all assets must be located in `assets` folder. In AppleOS, I wasn't  able to find a way to automatically input the reference folder, so, whenever you need to release your game, you will need to exclude the `assets` reference and put your own assets folder as a reference. 

- Right after putting the new reference, check in XCode project `Build Phasers->Copy Bundle Resources` and look if your new assets reference is in there. After that the game will be able to find it.
