module feature;
import commons;
public import std.functional:toDelegate;

///URLs supports $VERSION
struct DownloadURL
{
    string windows;
    string linux;
    string osx;

    static DownloadURL any(string url)
    {
        return DownloadURL(url, url, url);
    }

    string get(TargetVersion ver) const
    {
        import std.string:replace;
        string ret;
        version(Windows) ret = windows;
        else version(linux) ret = linux;
        else version(OSX) ret = osx;
        return ret.replace("$VERSION", ver.toString);
    }
    string getDownloadFileName(TargetVersion ver) const
    {
        return get(ver).baseName;
    }
}

struct Download
{
    DownloadURL url;
    ///Supports $CWD, $TEMP, $VERSION and $NAME
    string outputPath = "$TEMP$NAME";
    ///Negative version ignored.
    TargetVersion ver;
    void function(string outputPath) onDownloadFinish;

    bool download(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver)
    {
        this.ver = ver;
        commons.downloadWithProgressBar(t, url.get(ver), getOutputPath(ver));
        return true;
    }
    string getOutputPath() const
    {
        return getOutputPath(ver);
    }

    string getOutputPath(TargetVersion ver) const
    {
        import std.conv:to;
        import std.string;
        string ret = replace(outputPath, "$CWD", std.file.getcwd);
        ret = replace(ret, "$TEMP", std.file.tempDir);
        ret = replace(ret, "$NAME", url.getDownloadFileName(ver));
        ret = replace(ret, "$VERSION", ver.toString);
        return ret;
    }
}

struct Installation
{
    Download[] downloadsRequired;
    bool delegate(
        ref Terminal t, 
        ref RealTimeConsoleInput input, 
        TargetVersion ver, 
        Download[] content
    ) installer;

    /** 
     * Follows the same order from `downloadsRequired`
     * May receive null if no extraction is desired for the download.
     * Accepts $CWD and $VERSION
     */
    string[] extractionPathList;

    string getExtractionPath(size_t index, TargetVersion ver)
    {
        import std.string;
        return extractionPathList[index].replace("$CWD", std.file.getcwd).replace("$VERSION", ver.toString).buildNormalizedPath;
    }

    bool install(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver)
    {
        foreach(i, ref d; downloadsRequired)
        {
            if(!std.file.exists(d.getOutputPath(ver)))
            {
                t.writeln("Downloading ", d.url.get(ver), " --> ", d.getOutputPath(ver));
                t.flush;
                if(!d.download(t, input, ver)) return false;
            }
            if(i < extractionPathList.length && extractionPathList[i].length)
            {
                import std.file;
                string extractionPath = getExtractionPath(i, ver);
                
                if(!extractToFolder(d.getOutputPath(ver), extractionPath, t, input))
                    return false;
            }
        }
        if(installer)
            return installer(t, input, ver, downloadsRequired);
        return true;
    }

}

struct Task(alias Fn)
{
    import std.traits;
    import std.meta;

    Feature*[] dependencies;
    private static auto fn = &Fn;
    static assert(is(Parameters!Fn[0] == Feature*[]), "The first argument of a Task function must be Feature*[]");

    auto execute(Parameters!Fn[1..$] args)
    {
        if(dependencies.length == 0)
            throw new Error("Your task has no dependency. Maybe you forgot to include it in the mixin StartFeatures! list?");
        foreach(dep; dependencies)
        {
            if(!dep.getFeature(args[0], args[1], dep.supportedVersion.max))
                throw new Exception("Could not get the feature named '"~dep.name~"' for executing the task.");
        }
        return fn(dependencies, args);
    }   
}

public import std.system;
struct Feature
{
    string name;
    string description;
    /** 
     * Checks the existence in $PATH
     * Checks the existence in gameBuild
     */
    ExistenceChecker existenceChecker;
    /** 
     * Gets an optional Download[] array, and an installer function
     * which contains the downloaded files information
     */
    Installation installer;
    /** 
     * A function that is executed exactly once after the installation
     * was succeeded.
     */
    void function(ref Terminal t, string where) startUsingFeature;
    /** 
     * Range of supported versions. May support in the feature also
     * version whitelisting. 
     */
    VersionRange supportedVersion;
    /**
     * The version that was actually chosen
     */
    TargetVersion currentVersion;
    /**
    * When empty it means it is required on every OS.
    * This was made because if it is not required in any OS, simply don't
    * put in the dependencies
    */
    OS[] requiredOn;

    /** 
     * Dependencies must be initialized in a 2-way start.
     * First, every dependency is started with its own information
     * After that, all the dependencies are started.
     */
    Feature*[] dependencies;

    bool isRequired()
    {
        if(requiredOn.length == 0)
            return true;
        foreach(req; requiredOn) if(req == os) return true;
        return false;
    }
    

    Feature*[] getAllDependencies()
    {
        bool[Feature*] visited;
        Feature*[] ret;
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

    private bool startedUsing = false;

    bool getFeature(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion v = TargetVersion.init)
    {
        if(v == TargetVersion.init)
        {
            if(currentVersion != TargetVersion.init)
                v = currentVersion;
            else
            {
                v = supportedVersion.max;
                currentVersion = v;
            }
        }
        if(!supportedVersion.isInRange(v))
        {
            t.writelnError("Unsupported version '",v.toString,"' for feature ", name, 
                ".\n\t Supported versions are ", supportedVersion.toString);
            return false;
        }
        foreach(Feature* dep; getAllDependencies)
        {
            if(*dep != Feature.init && !dep.getFeature(t, input, dep.supportedVersion.max))
            {
                t.writelnError("Could not get feature '",name,"': Requires: ", dep.name);
                return false;
            }
        }
        ExistenceStatus status = existenceChecker.existStatus(t, v);
        if(status.place == ExistenceStatus.Place.notFound)
        {
            import std.conv:to;
            t.writeln("Installation: ", name, " v", v.toString, "\n\t", description);
            t.flush;
            if(!installer.install(t, input, v))
            {
                t.writelnError("Could not install feature ", name);
                return false;
            }
            status = existenceChecker.existStatus(t, v);
        }
        if(status.place == ExistenceStatus.Place.notFound)
            throw new Error(`Could not find `~name~` v`~v.toString~"\n\t"~description~" even after installation");
        if(!startedUsing)
        {
            startedUsing = true;
            if(startUsingFeature !is null)
            {
                string where = status.where;
                if(status.place == ExistenceStatus.Place.inConfig)
                    where = configs[where].str;
                startUsingFeature(t, where);
            }
        }
        return true;
    }
}
mixin template StartFeatures(string[] features)
{
    static this()
    {
        static foreach(f; features)
        {
            mixin("import ",f," = features.",f,";");
            mixin(f,".initialize();");
        }
        static foreach(f; features)
        {
            mixin(f,".start();");
        }
    }
}

struct ExistenceStatus
{
    static enum Place
    {
        notFound,
        inConfig,
        inPath,
        custom
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
    bool delegate(ref Terminal t, TargetVersion v, out ExistenceStatus where) checkExistenceFn;


    ExistenceStatus existStatus(ref Terminal t, TargetVersion v)
    {
        ExistenceStatus status;
        int validCount = 0;
        foreach(i; gameBuildInput)
            if(i in configs && std.file.exists(configs[i].str)) validCount++;
        if(validCount && validCount == gameBuildInput.length)
        {
            status.place = ExistenceStatus.Place.inConfig;
            status.where = gameBuildInput[0];
            return status;
        }
        foreach(anAlias; expectedInPathAs)
        {
            string program = findProgramPath(anAlias);
            if(program.length)
            {
                status.where = program;
                status. place = ExistenceStatus.Place.inPath;
                return status;
            }
        }
        if(checkExistenceFn)
            checkExistenceFn(t, v, status);
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
        if(major == -1) return null;
        string ret = major.to!string;
        if(minor != -1) ret~= "." ~ minor.to!string;
        if(patch != -1) ret~= "." ~ patch.to!string;
        if(modifier.name.length) ret~= modifier.name;
        if(modifier.ver != -1) ret~= modifier.ver.to!string;
        return ret;
    }

    static TargetVersion fromGameBuild(string entry)
    {
        if(!(entry in configs))
            return TargetVersion.init;
        return TargetVersion.parse(configs[entry].str);
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
    static VersionRange parse(string min, string max = null)
    {
        if(max == null) max = min;
        return VersionRange(TargetVersion.parse(min), TargetVersion.parse(max));
    }

    string toString()
    {
        return min.toString ~ " ~ " ~ max.toString;
    }
    /** 
     * Compares both major and minor to min and max versions.
     * Currently, patch, modifier and modifier version are ignored.
     * Params:
     *   v = A Target version
     * Returns: 
     */
    bool isInRange(TargetVersion v)
    {
        if(this == VersionRange.init)
            return true;
        return v.major >= min.major  && v.major <= max.major &&
        v.minor >= min.minor && v.minor <= max.minor;
    }
}