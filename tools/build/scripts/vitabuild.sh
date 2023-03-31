export _DFLAGS="-I=$HIPREME_ENGINE/modules/d_std/source \
-I=$HIPREME_ENGINE/dependencies/runtime/druntime/arsd-webassembly \
-d-version=PSVita \
-d-version=PSV \
-preview=shortenedMethods \
-mtriple=armv7a-unknown-unknown \
--revert=dtorfields \
-mcpu=cortex-a9 \
-O0 \
-g \
-float-abi=hard \
--relocation-model=static \
-d-version=CarelessAlocation"

export DFLAGS=$_DFLAGS;

dub -c psvita-main --compiler=ldc2 --arch=armv7a-unknown-unknown
dub -c psvita --compiler=ldc2 --arch=armv7a-unknown-unknown
export DFLAGS="";
rdmd tools/build/copylinkerfiles.d "-c psvita --compiler=ldc2 --arch=arvm7a-unknown-unknown" "build/vita/hipreme_engine/libs" $_DFLAGS
