module features.ldc;
import commons;
import feature;
enum LdcVersion = "1.36.0-beta1";

Download LDCDownload = Download(
    DownloadURL(
        windows: "https://github.com/ldc-developers/ldc/releases/download/v$VERSIONldc2-$VERSIONwindows-x64.7z",
        linux: "https://github.com/ldc-developers/ldc/releases/download/v$VERSIONldc2-$VERSIONlinux-x86_64.tar.xz",
        osx: "https://github.com/ldc-developers/ldc/releases/download/v$VERSIONldc2-$VERSIONosx-universal.tar.xz"
    )
);


private string getOutputPath()
{
    string outputPath = buildNormalizedPath(std.file.getcwd(), "D");
    string fileName = "ldc2-"~LdcVersion~"-";
    version(Windows) fileName~= "windows-x64";
    else version(linux) fileName~= "linux-x86_64";
    else version(OSX) fileName~= "osx-universal";
    else assert(false, "Not implemented for your system.");
    return buildNormalizedPath(outputPath, fileName);
}

private string getLdcDownloadOutputName()
{
    static string fileName;
    if(!fileName)
    {
        fileName = "ldc2-"~LdcVersion~"-";
        version(Windows) fileName~= "windows-x64.7z";
        else version(linux) fileName~= "linux-x86_64.tar.xz";
        else version(OSX) fileName~= "osx-universal.tar.xz";
        else assert(false, "System not supported.");
    }
    return fileName;
}


/** 
 * Must check if ~/.ldc2.conf (%APPDATA%\.ldc\ldc2.conf) exists and then ignore it.
 * This is a fix since Hipreme Engine should contain the entire build command and make it
 * predictable.
 *  Here, it uses the 2nd ldc2.conf, so, one is still able to tweak although not recommended
 * https://wiki.dlang.org/Using_LDC - Next to ldc2 executable.
 */
private void overrideLdcConf(ref Terminal t, string outputPath)
{
    static import std.file;
    string ldc2Conf = buildNormalizedPath(outputPath, "etc", "ldc2.conf");
    t.writelnHighlighted("Overriding ldc2.conf to use one next to ldc executable.");
    std.file.copy(ldc2Conf, buildNormalizedPath(outputPath, "bin", "ldc2.conf"));
}


bool installLdc(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] downloads)
{
    string ldcPath = buildNormalizedPath(std.file.getcwd, "D");
    if(!extractToFolder(downloads[0].getOutputPath, ldcPath, t, input))
    {
        t.writelnError("Install failed");
        return false;
    }
    t.writeln("Installed.");
    auto binPath = buildNormalizedPath(ldcPath, "bin");
    foreach(executable; ["ldc2", "ldmd2", "rdmd", "dub"])
        makeFileExecutable(buildNormalizedPath(binPath, executable));
    overrideLdcConf(t, ldcPath);

    string rdmd = buildNormalizedPath(binPath, "rdmd");
    version(Windows) rdmd = rdmd.setExtension("exe");
    configs["ldcVersion"] = ver.toString;
    configs["ldcPath"] = ldcPath;
    configs["rdmdPath"] = rdmd;
    configs["dubPath"] = binPath;
    updateConfigFile();
    

    return true;
}



immutable Feature LDCFeature;
shared static this()
{
    LDCFeature = Feature(
        "LDC 2", 
        "LLVM Backend D Compiler. Used for development on various platforms",
        ExistenceChecker(["ldcPath"], ["ldc2"]),
        Installation([LDCDownload], &installLdc),
        (ref Terminal){addToPath(configs["ldcPath"].str.buildNormalizedPath);},
        VersionRange.parse("1.35.0", "1.36.0-beta1")
    );

}
