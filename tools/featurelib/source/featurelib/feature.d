module featurelib.feature;

import std.file;
import std.path : baseName, buildNormalizedPath;
import featurelib.terminal : Terminal, ConsoleInput;
import featurelib.config : configs, getConfigFolder, ConfigScope;
import featurelib.download : downloadWithProgressBar;
import featurelib.extract : extractToFolder;
import featurelib.util : findProgramPath, unique;
public import std.functional : toDelegate;
public import std.system;

/// URLs support $VERSION.
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
        import std.string : replace;
        string ret;
        version (Windows) ret = windows;
        else version (linux) ret = linux;
        else version (OSX) ret = osx;
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
    /// Supports $CWD, $TEMP, $VERSION, $NAME and $CONFIG_DIR.
    string outputPath = "$TEMP$NAME";
    /// Negative version is ignored.
    TargetVersion ver;

    bool download(ref Terminal t, ConsoleInput input, TargetVersion ver)
    {
        this.ver = ver;
        downloadWithProgressBar(t, url.get(ver), getOutputPath(ver));
        return true;
    }

    string getOutputPath() const
    {
        return getOutputPath(ver);
    }

    string getOutputPath(TargetVersion ver) const
    {
        import std.string : replace;
        string ret = replace(outputPath, "$CWD", std.file.getcwd);
        ret = replace(ret, "$TEMP", std.file.tempDir);
        ret = replace(ret, "$NAME", url.getDownloadFileName(ver));
        ret = replace(ret, "$VERSION", ver.toString);
        ret = replace(ret, "$CONFIG_DIR", getConfigFolder());
        return ret;
    }
}

struct Installation
{
    Download[] downloadsRequired;
    bool delegate(
        ref Terminal t,
        ConsoleInput input,
        TargetVersion ver,
        Download[] content,
        string[] extractionPaths) installer;

    /**
     * Follows the same order from `downloadsRequired`.
     * May receive null if no extraction is desired for the download.
     * Accepts $CWD, $VERSION and $CONFIG_DIR.
     */
    private string[] extractionPathList;

    string getExtractionPath(size_t index, TargetVersion ver)
    {
        import std.string : replace;
        return extractionPathList[index]
            .replace("$CWD", std.file.getcwd)
            .replace("$VERSION", ver.toString)
            .replace("$CONFIG_DIR", getConfigFolder())
            .buildNormalizedPath;
    }

    string[] getExtractionPathList(TargetVersion ver)
    {
        string[] ret = new string[extractionPathList.length];
        foreach (i; 0 .. extractionPathList.length)
            ret[i] = getExtractionPath(i, ver);
        return ret;
    }

    bool install(ref Terminal t, ConsoleInput input, TargetVersion ver)
    {
        foreach (i, ref d; downloadsRequired)
        {
            if (!std.file.exists(d.getOutputPath(ver)))
            {
                t.writeln("Downloading ", d.url.get(ver), " --> ", d.getOutputPath(ver));
                t.flush();
                if (!d.download(t, input, ver)) return false;
            }
            if (i < extractionPathList.length && extractionPathList[i].length)
            {
                string extractionPath = getExtractionPath(i, ver);
                if (!extractToFolder(d.getOutputPath(ver), extractionPath, t, input))
                    return false;
            }
        }
        if (installer)
            return installer(t, input, ver, downloadsRequired, getExtractionPathList(ver));
        return true;
    }
}

/**
 * Wraps a function so that every Feature declared in `dependencies` is
 * provisioned before it runs. The first parameter must be Feature*[].
 */
struct Task(alias Fn)
{
    import std.traits;

    Feature*[] dependencies;
    private static auto fn = &Fn;
    static assert(is(Parameters!Fn[0] == Feature*[]), "The first argument of a Task function must be Feature*[]");

    auto execute(Parameters!Fn[1 .. $] args)
    {
        foreach (dep; dependencies)
        {
            if (!dep.getFeature(args[0], args[1]))
                throw new Exception("Could not get the feature named '" ~ dep.name ~ "' for executing the task.");
        }
        return fn(dependencies, args);
    }
}

struct Feature
{
    string name;
    string description;
    /// Checks the existence in the lib config and in $PATH.
    ExistenceChecker existenceChecker;
    /// Gets an optional Download[] array, and an installer function which
    /// contains the downloaded files information.
    Installation installer;
    /// Executed exactly once after the installation succeeds.
    void function(ref Terminal t, string where) startUsingFeature;
    /// Range of supported versions.
    VersionRange supportedVersion;
    /// The version that was actually chosen.
    TargetVersion currentVersion;
    /**
     * When empty it means it is required on every OS.
     * This was made because if it is not required in any OS, simply don't
     * put it in the dependencies.
     */
    OS[] requiredOn;
    /**
     * Dependencies must be initialized in a 2-way start.
     * First, every dependency is started with its own information.
     * After that, all the dependencies are started.
     */
    Feature*[] dependencies;
    /// When true, this feature's config keys are stored in the global store;
    /// otherwise they stay next to the executable.
    bool shareable;

    bool isRequired()
    {
        if (requiredOn.length == 0)
            return true;
        foreach (req; requiredOn) if (req == os) return true;
        return false;
    }

    Feature*[] getAllDependencies()
    {
        bool[Feature*] visited;
        Feature*[] ret;

        void collect(Feature* dep)
        {
            if (dep is null || (dep in visited))
                return;
            visited[dep] = true;
            if (!dep.isRequired)
                return;
            ret ~= dep;
            foreach (child; dep.dependencies)
                collect(child);
        }

        foreach (dep; dependencies)
            collect(dep);
        return unique(ret);
    }

    private bool startedUsing = false;

    bool getFeature(ref Terminal t, ConsoleInput input, TargetVersion v = TargetVersion.init)
    {
        if (this == Feature.init)
            throw new Error("Feature not initialized. Be sure to call its initialize().");
        ConfigScope configScope = ConfigScope(shareable);
        if (v == TargetVersion.init)
        {
            if (currentVersion != TargetVersion.init)
                v = currentVersion;
            else
            {
                v = supportedVersion.max;
                currentVersion = v;
            }
        }
        if (!supportedVersion.isInRange(v))
        {
            t.writelnError("Unsupported version '", v.toString, "' for feature ", name,
                ".\n\t Supported versions are ", supportedVersion.toString);
            return false;
        }
        foreach (Feature* dep; getAllDependencies)
        {
            if (*dep != Feature.init && !dep.getFeature(t, input, dep.supportedVersion.max))
            {
                t.writelnError("Could not get feature '", name, "': Requires: ", dep.name);
                return false;
            }
        }
        ExistenceStatus status = existenceChecker.existStatus(t, v);
        if (status.place == ExistenceStatus.Place.notFound)
        {
            t.writeln("Installation: ", name, " v", v.toString, "\n\t", description);
            t.flush();
            if (!installer.install(t, input, v))
            {
                t.writelnError("Could not install feature ", name);
                return false;
            }
            status = existenceChecker.existStatus(t, v);
        }
        if (status.place == ExistenceStatus.Place.notFound)
            throw new Error(`Could not find ` ~ name ~ ` v` ~ v.toString ~ "\n\t" ~ description ~ " even after installation");
        if (!startedUsing)
        {
            startedUsing = true;
            if (startUsingFeature !is null)
            {
                string where = status.where;
                if (status.place == ExistenceStatus.Place.inConfig && (where in configs))
                    where = configs[where].str;
                startUsingFeature(t, where);
            }
        }
        return true;
    }
}

/**
 * Pass imported feature modules as arguments, e.g.
 * `mixin StartFeatures!(features.git, features.ldc);`.
 * Every initialize runs first, then every start, so features can reference
 * each other in either direction.
 */
mixin template StartFeatures(modules...)
{
    static this()
    {
        static foreach (mod; modules)
            mod.initialize();
        static foreach (mod; modules)
            mod.start();
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
    /// All the config keys related to this feature.
    string[] configInput;
    /// All the aliases this feature is expected in path.
    string[] expectedInPathAs;
    /// Optional.
    bool delegate(ref Terminal t, TargetVersion v, out ExistenceStatus where) checkExistenceFn;

    ExistenceStatus existStatus(ref Terminal t, TargetVersion v)
    {
        ExistenceStatus status;
        int validCount = 0;
        foreach (i; configInput)
            if (i in configs && std.file.exists(configs[i].str)) validCount++;
        if (validCount && validCount == configInput.length)
        {
            status.place = ExistenceStatus.Place.inConfig;
            status.where = configInput[0];
            return status;
        }
        foreach (anAlias; expectedInPathAs)
        {
            string program = findProgramPath(anAlias);
            if (program.length)
            {
                status.where = program;
                status.place = ExistenceStatus.Place.inPath;
                return status;
            }
        }
        if (checkExistenceFn)
            checkExistenceFn(t, v, status);
        return status;
    }
}

struct TargetVersion
{
    static struct Modifier
    {
        /// May receive a different modifier name.
        string name;
        int ver = -1;
    }
    int major = -1;
    int minor = -1;
    int patch = -1;
    Modifier modifier;

    string toString()
    {
        import std.conv : to;
        if (major == -1) return null;
        string ret = major.to!string;
        if (minor != -1) ret ~= "." ~ minor.to!string;
        if (patch != -1) ret ~= "." ~ patch.to!string;
        if (modifier.name.length) ret ~= modifier.name;
        if (modifier.ver != -1) ret ~= modifier.ver.to!string;
        return ret;
    }

    static TargetVersion fromConfig(string entry)
    {
        return entry in configs ? parse(configs[entry].str) : TargetVersion.init;
    }

    static TargetVersion parse(string ver)
    {
        import std.conv : to;
        import std.string : split;
        import std.algorithm : countUntil;

        string[] vers = ver.split(".");
        TargetVersion ret;

        if (vers.length > 3) throw new Error("Unsupported format " ~ ver);
        if (vers.length > 0) ret.major = vers[0].to!int;
        if (vers.length > 1) ret.minor = vers[1].to!int;
        if (vers.length > 2)
        {
            ptrdiff_t ind = countUntil!((a) => a < '0' || a > '9')(vers[2]);
            if (ind == -1) ret.patch = vers[2].to!int;
            else
            {
                ret.patch = vers[2][0 .. ind].to!int;
                ptrdiff_t ver2 = countUntil!((a) => a >= '0' && a <= '9')(vers[2][ind .. $]);
                if (ver2 == -1) ret.modifier.name = vers[2][ind .. $];
                else
                {
                    ret.modifier.name = vers[2][ind .. ind + ver2];
                    ret.modifier.ver = vers[2][ind + ver2 .. $].to!int;
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
        if (max == null) max = min;
        return VersionRange(TargetVersion.parse(min), TargetVersion.parse(max));
    }

    string toString()
    {
        return min.toString ~ " ~ " ~ max.toString;
    }

    /**
     * Compares both major and minor to min and max versions.
     * Currently, patch, modifier and modifier version are ignored.
     */
    bool isInRange(TargetVersion v)
    {
        if (this == VersionRange.init)
            return true;
        return v.major >= min.major && v.major <= max.major &&
            v.minor >= min.minor && v.minor <= max.minor;
    }
}

unittest
{
    Feature root, b, c, common;
    b.dependencies = [&common];
    c.dependencies = [&common];
    root.dependencies = [&b, &c];
    assert(root.getAllDependencies.length == 3);

    Feature x, y;
    x.dependencies = [&y];
    y.dependencies = [&x];
    assert(x.getAllDependencies.length == 2);
}
