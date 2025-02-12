module targets.psvita;
import std.exception;
import features.git;
import commons;

private enum updateCmd = "sudo apt-get update";
private enum depsInstallCmd = "sudo apt-get install make git-core cmake python3 curl wget bzip2";
private enum vdpmRepo = "https://github.com/vitasdk/vdpm";
private enum bootstrapVsdk = "./bootstrap-vitasdk.sh";
private enum installAllVsdk = "./install-all.sh";

version(Posix)
    private string vitaSdkPath="/usr/local/vitasdk";
else
    private string vitaSdkPath;

private enum vitasdkExports =
    "\n"~"export PATH=$VITASDK/bin:$PATH #adds vitasdk tool to $PATH";

private enum vdpmInstallCmd =
    "git clone https://github.com/vitasdk/vdpm && "~
    "cd vdpm && "~
    "./bootstrap-vitasdk-.sh "~
    "./install-all.sh";


private bool setupPsvitaLinux(ref Terminal t, ref RealTimeConsoleInput input)
{
    string exports = "\n"~"export VITASDK="~vitaSdkPath ~ vitasdkExports;
    std.file.append(buildPath(environment["HOME"], ".bashrc"), exports);
    t.wait(spawnShell(updateCmd));
    t.wait(spawnShell(depsInstallCmd));
    t.wait(spawnShell(vdpmInstallCmd));
    t.wait(spawnShell("vitasdk-update"));
    return true;
}
private string getWslSource()
{
    return executeShell("wsl echo -n $(wslpath \"%USERPROFILE%\")/.bashrc").output;
}

private string getWslPath(string inputPath)
{
    import std.path;
    import std.string:replace, toLower;
    import std.conv;
    return "/mnt/"~driveName(inputPath)[0].toLower.to!string~replace(inputPath[2..$], '\\', '/');
}

private auto getExecFunc(ref Terminal t)
{
    return (scope string arg)
    {
        version(Windows)
        {
            string toExec = "wsl source "~getWslSource~" ^&^& "~arg;
            t.writelnHighlighted("Executing: ", toExec);
            return wait(spawnShell(toExec));
        }
        else
        {
            t.writelnHighlighted("Executing: ", arg);
            return wait(spawnShell(arg));
        }
    };
}

/** 
 * The first build will simply generate the VPK, by mapping assets, compiling
 * all the required stuff for PSVita, and also including the main binary (eboot.bin)
 * after the first build is done, one must manually install the hipreme_engine.vpk
 * by using the vitashell utility.
 * Params:
 *   t = 
 * Returns: 
 */
private bool firstBuild(ref Terminal t)
{
    with(WorkingDir(getHipPath("build", "vita", "hipreme_engine")))
    {
        t.flush;
        auto exec = getExecFunc(t);
        if(exec("make") != 0)
        {
            t.writelnError("Make failed.");
            return false;
        }
        if(exec("curl ftp://"~configs["psvIp"].str~":1337/ux0:/ -T ./hipreme_engine.vpk") != 0)
        {
            t.writelnError("Could not send the VPK.");
            return false;
        }
        return true;
    }
}

/** 
 * Instead of building the entire VPK for PS Vita, it only changes the binary, after that,
 * it directly sends this new binary to the Package folder, so, there will be no need
 * to extract a VPK by going into the Install Process again, making it a lot faster
 * to both build and test.
 *
 *  For even faster installation, it is recomended to run a background FTP on PSV
 * Params:
 *   t = 
 * Returns: 
 */
private bool fastBuild(ref Terminal t)
{
    enum APP_ID = "VSDK00007";
    auto exec = getExecFunc(t);

    with(WorkingDir(getHipPath("build", "vita", "hipreme_engine")))
    {
        version(Windows) enum pipe = "^|";
        else enum pipe = "|";

        // exec("make clean");
        if(exec("make eboot.bin") != 0)
        {
            t.writelnError("Could not rebuild.");
            return false;
        }
        // exec("echo screen on "~pipe~" nc "~configs["psvIp"].str~" "~configs["psvCmdPort"].str);
        if(exec("curl ftp://"~configs["psvIp"].str~":1337/ux0:/app/"~APP_ID~"/ -T ./eboot.bin") != 0)
        {
            t.writelnError("Could not send eboot.bin");
            return false;
        }
        // exec("echo launch "~APP_ID~" "~pipe~" nc "~configs["psvIp"].str~" "~configs["psvCmdPort"].str);
        return true;
    }
}

private bool setupPsvitaWindows(ref Terminal t, ref RealTimeConsoleInput input)
{
    if(executeShell("where wsl").status != 0)
    {
        t.writelnError("Please, run a command prompt with administrator access and run `wsl --install` before developing for PSV on Windows.");
        return false;
    }
    string vitaPath = getHipPath("tools", "hbuild", "PSVita");


    string bashRc = buildPath(environment["USERPROFILE"], ".bashrc");
    string fileToSource = getWslSource();

    vitaSdkPath = getWslPath(buildPath(vitaPath, "vitasdk"));

    string exports = "\n"~"export VITASDK="~vitaSdkPath~vitasdkExports;
    if(std.file.exists(bashRc))
    {
        import std.algorithm.searching:countUntil;
        string data = std.file.readText(bashRc);
        if(countUntil(data, "VITASDK") == -1)
            std.file.append(bashRc, exports);
    }
    else std.file.append(bashRc, exports);

    auto wslExec = (scope string[] commands...)
    {
        import std.array:join;
        t.writelnHighlighted("WSL Execution: "~commands);
        return t.wait(spawnShell("wsl source "~fileToSource~" ^&^& "~join(commands, " ")));
    };
    
    if(wslExec(updateCmd) != 0)
    {
        t.writelnError("Could not update system repositores");
        return false;
    }
    if(wslExec(depsInstallCmd) != 0)
    {
        t.writelnError("Could not setup vita dependencies");
        return false;
    }
    with(WorkingDir(vitaPath))
    {
        if(!std.file.exists("vdpm"))
        {
            if(wslExec("git clone "~vdpmRepo) != 0)
            {
                t.writelnError("Could not clone vdpm");
                return false;
            }
        }
    }
    with(WorkingDir(buildPath(vitaPath, "vdpm")))
    {
        if(wslExec("which vitasdk-update") != 0 && wslExec(bootstrapVsdk) != 0)
        {
            t.writelnError("Could not execute "~bootstrapVsdk);
            wslExec("sudo rm -rf "~vitaSdkPath);
            return false;
        }
        if(wslExec(installAllVsdk) != 0)
        {
            t.writelnError("Could not execute "~installAllVsdk);
            return false;
        }
    }
    if(wslExec("vitasdk-update") != 0)
    {
        t.writelnError("Could not update vitasdk");
        return false;
    }
    configs["firstPsvConfig"] = true;
    updateConfigFile();
    return true;
}

bool setupPsvita(ref Terminal t, ref RealTimeConsoleInput input)
{
     if(!extractToFolder(
        getHipPath("build", "vita", "hipreme_engine", "hipreme_engine_vita_dev_files.7z"),
        getHipPath("build", "vita", "hipreme_engine"),
        t, input
    ))
    {
        t.writelnError("PSVita requires 7zip to extract the development files.");
        return false;
    }
    //https://vitasdk.org/
    version(Windows) return setupPsvitaWindows(t, input);
    else version(linux) return setupPsvitaLinux(t, input);
    else assert(false, "Not supported");
}

ChoiceResult preparePSVita(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    if(!("firstPsvConfig" in configs) || !configs["firstPsvConfig"].boolean)
    {
        if(!setupPsvita(t, input))
            return ChoiceResult.Error;
    }
	cached(() => timed(t, submoduleLoader.execute(t, input)));    
    import std.string;
	executeGameRelease(t);
    putResourcesIn(t, getHipPath("build", "vita", "hipreme_engine", "assets"));

    string dflags = "-I="~configs["hipremeEnginePath"].str~"/modules/d_std/source "~
    "-I="~configs["hipremeEnginePath"].str~"/dependencies/runtime/druntime/source "~
    "-d-version=PSVita " ~
    "-d-version=PSV " ~
    "-mtriple=armv7a-unknown-unknown " ~
    "--revert=dtorfields "~
    "-mcpu=cortex-a9 "~
    "-O0 " ~
    "-g "~
    "-float-abi=hard "~
    "--relocation-model=static "~
    "-d-version=CarelessAlocation "~
    "-d-version=ArsdUseCustomRuntime ";

    environment["DFLAGS"] = dflags;

    requireConfiguration("psvIp", "Set up PSVita IP for installing your application via FTP.", t, input, (ref str)
    {
        str = str.strip();
        return isIpAddress(str);
    }, "psvIp must be a valid IP address");


    requireConfiguration("psvCmdPort", "Set up PSVita Command Port for automatic execution after compilation+installation.", t, input, (ref str)
    {
        str = str.strip();
        return isNumeric(str);
    });


    with(WorkingDir(configs["gamePath"].str))
    {
        ProjectDetails d;
        if(waitRedub(t, DubArguments().command("build").configuration("psvita").arch("armv7a-unknown-unknown").opts(cOpts), d,
        getHipPath("build", "vita", "hipreme_engine", "libs")) != 0)
        {
            t.writelnError("Could not build for PSVita.");
            return ChoiceResult.Error;
        }

        static bool isFirstBuild = true;
        if(isFirstBuild)
        {
            if(!firstBuild(t))
            {
                t.writelnError("Could not build PSVita hipreme_engine.vpk");
                return ChoiceResult.Error;
            }
            isFirstBuild = false;
        }
        else
        {
            if(!fastBuild(t))
            {
                t.writelnError("Could not do subsequent builds.");
                return ChoiceResult.Error;
            }
        }
    }

    return ChoiceResult.None;
}