module d_getter;
import commons;
enum LdcVersion = "1.33.0-beta1";


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
    version(Windows) return buildNormalizedPath(std.file.tempDir, "ldc2-"~LdcVersion~".7z");
    else version(Posix) return buildNormalizedPath(std.file.tempDir, "ldc2-"~LdcVersion~".tar.xz");
    else assert(false, "System not supported.");
}

bool downloadLdc(ref Terminal t, ref RealTimeConsoleInput input)
{
    if(!downloadFileIfNotExists("Get LDC2 "~LdcVersion~" and dub.", getLdcLink, 
        buildNormalizedPath(std.file.tempDir, getLdcDownloadOutputName), t, input
    ))
    {
        t.writelnError("Could not download Ldc.");
        t.flush;
        return false;
    }
    return true;
}

bool installD(ref Terminal t, ref RealTimeConsoleInput input)
{
    bool existsLdc = ("ldcPath" in configs) !is null;
    bool isExpectedVersion;
    if("ldcVersion" in configs)
    {
        isExpectedVersion = configs["ldcVersion"].str == LdcVersion;
        if(!isExpectedVersion)
        {
            t.writelnError("Different LDC Version. Your system will attempt to install LDC2 " ~LdcVersion);
            t.flush;
        }
    }
    else
    {
        t.writelnHighlighted("No ldcVersion specified, your system will attempt to install LDC2 " ~LdcVersion);
        t.flush;
    }
    if(!existsLdc || !isExpectedVersion)
    {
        if(!downloadLdc(t, input))
        {
            t.writelnError("Install failed");
            return false;
        }

        version(Windows)
        {
            if(!extract7ZipToFolder(getLdcDownloadOutputName, 
                buildNormalizedPath(std.file.getcwd, "D"), t, input
            ))
            {
                t.writelnError("Could not extract LDC.");
                return false;
            }
        }
        else version(Posix)
        {
            if(!extractTarGzToFolder(getLdcDownloadOutputName,
                buildNormalizedPath(std.file.getcwd, "D"), t
            ))
            {
                t.writelnError("Could not extract LDC.");
                return false;
            }
        }
        auto binPath = buildNormalizedPath(getOutputPath, "bin");
        makeFileExecutable(buildNormalizedPath(binPath, "rdmd"));
        makeFileExecutable(buildNormalizedPath(binPath, "ldc2"));
        makeFileExecutable(buildNormalizedPath(binPath, "ldmd2"));
        makeFileExecutable(buildNormalizedPath(binPath, "dub"));
        configs["ldcVersion"] = LdcVersion;
        configs["ldcPath"] = getOutputPath;
        configs["dubPath"] = binPath;
        updateConfigFile();
    }

    return true;
}

bool setupD(ref Terminal t, ref RealTimeConsoleInput input)
{
    if(!installD(t, input))
    {
        t.writelnError("Could not setup D. Aborting process");
        return false;
    }
    string concatPath = ":";
    version(Windows) concatPath = ";";
    environment["PATH"] = buildNormalizedPath(configs["ldcPath"].str, "bin")~concatPath~environment["PATH"];


    return true;
}