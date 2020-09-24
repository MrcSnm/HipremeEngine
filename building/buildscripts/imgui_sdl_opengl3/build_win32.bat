@REM Build for Visual Studio compiler. Run your copy of vcvars32.bat or vcvarsall.bat to setup command-line compiler.
::Change if needed
set arch=x86
set OUT_DIR=Debug%arch%
set OUT_EXE=example_sdl_opengl3

set WINPATH=C:\Program Files (x86)\Windows Kits\8.1\Include
set GL_PATH=C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um

set VC_PATH=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC
set VC_INCLUDE_PATH=%VC_PATH%\include
set VC_LIB_PATH=%VC_PATH%\lib

set SDL2_DIR=..\..\..\SDL2-2.0.12
set INCLUDES=/I"%VC_INCLUDE_PATH%" /I.. /I..\.. /I%SDL2_DIR%\include /I..\libs\gl3w /I"%WINPATH%\shared" /I"%WINPATH%\um" /I"%WINPATH%\runtime" 
set SOURCES=main.cpp ..\imgui_impl_sdl.cpp ..\imgui_impl_opengl3.cpp ..\..\imgui*.cpp ..\libs\gl3w\GL\gl3w.c

set LIBS=/libpath:"%GL_PATH%\%arch%" OpenGL32.lib shell32.lib /libpath:%SDL2_DIR%\lib\%arch% SDL2.lib SDL2main.lib /libpath:"%VC_LIB_PATH%"
::Needs OpenGL32.lib, shell32.lib
mkdir %OUT_DIR%
cl /Ox /nologo /Zi /MD %INCLUDES% %SOURCES% /Fe%OUT_DIR%/%OUT_EXE%.exe /Fo%OUT_DIR%/ /link %LIBS% /subsystem:console
