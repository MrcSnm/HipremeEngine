import std;


string[] envDflags = 
[
"-I=$HIPREME_ENGINE/modules/d_std/source",
"-I=$HIPREME_ENGINE/build/wasm/runtime/webassembly/arsd-webassembly",
"-d-version=PSVita",
"-d-version=PSV",
"-preview=shortenedMethods",
"-fvisibility=hidden",
"-mtriple=armv7a-unknown-newlib",
"-mcpu=cortex-a9",
"-g",
"-float-abi=hard",
"--relocation-model=static",
"-fthread-model=local-exec",
"-d-version=CarelessAlocation"
];


string[] separateFromString(string str)
{
    string[] strings;
    
    bool isCapturing = false;
    string currStr;
    foreach(ch; str)
    {
        if(ch == '"')
        {
            if(isCapturing)
            {
                strings~= currStr;
                currStr = "";
            }
            isCapturing = !isCapturing;
        } else if(isCapturing) currStr~= ch;
    }
    if(currStr.length) strings~= currStr;
    return strings;
}

enum outputPath = "build/vita/hipreme_engine/libs/";

void main(string[] args)
{
    environment["DFLAGS"] = envDflags.join(" ");
    auto ret = executeShell("dub describe --data=linker-files -c psvita --compiler=ldc2 --arch=armv7a-unknown-newlib --vquiet");
    string librariesData = ret.output;
    string[] libraries = separateFromString(librariesData);
    writeln(libraries);


    string libNames = "";
    foreach(l; libraries)
    {
        string n = baseName(l);
        copy(l, buildPath(outputPath, n));
        libNames~= n;
        if(l != libraries[$-1])
            libNames~= " ";
    }

    std.file.write(buildPath(outputPath, "concat.sh"), "arm-vita-eabi-ar crsT libhipreme_engine_vita.a "~libNames);
}