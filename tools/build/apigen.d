module tools.build.apigen;
static import std.file;
import std.stdio;
import std.array;
import std.traits;
import std.process;
import std.algorithm.searching;
import std.algorithm.mutation;


version(SecondRun){}
else version = FirstRun;

version(DigitalMars)
{
    enum TheVersion = "-version=";
    enum StrImport = "\"-J=";
} 
else version(LDC)
{
    enum TheVersion = "--d-version=";
    enum StrImport = "-J";
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
    auto exec = executeShell("dub describe --data=import-paths --vquiet");
    if(exec.status)
    {
        writeln("Error executing dub on path ", enginePath, ": ", exec.output);
        return [];
    }
    string[] importsTemp = split(exec.output.replace("\"", "").replace("\r", "").replace("\n", ""), " ");
    string[] rms = ["--oq", "-od="];
    for(int i = 0; i < importsTemp.length; i++)
    {
        for(int iRm = 0; iRm < rms.length; i++)
        {
            auto res = findSplit(importsTemp[i], rms[iRm]);
            bool found = res[1].length != 0;
            if(found)
            {
                remove(importsTemp, i);
                rms = rms[1..$];
                i--;
                break;
            }
        }
    }
    return importsTemp;
}

version(FirstRun)
int FirstRunMain(string[] args)
{
    if(args.length < 3)
    {
        writeln("Usage: rdmd apigen.d <hipremeEnginePath> <root>");
        return 1;
    }
    string filesToProcess = args[2..$].join("\n");
    std.file.write("args.txt", filesToProcess);

    string[] versions = ["", "SecondRun"];
    string cmd = "rdmd "~
        versions.join(" "~TheVersion)~
        " \""~StrImport~".\""~
        " \"-i\" "~
        " \""~getImportPaths(args[1]).join("\" \"")~"\" apigen ";
    writeln(cmd);

    return wait(spawnShell(cmd));
}

version(SecondRun)
int SecondRunMain(string[] args)
{
    import hip.util.reflection;
    writeln("Second Run");
    enum string[] filesToProcess = import("args.txt").split("\n");
    static foreach(mod; filesToProcess)
    {
        mixin("import ", mod,";");
        static foreach(member; __traits(allMembers, mixin(mod)))
        {{
            alias mem = __traits(getMember, mixin(mod), member);
            ModuleImplementor mi;
            static if(mem.hasUDA!ModuleImplementor && isFunction!mem)
            {
                mi = mem.getUDAs!(ModuleImplementor)[0];
                pragma(msg, ReturnType!mem, " ", mi.apiOutput, "_", member, " (", Parameters!mem, ")");

            }
        }}
    }

    return 0;
}

int main(string[] args)
{
    version(FirstRun)
    {
        return FirstRunMain(args);
    }
    else    
    {
        return SecondRunMain(args);
    }
}