module featurelib.config;

import std.file;
import std.json;
import std.path;
import std.process : environment;

/// OS section used by this build. Mirrors hbuild's gamebuild.json layout.
string currentPlatformSection()
{
    version (Windows) return "windows";
    else return "posix";
}

/// Persistent key/value store, partitioned by OS.
struct FeatureConfig
{
    JSONValue data;
    string path;

    static FeatureConfig open(string path)
    {
        FeatureConfig ret;
        ret.path = path;
        if (exists(path))
        {
            try ret.data = parseJSON(readText(path));
            catch (Exception) ret.data = JSONValue.init;
        }
        ret.ensureSections();
        return ret;
    }

    private void ensureSections()
    {
        if (data.type != JSONType.object)
            data = JSONValue(string[string].init);
        foreach (sectionName; ["windows", "posix"])
        {
            if (!(sectionName in data) || data[sectionName].type != JSONType.object)
                data[sectionName] = JSONValue(string[string].init);
        }
    }

    private ref JSONValue section()
    {
        ensureSections();
        return data[currentPlatformSection()];
    }

    private const(JSONValue)* sectionConst() const
    {
        if (data.type != JSONType.object)
            return null;
        const(JSONValue)* s = currentPlatformSection() in data;
        if (s is null || s.type != JSONType.object)
            return null;
        return s;
    }

    bool has(string key) const
    {
        const(JSONValue)* dataSection = sectionConst();
        return dataSection !is null && (key in *dataSection) !is null;
    }

    string get(string key) const
    {
        const(JSONValue)* dataSection = sectionConst();
        if (dataSection is null) return null;
        const(JSONValue)* value = key in *dataSection;
        return value is null ? null : value.str;
    }

    void set(string key, string value)
    {
        section()[key] = value;
    }

    void remove(string key)
    {
        ensureSections();
        data[currentPlatformSection()].object.remove(key);
    }

    ref JSONValue opIndex(string key)
    {
        return section()[key];
    }

    ref auto opIndexAssign(V)(V value, string key)
    {
        return section()[key] = value;
    }

    const(JSONValue)* opBinaryRight(string op, R)(R rhs) const if (op == "in")
    {
        const(JSONValue)* dataSection = sectionConst();
        return dataSection is null ? null : rhs in *dataSection;
    }

    void save() const
    {
        if (path.length)
            std.file.write(path, data.toPrettyString(JSONOptions.doNotEscapeSlashes));
    }
}

/// True when writes should go to the global (shareable) store.
private bool writeToGlobal;

/// Selects the store that receives writes for the duration of a feature.
struct ConfigScope
{
    private bool previous;

    this(bool shareable)
    {
        previous = writeToGlobal;
        writeToGlobal = shareable;
    }

    ~this()
    {
        writeToGlobal = previous;
    }
}

/// Local store next to the executable (non-shareable features) plus a global
/// store in the user config folder (features marked shareable).
struct FeatureConfigs
{
    FeatureConfig localConfig;
    FeatureConfig globalConfig;

    private ref FeatureConfig activeStore()
    {
        return writeToGlobal ? globalConfig : localConfig;
    }

    bool has(string key) const
    {
        return localConfig.has(key) || globalConfig.has(key);
    }

    string get(string key) const
    {
        if (localConfig.has(key)) return localConfig.get(key);
        return globalConfig.get(key);
    }

    void set(string key, string value)
    {
        this[key] = value;
    }

    void remove(string key)
    {
        localConfig.remove(key);
        globalConfig.remove(key);
    }

    ref JSONValue opIndex(string key)
    {
        if (localConfig.has(key)) return localConfig[key];
        if (globalConfig.has(key)) return globalConfig[key];
        return activeStore()[key];
    }

    ref auto opIndexAssign(V)(V value, string key)
    {
        // One key has a single owner, so drop any stale copy from the other store.
        if (writeToGlobal) localConfig.remove(key);
        else globalConfig.remove(key);
        return activeStore()[key] = value;
    }

    const(JSONValue)* opBinaryRight(string op, R)(R rhs) const if (op == "in")
    {
        const(JSONValue)* found = rhs in localConfig;
        return found is null ? rhs in globalConfig : found;
    }

    void save() const
    {
        localConfig.save();
        globalConfig.save();
    }
}

private string envOr(string name, string fallback)
{
    return name in environment ? environment[name] : fallback;
}

string getConfigFolder()
{
    version (Windows)
    {
        string base = envOr("APPDATA", envOr("LOCALAPPDATA", "."));
        return buildPath(base, "featurelib");
    }
    else version (OSX)
    {
        return buildPath(envOr("HOME", "."), "Library", "Application Support", "featurelib");
    }
    else
    {
        string base = envOr("XDG_CONFIG_HOME", null);
        if (!base.length) base = buildPath(envOr("HOME", "."), ".config");
        return buildPath(base, "featurelib");
    }
}

string getExecutableFolder()
{
    import core.runtime : Runtime;
    return Runtime.args[0].dirName;
}

string getConfigPath()
{
    return buildPath(getConfigFolder(), "features.json");
}

string getLocalConfigPath()
{
    return buildPath(getExecutableFolder(), "features.local.json");
}

FeatureConfigs configs;

void updateConfigFile()
{
    configs.save();
}

static this()
{
    string folder = getConfigFolder();
    try
    {
        if (!exists(folder)) mkdirRecurse(folder);
    }
    catch (Exception) {}

    configs.globalConfig = FeatureConfig.open(getConfigPath());
    configs.localConfig = FeatureConfig.open(getLocalConfigPath());
}

unittest
{
    string dir = buildPath(tempDir, "featurelib-config-test");
    if (exists(dir)) rmdirRecurse(dir);
    mkdirRecurse(dir);
    scope (exit) if (exists(dir)) rmdirRecurse(dir);

    FeatureConfig cfg = FeatureConfig.open(buildPath(dir, "features.json"));
    cfg["tool"] = "/opt/tool";
    assert(cfg.has("tool"));
    assert(cfg["tool"].str == "/opt/tool");
    assert("missing" !in cfg);

    string otherSection = currentPlatformSection() == "windows" ? "posix" : "windows";
    assert(!("tool" in cfg.data[otherSection]));

    cfg.save();

    FeatureConfig loaded = FeatureConfig.open(buildPath(dir, "features.json"));
    assert(loaded["tool"].str == "/opt/tool");
    assert(loaded.get("tool") == "/opt/tool");

    auto raw = parseJSON(readText(buildPath(dir, "features.json")));
    assert("windows" in raw);
    assert("posix" in raw);
}

unittest
{
    string dir = buildPath(tempDir, "featurelib-configs-test");
    if (exists(dir)) rmdirRecurse(dir);
    mkdirRecurse(dir);
    scope (exit) if (exists(dir)) rmdirRecurse(dir);

    FeatureConfigs stores;
    stores.localConfig = FeatureConfig.open(buildPath(dir, "local.json"));
    stores.globalConfig = FeatureConfig.open(buildPath(dir, "global.json"));

    {
        ConfigScope scope_ = ConfigScope(false);
        stores["localKey"] = "local";
    }
    {
        ConfigScope scope_ = ConfigScope(true);
        stores["globalKey"] = "global";
    }

    assert(stores.localConfig.get("localKey") == "local");
    assert(stores.globalConfig.get("globalKey") == "global");
    assert(stores.get("localKey") == "local");
    assert(stores.get("globalKey") == "global");
    assert("localKey" in stores);
    assert("globalKey" in stores);

    {
        ConfigScope scope_ = ConfigScope(true);
        stores["localKey"] = "moved";
    }
    assert(!stores.localConfig.has("localKey"));
    assert(stores.globalConfig.get("localKey") == "moved");
}
