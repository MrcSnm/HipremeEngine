set DFLAGS=-I=$HIPREME_ENGINE/modules/d_std/source ^
-I=$HIPREME_ENGINE/dependencies/runtime/druntime/arsd-webassembly ^
-preview=shortenedMethods ^
--revert=dtorfields ^
-O0 ^
-g ^
--m32 ^
-d-version=CustomRuntimeTest ^
-link-defaultlib-shared=false ^
-d-version=CarelessAlocation ^
--defaultlib= ^
--relocation-model=static

dub -c customrt