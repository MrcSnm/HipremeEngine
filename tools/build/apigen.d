module tools.build.apigen;
static import std.file;
import std.stdio;
import std.array;
import std.string:indexOf;
import std.traits;
import std.path;
import std.process;
import std.algorithm.sorting;
import std.algorithm.searching;
import std.algorithm.mutation;


version(SecondRun){}
else version = FirstRun;

enum TheVersion = "-version=";
enum StrImport = "-J=";
enum MV = "-mv=";


string[] unique(string[] input)
{
    bool[string] ret;
    foreach(i; input) ret[i] = true;
    return ret.keys.dup;
}

/** 
 * 
 * Params:
 *   enginePath = The dub path from the engine
 * Returns: All the import paths which the engine uses to build
 */
string[] getImportPaths(string enginePath)
{
    string currDir = std.file.getcwd();
    std.file.chdir(enginePath);
    scope(exit) std.file.chdir(currDir);
    auto exec = executeShell("dub describe --data=import-paths --data=dflags --vquiet");
    if(exec.status)
    {
        writeln("Error executing dub on path ", enginePath, ": ", exec.output);
        return [];
    }
    static string[] separeMvFlags(ref string[] input)
    {
        string[] ret;
        for(int i = 0; i < input.length; i++)
        {
            auto res = findSplit(input[i], "-mv=");
            bool found = res[1].length != 0;
            if(found)
            {
                ret~= MV~res[2];
                input = input[0..i] ~ input[i+1..$];
                i--;
            }
        }
        return ret;
    }
    string[] importsTemp = split(exec.output.replace("\"", "").replace("\r", "").replace("\n", ""), " ");
    importsTemp = unique(importsTemp);
    string[] mvFlags = separeMvFlags(importsTemp);
    string[] rms = ["--oq", "-od=", "-mixin", "--disable-verify"];
    for(int i = 0; i < importsTemp.length; i++)
    {
        for(int iRm = 0; iRm < rms.length; iRm++)
        {
            if(indexOf(importsTemp[i], rms[iRm]) != -1)
            {
                importsTemp = importsTemp[0..i] ~ importsTemp[i+1..$];
                rms = rms[0..iRm] ~ rms[iRm+1..$];
                i--;
                break;
            }
        }
    }
    
    foreach(i; 0..importsTemp.length)
    {
        long index = importsTemp[i].indexOf("-J");
        if(index != -1)
        {
            if(!isAbsolute(importsTemp[i]["-J".length..$]))
                importsTemp[i] = "-J"~ enginePath ~ importsTemp[i]["-J".length..$];
        }
    }
    return mvFlags ~ importsTemp;
}

version(FirstRun)
int main(string[] args)
{
    if(args.length < 3)
    {
        writeln("Received ", args[1..$], " expected: ");
        writeln("Usage: rdmd apigen.d <hipremeEnginePath> <root>");
        return 1;
    }
    string filesToProcess = args[2..$].join("\n");
    std.file.write("args.txt", filesToProcess);

    string[] versions = ["", "SecondRun"];

    string rdmdArgs = versions.join(" "~TheVersion)~ " "~
        StrImport~". "~
        getImportPaths(args[1]).join(" ")~" apigen.d";

    writeln(rdmdArgs);

    string ext = "";
    version(Windows) ext = ".exe";
    
    return wait(spawnShell("dmd "~rdmdArgs~" && apigen"~ext));
}


string getModuleInfoVarName(string moduleName)
{
    import std.conv;
    char[256] ret = "_D";
    size_t length = 2;
    foreach(txt; moduleName.split("."))
    {
        string packageLength = to!string(txt.length);
        size_t newSize = length + txt.length+ packageLength.length;
        ret[length..length+packageLength.length] = packageLength;
        ret[length+packageLength.length..newSize] = txt;
        length = newSize;
    }
    enum moduleInfoStr = "12__ModuleInfoZ";
    ret[length..length+moduleInfoStr.length] = moduleInfoStr;
    return ret[0..length+moduleInfoStr.length].idup;
}



version(SecondRun)
{
    //Hack since D expects a module info to be linked on the imported files...
    enum string[] ApiGenArgs = import("args.txt").split("\n");
    static foreach(a; ApiGenArgs)
    {
        extern(C) mixin("void* ", getModuleInfoVarName(a), ";");
    }
    
    import hip.util.reflection:ModuleImplementor;
    int main(string[] args)
    {
        enum string[] filesToProcess = ApiGenArgs;

        string initializeFunction;
        static foreach(mod; filesToProcess)
        {{
            mixin("import ", mod,";");
            string moduleName = mod.replace(".", "_");
            string moduleDef;
            string functionDefinitions;
            initializeFunction = "void Init_"~moduleName~"()\n{";

            static foreach(member; __traits(allMembers, mixin(mod)))
            {{
                alias mem = __traits(getMember, mixin(mod), member);
                string exportedModule;

                static if(hasUDA!(mem, ModuleImplementor) && isFunction!mem)
                {{
                    enum ModuleImplementor mi = __traits(getAttributes, mem)[0];
                    if(moduleDef is null) moduleDef = "module "~mi.apiOutput~";\n";
                    if(exportedModule is null) exportedModule = mi.apiOutput.replace(".", "_");

                    initializeFunction~= "\n\t"~member~" = cast(typeof("~member~"))_loadSymbol(_dll, \""~exportedModule~"_"~member~"\");";

                    functionDefinitions~= "\n"~(ReturnType!mem).stringof~ " function "~ (Parameters!mem).stringof~member~";";

                }}
            }}

            std.file.write("fp.d", moduleDef~initializeFunction~"\n}\nextern(System) __gshared: \n"~functionDefinitions);

        }}

        return 0;
    }
}