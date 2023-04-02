cd $HIPREME_ENGINE
rm -r build/appleos/HipremeEngine\ D/libs
dub -c appleos
dub -c appleos-main
rdmd tools/build/copylinkerfiles.d "-c appleos" "build/appleos/HipremeEngine D/libs"
cd build/appleos/
xcodebuild -jobs 8 -configuration Debug -scheme HipremeEngine\ macOS build CONFIGURATION_BUILD_DIR="bin" && cd bin && HipremeEngine.app/Contents/MacOS/HipremeEngine