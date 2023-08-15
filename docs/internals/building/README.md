# Building

## Building Instructions for Hipreme Engine

### Windows

Windows is the main platform in which Hipreme Engine is being developed. That said, it is the most reliable platform to run it. Windows can render both OpenGL 3 and Direct3D 11. Which can be activated by adding into the dependendencies field from the dub file:

* OpenGL3 -> bindbc-opengl (Dub registry)
* Direct3D11 -> directx-d (It is on the dependencies folder)

The renderer can be dynamically swiched using the renderer.conf file (Needs restart)

Dependencies required:

* windowing

Command: `dub`

### Linux

Linux only supports OpenGL. So, do the same steps as Windows and add OpenGL

Dependencies required:

* windowing

Command: `dub`

## Needs build as shared library

### UWP (Xbox Series)

Programs Required:

* LDC
* Visual Studio (Tested with 2019)
* UWP extension for Visual Studio

Dependencies required:

* bind (Module)
* directx-d (Dependencies Folder)

Command: `dub build -c uwp`

UWP platform works fairly different from those above. It is similar to Android though. UWP only supports Direct3D11, so, add only the directx-d.

The output for this platform is a dll. Which is referenced by the C++ code. Usually one should not need modifying the C++ code which is only used to load HipremeEngine and implement wrappers over specific internals.

For building and testing on the target platform, enter build/uwp/HipremeEngine and open the Visual Studio project to build it.

### Android

Programs Required:

* LDC
* Android Studio
* Android NDK (From the Android Studio Plugins)

Steps Required:

* Setup ANDROID\_NDK\_HOME environment variable to point to your Android ndk version
* Setup HIPREME\_ENGINE environment variable to point to the main dub project folder for being able to debug your code on Android

Dependencies Required:

* bind (Module)
* jni (Module)
* sles (Dependencies Folder)
* gles (Dependencies Folder

Command: `dub build -c android --compiler=ldc2 -a aarch64--linux-android`

#### LDC configuration for Android Build

Go to the [LDC Release](https://github.com/ldc-developers/ldc/releases/), find a suitable version, and download ldc2-version-android-aarch64.tar.xz, extract it, and add the lib into where your ldc is installed with the name lib-android\_aarch64

Add the following input to your ldc2.conf file:

Of course, change -gcc and -linker to reflect the correct place in your file system

```
"aarch64-.*-linux-android":
{
    switches = [
        "-defaultlib=phobos2-ldc,druntime-ldc",
        "-link-defaultlib-shared=false",
        "-gcc=/home/hipreme/Android/Sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang",
        "-linker=/home/hipreme/Android/Sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/bin/ld"
    ];
    lib-dirs = [
        "%%ldcbinarypath%%/lib-android_aarch64",
    ];
    rpath = "";
};
```

Android can be found in 4 common architectures

* arm64-v8a
* armeabi-v7a
* x86\_64
* x86

Your build command may change based on those architectures. For converting your command to the specified architecture, follow the list:

| Target Achitecture |      Build Command     |
| :----------------: | :--------------------: |
|    **arm64-v8a**   | aarch64--linux-android |
|   **armeabi-v7a**  |  armv7a--linux-android |
|     **x86\_64**    | x86\_64--linux-android |
|       **x86**      |   i686--linux-android  |

It is planned on future to automate those steps. Currently, HipremeEngine automatically moves the aarch64 to the correct folder on the Android project.

## Building and testing

As with UWP, Android will contain a shared library which will be read from Java, that usually should not be modified, as it contains internal code for running the Engine entry point and bindings to specific API.

Open Android Studio and click on "Run".
