module feature;
import commons;

///URLs supports $VERSION
struct DownloadURL
{
    string windows;
    string linux;
    string osx;

    string get()
    {
        version(Windows) return windows;
        else version(linux) return linux;
        else version(OSX) return osx;
    }
}

struct Download
{
    DownloadURL url;
    ///Supports $CWD, $TEMP, $VERSION and $NAME
    string outputPath;
    ///Negative version ignored.
    int targetVer = -1;
    void function(string outputPath) onDownloadFinish;

    string getOutputPath()
    {
        import std.conv:to;
        import std.string;
        string ret = replace(outputPath, "$CWD", std.file.getcwd);
        ret = replace(ret, "$TEMP", std.file.tempDir);
        //TODO: Replace name
        ret = replace(ret, "$NAME", std.file.tempDir);
        
        string v = targetVer < 0 ? "" : to!string(targetVer);
        ret = replace(ret, "$VERSION", v);
        return ret;
    }
}

struct Installation
{
    Download[] downloadsRequired;
    bool function(
        ref Terminal t, 
        ref RealTimeConsoleInput input, 
        TargetVersion ver, 
        Download[] content
    ) installer;

    alias opCall = installer;
}

struct Task(alias Fn)
{
    import std.traits;
    Feature[] dependencies;
    private static auto fn = &Fn;

    auto execute(Parameters!Fn args)
    {
        foreach(dep; dependencies) dep.getFeature();
        return fn(args);
    }   
}

struct Feature
{
    import std.system;
    import features.ldc;
    string name;
    string description;
    ExistenceChecker existenceChecker;
    Installation installer;

    void function(ref Terminal t) startUsingFeature;
    VersionRange supportedVersion;
    Feature[] dependencies;

    /**
    * When empty it means it is required on every OS.
    * This was made because if it is not required in any OS, simply don't
    * put in the dependencies
    */
    OS[] requiredOn;

    bool isRequired()
    {
        if(requiredOn.length == 0)
            return true;
        foreach(req; requiredOn) if(req == os) return true;
        return false;
    }
    

    Feature[] getAllDependencies()
    {
        bool[Feature] visited;
        Feature[] ret;
        foreach(dep; dependencies)
        {
            if(!(dep in visited))
            {
                visited[dep] = true;
                if(dep.isRequired)
                {
                    ret~= dep;
                    ret~= dep.getAllDependencies;
                }
            }
        }
        return ret.unique;
    }

    bool getFeature(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion v = TargetVersion.init)
    {
        if(!supportedVersion.isInRange(v))
            return false;
        foreach(ref Feature dep; getAllDependencies)
        {
            if(!dep.getFeature(t, input, dep.supportedVersion.max))
            {
                t.writelnError("Could not get feature '",name,"': Requires: ", dep.name);
                return false;
            }
        }
        ExistenceStatus status = existenceChecker.existStatus;
        if(status.place == ExistenceStatus.Place.notFound)
        {
            import std.conv:to;
            t.writeln("Installation: ", name, " v", v.toString, "\n\t", description);
            t.flush;
            if(!installer(t, input, v, status))
                return false;
            startUsingFeature(t);
        }
        return true;
    }
}

struct ExistenceStatus
{
    static enum Place
    {
        inPath,
        inConfig,
        notFound
    }
    Place place;
    string where;
}

struct ExistenceChecker
{
    ///All the inputs related to this feature.
    string[] gameBuildInput;
    ///All the aliases this feature is expected in path.
    string[] expectedInPathAs;
    ///Optional. 
    bool function(ref Terminal t, int targetVer) checkExistenceFn;


    ExistenceStatus existStatus()
    {
        ExistenceStatus status;
        foreach(anAlias; expectedInPathAs)
        {
            string program = findProgramPath(anAlias);
            if(program.length)
            {
                status.where = program;
                status.place = ExistenceStatus.Place.inPath;
            }
        }
        int validCount = 0;
        foreach(i; gameBuildInput)
            if(i in configs) validCount++;
        if(validCount == gameBuildInput.length)
        {
            status.place = ExistenceStatus.inConfig;
            status.where = gameBuildInput[0];
        }
        return status;
    }

}
struct TargetVersion
{
    static struct Modifier
    {
        ///May receive a different modifier name.
        string name;
        int ver = -1;
    }
    int major = -1;
    int minor = -1;
    int patch = -1;
    Modifier modifier;

    string toString()
    {
        import std.conv:to;
        if(major == -1) return "0";
        string ret = major.to!string;
        if(minor != -1) ret~= "." ~ minor.to!string;
        if(patch != -1) ret~= "." ~ patch.to!string;
        if(modifier.name.length) ret~= modifier.name;
        if(modifier.ver != -1) ret~= modifier.ver.to!string;
        return ret;
    }

    static TargetVersion parse(string ver)
    {
        import std.conv:to;
        string[] vers = ver.split(".");
        TargetVersion ret;

        if(vers.length > 3) throw new Error("Unsupported format "~ver);
        if(vers.length > 0) ret.major = vers[0].to!int;
        if(vers.length > 1) ret.minor = vers[1].to!int;
        if(vers.length > 2)
        {
            import std.algorithm;
            ptrdiff_t ind = countUntil!((a) => a < '0' || a > '9')(vers[2]);
            if(ind == -1) ret.patch = vers[2].to!int; 
            else
            {
                ret.patch = vers[2][0..ind].to!int;
                ptrdiff_t ver2 = countUntil!((a) => a >= '0' && a <= '9')(vers[2][ind..$]);
                if(ver2 == -1) ret.modifier.name = vers[2][ind..$];
                else
                {
                    ret.modifier.name = vers[2][ind..ind+ver2];
                    ret.modifier.ver = vers[2][ind+ver2..$].to!int;
                }

            }
        }
        return ret;
    }

    unittest
    {
        TargetVersion v = TargetVersion.parse("1.36.0-beta1");
        assert(v.toString == "1.36.0-beta1");
        assert(v.major == 1);
        assert(v.minor == 36);
        assert(v.patch == 0);
        assert(v.modifier.name == "-beta");
        assert(v.modifier.ver == 1);
    }
}

struct VersionRange
{
    TargetVersion min, max;
    static VersionRange parse(string min, string max)
    {
        return VersionRange(TargetVersion.parse(min), TargetVersion.parse(max));
    }
    bool isInRange(TargetVersion v)
    {
        return v.major >= min.major  && v.major <= max.major &&
        v.minor >= min.minor && v.minor <= max.minor;
    }
}