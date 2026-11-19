module hip.config.args;

///Help metadata for an accepted engine argument.
struct Help
{
    string name;
    string text;
}

///Argument wrapper: `specified` tells whether the CLI set it, so callers can
///fall back to a config/default when it didn't.
struct Opt(T)
{
    T value;
    bool specified;
    alias value this;
}

///Every CLI argument accepted by the engine.
struct HipremeEngineArgs
{
    @Help("help",        "Print this help and exit")                Opt!bool help;
    @Help("verbose",     "Enable verbose engine logging")           Opt!bool verbose;
    @Help("frame-guard", "Enable the frame allocator escape guard") Opt!bool frameGuard;
    @Help("project",     "Project path or Lua script to run")       Opt!string project;
}

///Bools accept `--name` and `--no-name`; `project` is the first positional.
HipremeEngineArgs parseHipremeEngineArgs(string[] argv, bool defaultFrameGuard = false)
{
    HipremeEngineArgs ret;
    ret.frameGuard.value = defaultFrameGuard;

    bool positional;
    foreach(i, token; argv)
    {
        if(i == 0) // executable path
            continue;
        if(token == "-h" || token == "--help")
        {
            ret.help.value = true;
            continue;
        }
        if(token.length < 3 || token[0 .. 2] != "--")
        {
            if(!positional)
            {
                ret.project.value = token;
                ret.project.specified = true;
                positional = true;
            }
            continue;
        }

        string name = token[2 .. $];
        bool negated;
        if(name.length > 3 && name[0 .. 3] == "no-")
        {
            name = name[3 .. $];
            negated = true;
        }

        static foreach(member; __traits(allMembers, HipremeEngineArgs))
        {{
            enum Help help = __traits(getAttributes, __traits(getMember, HipremeEngineArgs, member))[0];
            static if(is(typeof(__traits(getMember, HipremeEngineArgs, member).value) == bool))
            {
                if(name == help.name)
                {
                    __traits(getMember, ret, member).value = !negated;
                    __traits(getMember, ret, member).specified = true;
                }
            }
        }}
    }
    return ret;
}

void printHipremeEngineArgsHelp(void function(string) sink)
{
    sink("Usage: hipreme_engine [options] [project]");
    sink("Options:");
    static foreach(member; __traits(allMembers, HipremeEngineArgs))
    {{
        enum Help help = __traits(getAttributes, __traits(getMember, HipremeEngineArgs, member))[0];
        static if(member == "help")
            sink("  -h, --help\t" ~ help.text);
        else static if(is(typeof(__traits(getMember, HipremeEngineArgs, member).value) == bool))
            sink("  --" ~ help.name ~ ", --no-" ~ help.name ~ "\t" ~ help.text);
        else
            sink("  <" ~ help.name ~ ">\t" ~ help.text);
    }}
}

unittest
{
    auto a = parseHipremeEngineArgs(["engine", "--verbose", "--frame-guard", "myProject"]);
    assert(a.verbose.value && a.verbose.specified);
    assert(a.frameGuard.value && a.frameGuard.specified);
    assert(a.project.value == "myProject" && a.project.specified);

    auto b = parseHipremeEngineArgs(["engine", "--no-frame-guard"], true);
    assert(!b.frameGuard.value && b.frameGuard.specified);

    assert(parseHipremeEngineArgs(["engine", "-h"]).help.value);
    assert(!parseHipremeEngineArgs(["engine"]).frameGuard.specified);
}
