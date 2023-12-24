module features.dmd;

import commons;
import feature;

private string getDmdLink()
{
    import std.system;
    string link = "https://downloads.dlang.org/releases/2.x/" ~ DmdVersion ~ "/dmd." ~ DmdVersion;
    return link ~ (os == OS.linux ? ".linux.tar.xz" : os == OS.osx ? ".osx.tar.xz" : ".windows.7z");
}
private string getDmdDownloadOutputName()
{
    version(Posix) return "dmd-"~DmdVersion~".tar.xz";
    else return "dmd-"~DmdVersion~".7z";
}
private string getDmdOutputPath()
{
    string outputPath = buildNormalizedPath(std.file.getcwd(), "D");
    string fileName = "dmd-"~DmdVersion~"-";
    version(Windows) fileName~= "windows-x64";
    else version(linux) fileName~= "linux-x86_64";
    else version(OSX) fileName~= "osx-universal";
    else assert(false, "Not implemented for your system.");
    return buildNormalizedPath(outputPath, fileName);
}

bool installDmd(
    ref Terminal t,
    ref RealTimeConsoleInput input,
    int targetVer,
    ExistenceStatus status
)
{
    if(status == ExistenceStatus.inPath)
    {
        t.writelnError("Different DMD Version. HipremeEngine will attempt to install locally DMD " ~DmdVersion);
        t.flush;
    }
    if(!installFileTo("Download D fast iteration compiler DMD "~DmdVersion, getDmdLink,
    getDmdDownloadOutputName, buildNormalizedPath(std.file.getcwd, "D"), t, input))
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
    string binPath = buildNormalizedPath(getDmdOutputPath, "dmd2", sys, bin);
    makeFileExecutable(buildNormalizedPath(binPath, "dmd"));
    makeFileExecutable(buildNormalizedPath(binPath, "dub"));
    makeFileExecutable(buildNormalizedPath(binPath, "rdmd"));

    configs["dmdVersion"] = DmdVersion;
    configs["dmdPath"] = binPath;
    updateConfigFile();
}