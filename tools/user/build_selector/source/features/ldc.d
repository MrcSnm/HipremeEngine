module features.ldc;
import commons;
import feature;
enum LdcVersion = "1.36.0-beta1";


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
    import commons:removeExtension;
    string ldcPath = buildNormalizedPath(std.file.getcwd, "D", downloads[0].url.getDownloadFileName(ver).removeExtension);
    if(!extractToFolder(downloads[0].getOutputPath, ldcPath, t, input))
    {
        t.writelnError("Failed to extract");
        return false;
    }
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



Feature LDCFeature;
void initialize()
{
    LDCFeature = Feature(
        "LDC 2", 
        "LLVM Backend D Compiler. Used for development on various platforms",
        ExistenceChecker(["ldcPath"]),
        Installation([
            Download(
                DownloadURL(
                    windows: "https://github.com/ldc-developers/ldc/releases/download/v$VERSION/ldc2-$VERSION-windows-x64.7z",
                    linux: "https://github.com/ldc-developers/ldc/releases/download/v$VERSION/ldc2-$VERSION-linux-x86_64.tar.xz",
                    osx: "https://github.com/ldc-developers/ldc/releases/download/v$VERSION/ldc2-$VERSION-osx-universal.tar.xz"
                ),
                outputPath: "$TEMP$NAME",
            )
        ], &installLdc),
        (ref Terminal){addToPath(configs["ldcPath"].str.buildNormalizedPath);},
        VersionRange.parse("1.35.0", "1.36.0-beta1")
    );

}

void start()
{
    
}