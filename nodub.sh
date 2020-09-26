#Include BindBC-Loader and Source
#Include BindBCSDL
#Output bin/libmain.so

#Path related to bindbc
BINDBC_LOADER="$HOME/.dub/packages/bindbc-loader-0.3.2/bindbc-loader"
BINDBC_LOADER_SOURCE="$BINDBC_LOADER/source/"
BINDBC_LOADER_LIB="$BINDBC_LOADER/lib/libBindBC_Loader.a"

#Path related to bindbc
BINDBC_SDL="$HOME/.dub/packages/bindbc-sdl-0.19.0/bindbc-sdl"
BINDBC_SDL_SOURCE="$BINDBC_SDL/source"
BINDBC_SDL_LIB="$BINDBC_SDL/lib/libBindBC_SDL.a"
NDK_API_LEVEL=21


#Android architecture
#Listing existing architectures:
#Those configurations all exists under $HOME/dlang/ldc$ldc_version/etc/ldc2.conf
AARCH64="aarch64"
ARMV7A="armv7a"
X86_64="x86_64"
I686="i686"

SELECTED_ARCHITECTURE=$AARCH64
_DROID="-linux-android" #Common dlc2 structure after architecture

#Android Libraries: Those libraries are here just for reference
#Will need to include it at your android project    
#All those libraries must be located based on the achitecture
ALIB_PATH_="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/$SELECTED_ARCHITECTURE$_DROID/$NDK_API_LEVEL/"


ANDROID_LOG_LIBRARY="liblog.so"

#Automatically included by libsdl.so
ANDROID_EGL_LIBRARY="libEGL.so"
ANDROID_GLES1="libGLESv1_CM.so"
ANDROID_GLES2="libGLESv2.so"
ANDROID_GLES3="libGLESv3.so"
#Only for reference

COMP_FILES=""
shopt -s globstar

for file in $BINDBC_LOADER_SOURCE/**/*.d; do
    COMP_FILES="$COMP_FILES $file"
done

for file in $BINDBC_SDL_SOURCE/**/*.d; do
    COMP_FILES="$COMP_FILES $file"
    #echo $file
done

for file in source/**/*.d; do
    COMP_FILES="$COMP_FILES $file"
done

VERSIONS[0]="SDL_2012"
VERSIONS[1]="BindSDL_Mixer"
VERSIONS[2]="BindSDL_TTF"
VERSIONS[3]="BindSDL_Image"

LDC_VERSION=""
for v in "${VERSIONS[@]}"; do
    LDC_VERSION="$LDC_VERSION -d-version=$v"
done

ldc2 -Isource/ -I$BINDBC_LOADER_SOURCE \
-I$BINDBC_SDL_SOURCE \
--of=libmain.so \
-L$ALIB_PATH_$ANDROID_LOG_LIBRARY \
$LDC_VERSION \
-mtriple=$SELECTED_ARCHITECTURE-$_DROID --shared $COMP_FILES