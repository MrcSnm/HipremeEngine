# Building the libs

This is an extensive guide for building the libraries needed for HipremeEngine, focused on users
with a bit more of experience.

## Building Dear ImGUI

- Building for Windows

For being able to build for Windows, you will need Windows Kit/SDK and Visual C++ compiler "`cl` command"
This is only achieved by installing Microsoft Visual Studio, then, you will need to find it and 
add the bin directory for the `cl` command, usually located at `C:\Program Files(x86)\Microsoft Visual Studio xx.0\VC\bin`

After adding the Visual C++ Compiler, you will be able to compile it, when trying to compile, check for
any linker error, it is probably related to Windows SDK, if is usually located at 
`C:\Program Files (x86)\Windows Kits\10\Lib` and `C:\Program Files (x86)\Windows Kits\10\Include`
Remember that you will probably need to select if it is x86 or x64, and probably need to select the folder `um` after it

