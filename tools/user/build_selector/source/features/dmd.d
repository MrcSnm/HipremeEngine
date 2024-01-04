module features.dmd;

import commons;
import feature;

bool installDmd(
    ref Terminal t,
    ref RealTimeConsoleInput input,
    TargetVersion ver,
    Download[] downloads
)
{
    if(!extractToFolder(downloads[0].getOutputPath, buildNormalizedPath(std.file.getcwd, "D"), t, input))
    {
        t.writelnError("Install failed");
        t.flush;
        return false;
    }
    import std.system;

    string sys;
    string bin = "bin";
    switch(os) with(OS)
    {
        case osx: sys = "osx"; break;
        case win32, win64: sys = "windows"; break;
        case linux: sys = "linux"; bin = "bin64"; break;
        default: assert(false, "System not supported.");
    }
    string binPath = buildNormalizedPath(downloads[0].getOutputPath, "dmd2", sys, bin);
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
        ExistenceChecker(["dmdPath"], ["dmd"]),
        Installation([Download(
            DownloadURL(
                windows: "https://downloads.dlang.org/releases/2.x/$VERSION/dmd.$VERSION.windows.7z",
                linux: "https://downloads.dlang.org/releases/2.x/$VERSION/dmd.$VERSION.linux.tar.xz",
                osx: "https://downloads.dlang.org/releases/2.x/$VERSION/dmd.$VERSION.osx.tar.xz",
            ),
            outputPath: "$TEMP/$NAME",
        )], &installDmd), 
        (ref Terminal){addToPath(configs["dmdPath"].str.buildNormalizedPath);},
        VersionRange.parse("2.105.0", "2.106.0")
    );
}
void start()
{
    
}