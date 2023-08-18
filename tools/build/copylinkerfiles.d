import std;

enum Arguments
{
    dubArgs = 1,
    outputPath = 2,
    dflags = 3
}

string[] separateFromString(string str)
{
    string[] strings;
    
    bool isCapturing = false;
    string currStr;
    foreach(ch; str)
    {
        if(ch == '"' || ch == '\'')
        {
            if(isCapturing)
            {
                strings~= currStr;
                currStr = "";
            }
            isCapturing = !isCapturing;
        } else if(isCapturing) currStr~= ch;
    }
    if(currStr.length) strings~= currStr;
    return strings;
}

int main(string[] args)
{
    if(args.length <= Arguments.dubArgs)
    {
        writeln("Missing target dubArgs for calling dub describe");
        return 1;
    }
    if(args.length <= Arguments.outputPath)
    {
        writeln("Missing target outputPath for copying linker files");
        return 1;
    }
    string dubArgs = args[Arguments.dubArgs];
    string outputPath = args[Arguments.outputPath];
    writeln(dubArgs);
    writeln(outputPath);

    string[] envDflags;
    if(args.length > Arguments.dflags)
        envDflags = args[Arguments.dflags..$];

    environment["DFLAGS"] = envDflags.join(" ");
    string dub = "dub ";
    if("DUB" in environment)
    {
        dub = environment["DUB"];
        writeln("Using dub: ", dub);
    }
    auto ret = executeShell(dub~" describe --data=linker-files "~dubArgs~" --vquiet");
    string librariesData = ret.output;
    string[] libraries = separateFromString(librariesData);
    writeln("Found libraries ", libraries.map!(lName => lName.baseName));

    string libIncludes = buildNormalizedPath(outputPath, "..", "libIncludes.txt");
    std.file.write(libIncludes, libraries.map!(lName => "-l"~lName.baseName.stripExtension[3..$]).join(" "));

    string libNames = "";
    mkdirRecurse(outputPath);
    foreach(l; libraries)
    {
        string n = baseName(l);
        copy(l, buildPath(outputPath, n));
        libNames~= n;
        if(l != libraries[$-1])
            libNames~= " ";
    }
    return 0;
}