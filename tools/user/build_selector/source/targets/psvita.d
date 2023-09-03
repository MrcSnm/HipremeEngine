module targets.psvita;
import std.exception;
import commons;

private enum updateCmd = "sudo apt-get update";
private enum depsInstallCmd = "sudo apt-get install make git-core cmake python curl wget";
private enum vdpmRepo = "https://github.com/vitasdk/vdpm";
private enum bootstrapVsdk = "./bootstrap-vitasdk.sh";
private enum installAllVsdk = "./install-all.sh";
private enum vitasdkExports =
    "\n"~"export VITASDK=/usr/local/vitasdk" ~
    "\n"~"export PATH=$VITASDK/bin:$PATH #adds vitasdk tool to $PATH";

private enum vdpmInstallCmd =
    "git clone https://github.com/vitasdk/vdpm && "~
    "cd vdpm && "~
    "./bootstrap-vitasdk-.sh "~
    "./install-all.sh";


private bool setupPsvitaLinux(ref Terminal t, ref RealTimeConsoleInput input)
{
    std.file.mkdirRecurse("/usr/local/vitasdk");
    std.file.append(buildPath(environment["HOME"], ".bashrc"), vitasdkExports);
    wait(spawnShell(updateCmd));
    wait(spawnShell(depsInstallCmd));
    wait(spawnShell(vdpmInstallCmd));
    wait(spawnShell("vitasdk-update"));
    return true;
}
private string getWslSource()
{
    return executeShell("wsl echo -n $(wslpath \"%USERPROFILE%\")/.bashrc").output;
}

private auto getExecFunc()
{
    return (scope string arg)
    {
        version(Windows){return wait(spawnShell("wsl source "~getWslSource~" ^&^& "~arg));}
        else return wait(spawnShell(arg));
    };
}

/** 
 * The first build will simply generate the VPK, by mapping assets, compiling
 * all the required stuff for PSVita, and also including the main binary (eboot.bin)
 * after the first build is done, one must manually install the vita_sample.vpk 
 * by using the vitashell utility.
 * Params:
 *   t = 
 * Returns: 
 */
private bool firstBuild(ref Terminal t)
{
    string cwd = std.file.getcwd();
    std.file.chdir(getHipPath("build", "vita", "hipreme_engine"));
    scope(exit) std.file.chdir(cwd);
    auto exec = getExecFunc();
    if(exec("make") != 0)
    {
        t.writelnError("Make failed.");
        return false;
    }
    if(exec("curl ftp://"~configs["psvIp"].str~":1337/ux0:/ -T ./vita_sample.vpk") != 0)
    {
        t.writelnError("Could not send the VPK.");
        return false;
    }
    return true;
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
    auto exec = getExecFunc();

    string cwd = std.file.getcwd();
    std.file.chdir(getHipPath("build", "vita", "hipreme_engine"));

    version(Windows) enum pipe = "^|";
    else enum pipe = "|";

    scope(exit) std.file.chdir(cwd);
    exec("make clean");
    if(exec("make eboot.bin") != 0)
    {
        t.writelnError("Could not rebuild.");
        return false;
    }
    exec("echo screen on "~pipe~" nc "~configs["psvIp"].str~" "~configs["psvCmdPort"].str);
    if(exec("curl ftp://"~configs["psvIp"].str~":1337/ux0:/app/"~APP_ID~"/ -T ./eboot.bin") != 0)
    {
        t.writelnError("Could not send eboot.bin");
        return false;
    }
    exec("echo launch "~APP_ID~" "~pipe~" nc "~configs["psvIp"].str~" "~configs["psvCmdPort"].str);
    return true;
}

private bool setupPsvitaWindows(ref Terminal t, ref RealTimeConsoleInput input)
{
    if(executeShell("where wsl").status != 0)
    {
        t.writelnError("Please, run a command prompt with administrator access and run `wsl --install` before developing for PSV on Windows.");
        return false;
    }
    string cwd = std.file.getcwd();
    std.file.mkdirRecurse(buildPath(cwd, "PSVita", "vitasdk"));

    string bashRc = buildPath(environment["USERPROFILE"], ".bashrc");
    string fileToSource = getWslSource();
    if(std.file.exists(bashRc))
    {
        if(executeShell("wsl source"~fileToSource~" ^&^& export -p ^| grep VITASDK").status != 0)
            std.file.append(bashRc, vitasdkExports);
    }
    else std.file.append(bashRc, vitasdkExports);

    auto wslExec = (scope string[] commands...)
    {
        import std.array:join;
        t.writelnHighlighted("WSL Execution: "~commands);
        return wait(spawnShell("wsl source "~fileToSource~" ^&^& "~join(commands, " ")));
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
    std.file.chdir(buildPath(cwd, "PSVita"));
    if(!std.file.exists("vdpm"))
    {
        if(wslExec("git clone "~vdpmRepo) != 0)
        {
            t.writelnError("Could not clone vdpm");
            return false;
        }
    }
    std.file.chdir(buildPath(cwd, "PSVita", "vdpm"));
    if(wslExec("which vitasdk-update") != 0 && wslExec(bootstrapVsdk) != 0)
    {
        t.writelnError("Could not execute "~bootstrapVsdk);
        wslExec("sudo rm -rf /usr/local/vitasdk");
        return false;
    }
    if(wslExec(installAllVsdk) != 0)
    {
        t.writelnError("Could not execute "~installAllVsdk);
        return false;
    }
    std.file.chdir(cwd);
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
     if(!extract7ZipToFolder(
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
	cached(() => timed(() => loadSubmodules(t, input)));    
	cached(() => timed(() => outputTemplateForTarget(t)));    
	runEngineDScript(t, "releasegame.d", configs["gamePath"].str);
    putResourcesIn(t, buildNormalizedPath(configs["hipremeEnginePath"].str, "build", "vita", "hipreme_engine", "assets"));

    string dflags = "-I="~configs["hipremeEnginePath"].str~"/modules/d_std/source "~
    "-I="~configs["hipremeEnginePath"].str~"/dependencies/runtime/druntime/arsd-webassembly "~
    "-d-version=PSVita " ~
    "-d-version=PSV " ~
    "-preview=shortenedMethods "~
    "-mtriple=armv7a-unknown-unknown " ~
    "--revert=dtorfields "~
    "-mcpu=cortex-a9 "~
    "-O0 " ~
    "-g "~
    "-float-abi=hard "~
    "--relocation-model=static "~
    "-d-version=CarelessAlocation ";

    environment["DFLAGS"] = dflags;

    
    requireConfiguration("psvIp", "Set up PSVita IP for installing your application via FTP.", t, input);
    requireConfiguration("psvCmdPort", "Set up PSVita Command Port for automatic execution after compilation+installation.", t, input);


    std.file.chdir(configs["hipremeEnginePath"].str);

    if(waitDubTarget(t, "psvita", "build --parallel --deep --compiler=ldc2 --arch=armv7a-unknown-unknown ") != 0)
    {
        t.writelnError("Could not build for PSVita.");
        return ChoiceResult.Error;
    }
    environment["DFLAGS"] = "";    
    runEngineDScript(t, "copylinkerfiles.d", 
        "\"--compiler=ldc2 --arch=armv7a-unknown-unknown " ~
        "--recipe="~buildPath(getBuildTarget("psvita"), "dub.json")~'"', 
        getHipPath("build", "vita", "hipreme_engine", "libs"), 
    dflags);

    static bool isFirstBuild = true;
    if(isFirstBuild)
    {
        if(!firstBuild(t))
        {
            t.writelnError("Could not build PSVita vita_sample.vpk");
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
    
    return ChoiceResult.None;
}