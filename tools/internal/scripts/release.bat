set HIPREME_ENGINE="G:\HipremeEngine\"
set HIPREME_TOOLS="G:\HipremeEngine\tools\build\"
set PROJECT_PATH="G:\HipremeEngine\projects\match3"

if not defined PROJECT_PATH (
    set /p "PROJECT_PATH= Enter project path to release: "
)

cd %HIPREME_TOOLS%
rdmd releasegame.d %PROJECT_PATH%
cd %HIPREME_ENGINE%
dub -c uwp
cd %HIPREME_TOOLS%
rdmd insertresourceuwp.d %HIPREME_ENGINE%build\uwp\HipremeEngine\HipremeEngine %PROJECT_PATH%\assets