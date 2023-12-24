module feature;
import commons;

struct Feature
{
    string name;
    string description;
    ExistenceChecker existenceChecker;

    void function(ref Terminal t) startUsingFeature;
    bool function(
        ref Terminal t, 
        ref RealTimeConsoleInput input, 
        int targetVer, 
        ExistenceStatus status
    ) installer;
    bool function(ref Terminal t, int targetVer) checkExistenceFn;
    VersionRange supportedVersion;
    Feature[] dependencies;

    Feature[] getAllDependencies()
    {
        bool[Feature] visited;
        Feature[] ret;
        foreach(dep; dependencies)
        {
            if(!(dep in visited))
            {
                visited[dep] = true;
                ret~= dep;
                ret~= dep.getAllDependencies;
            }
        }
        return ret.unique;
    }

    bool getFeature(ref Terminal t, ref RealTimeConsoleInput inpput, int targetVer)
    {
        if(!supportedVersion.isInRange(targetVer))
            return false;
        ExistenceStatus status = existenceChecker.existStatus;
        if(status == ExistenceStatus.notFound)
        {
            import std.conv:to;
            t.writeln("Installation: ", name, " v", targetVer.to!string, "\n\t", description);
            t.flush;
            if(!installer(t, input, targetVer, status))
                return false;
            startUsingFeature(t);
        }
        return true;
    }
}


enum ExistenceStatus
{
    inPath,
    inConfig,
    notFound
}
struct ExistenceChecker
{
    ///All the inputs related to this feature.
    string[] gameBuildInput;
    ///All the aliases this feature is expected in path.
    string[] expectedInPathAs;


    ExistenceStatus existStatus()
    {
        ExistenceStatus status;
        foreach(anAlias; expectedInPathAs)
        {
            if(findProgramPath(anAlias))
                status = ExistenceStatus.inPath;
        }
        int validCount = 0;
        foreach(i; gameBuildInput)
            if(i in configs) validCount++;
        if(validCount == gameBuildInput.length)
            status = ExistenceStatus.inConfig;
        return status;
    }

}
struct VersionRange
{
    int min, max;
    bool isInRange(int v){return v >= min && v <= max;}
}


Feature _7zFeature = Feature(
    "7zip",
    "Compressed file type",
    ExistenceChecker(["7zip"], ["7z", "7za"]),
    null,
    &install7zip2,
);

Feature GitFeature = Feature(
    "git",
    "Git Versioning software",
    ExistenceChecker(null, ["git"]),
    null,
    &installGit
);

Feature DMDFeature = Feature(
    "DMD",
    "Digital Mars D Compiler. Used for fast iteration development", 
    ExistenceChecker(["ldcPath"], ["ldc2"]),
    null, 
    null, 
    VersionRange(2_105_0, 2_106_0)
);
Feature LDCFeature = Feature(
    "LDC 2", 
    "LLVM Backend D Compiler. Used for development on various platforms",
    ExistenceChecker(["ldcPath"], ["ldc2"]),
    (ref Terminal){addToPath(configs["ldcPath"].str.buildNormalizedPath);},
    &hasLdc,
    VersionRange(1_35_0, 1_36_0)
);

Feature HipremeEngineFeature = Feature(
    "Hipreme Engine",
    "The engine for D game development",
    ExistenceChecker(["hipremeEnginePath"]),
    (ref Terminal){environment["HIPREME_ENGINE"] = configs["hipremeEnginePath"].str;},
    &installHipremeEngine,
    null,
    VersionRange(),
    [GitFeature]
);



