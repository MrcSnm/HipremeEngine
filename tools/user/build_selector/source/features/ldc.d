module features.ldc;

private string getLdcLink()
{
    string baseDownloadLink = "https://github.com/ldc-developers/ldc/releases/download/";
    baseDownloadLink~= "v"~LdcVersion;
    baseDownloadLink~= "/ldc2-"~LdcVersion~"-";
    version(Windows)
        baseDownloadLink~= "windows-x64.7z";
    else version(OSX)
        baseDownloadLink~= "osx-universal.tar.xz";
    else version(linux)
        baseDownloadLink~= "linux-x86_64.tar.xz";
    else assert(false, "D is not supported in your system.");
    return baseDownloadLink;
}

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
private void overrideLdcConf(ref Terminal t)
{
    static import std.file;
    string ldc2Conf = buildNormalizedPath(getOutputPath(), "etc", "ldc2.conf");
    t.writelnHighlighted("Overriding ldc2.conf to use one next to ldc executable.");
    std.file.copy(ldc2Conf, buildNormalizedPath(getOutputPath(), "bin", "ldc2.conf"));
}


bool installD(ref Terminal t, ref RealTimeConsoleInput input)
{
    bool existsDmd = ("dmdPath" in configs) !is null;
    bool existsLdc = ("ldcPath" in configs) !is null;
    bool isDmdExpectedVersion = existsDmd && configs["dmdVersion"].str == DmdVersion;
    bool isLdcExpectedVersion = existsLdc && configs["ldcVersion"].str == LdcVersion;
    
    if(!isLdcExpectedVersion)
    {
        if(!existsLdc)
            t.writelnHighlighted("No ldcVersion specified, your HipremeEngine will attempt to install locally LDC2 " ~LdcVersion ~ 
            wontAffectMessage);
        else
            t.writelnError("Different LDC Version. HipremeEngine will attempt to install locally LDC2 " ~LdcVersion);
        t.flush;
        if(!installFileTo("Download D cross compiler LDC2 "~LdcVersion, getLdcLink,
        getLdcDownloadOutputName, buildNormalizedPath(std.file.getcwd, "D"), t, input))
        {
            t.writelnError("Install failed");
            return false;
        }
        t.writeln("Installed.");
        auto binPath = buildNormalizedPath(getOutputPath, "bin");
        makeFileExecutable(buildNormalizedPath(binPath, "rdmd"));
        makeFileExecutable(buildNormalizedPath(binPath, "ldc2"));
        makeFileExecutable(buildNormalizedPath(binPath, "ldmd2"));
        makeFileExecutable(buildNormalizedPath(binPath, "dub"));
        overrideLdcConf(t);

        string rdmd = buildNormalizedPath(binPath, "rdmd");
        version(Windows) rdmd = rdmd.setExtension("exe");
        configs["ldcVersion"] = LdcVersion;
        configs["ldcPath"] = getOutputPath;
        configs["rdmdPath"] = rdmd;
        configs["dubPath"] = binPath;
        updateConfigFile();
    }
    

    return true;
}