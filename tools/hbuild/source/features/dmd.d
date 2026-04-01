module features.dmd;

import commons;
import feature;

bool installDmd(
    ref Terminal t,
    ref RealTimeConsoleInput input,
    TargetVersion ver,
    Download[] downloads,
    string[] extractionPaths
)
{
    import std.system;
    import std.path;

    string sys;
    version(X86_64)
        string bin = "bin64";
    else
        string bin = "bin";
    switch(os) with(OS)
    {
        case osx: sys = "osx"; break;
        case win32, win64: sys = "windows"; break;
        case linux: sys = "linux"; break;
        default: assert(false, "System not supported.");
    }
    string binPath = buildNormalizedPath(extractionPaths[0], "dmd2", sys, bin);
    makeFileExecutable(buildNormalizedPath(binPath, "dmd"));
    makeFileExecutable(buildNormalizedPath(binPath, "dub"));
    makeFileExecutable(buildNormalizedPath(binPath, "rdmd"));

    configs["dmdVersion"] = ver.toString;
    configs["dmdPath"] = binPath;
    updateConfigFile();
    return true;
}


Feature DMDFeature;
void initialize()
{
    DMDFeature = Feature(
        "DMD",
        "Digital Mars D Compiler. Used for fast iteration development", 
        ExistenceChecker(["dmdPath"]),
        Installation([Download(
            DownloadURL(
                windows: "https://downloads.dlang.org/releases/2.x/$VERSION/dmd.$VERSION.windows.7z",
                linux: "https://downloads.dlang.org/releases/2.x/$VERSION/dmd.$VERSION.linux.tar.xz",
                osx: "https://downloads.dlang.org/releases/2.x/$VERSION/dmd.$VERSION.osx.tar.xz",
            ),
            outputPath: "$TEMP/$NAME",
        )], toDelegate(&installDmd), ["$CONFIG_DIR/D"]), 
        (ref Terminal t, string installPath)
        {
            addToPath(installPath.dirName);
        },
        VersionRange.parse("2.111.0", "2.111.0")
    );
}
void start()
{
    
}