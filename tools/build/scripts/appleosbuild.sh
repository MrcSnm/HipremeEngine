cd $HIPREME_ENGINE
rm -r build/appleos/HipremeEngine\ D/libs
dub -c appleos
dub -c appleos-main
rdmd tools/build/copylinkerfiles.d "-c appleos" "build/appleos/HipremeEngine D/libs"