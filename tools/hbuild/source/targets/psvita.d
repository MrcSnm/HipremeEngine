module targets.psvita;
import std.exception;
import features.git;
import commons;
import std.path;

private enum updateCmd = "sudo apt-get update";
private enum depsInstallCmd = "sudo apt-get install make git-core cmake python3 curl wget bzip2";
private enum vdpmRepo = "https://github.com/vitasdk/vdpm";
private enum bootstrapVsdk = "./bootstrap-vitasdk.sh";
private enum installAllVsdk = "./install-all.sh";
private enum vitasdkExports = "\n"~"export PATH=$VITASDK/bin:$PATH #adds vitasdk tool to $PATH";


private bool setupPsvitaLinux(ref Terminal t, ref RealTimeConsoleInput input)
{
    t.wait(spawnShell(updateCmd));
    t.wait(spawnShell(depsInstallCmd));
    string rc = getBashRcPath();
    return setupVdpm(t, input, (scope string[] cmds...)
    {
        string toExec = "source "~rc~" && "~cmds.join(" ");
        t.writelnHighlighted("Executing: " ~ toExec); 
        return t.wait(spawnShell(toExec));
    });
}

private bool setupPsvitaOSX(ref Terminal t, ref RealTimeConsoleInput input)
{
    import std.file;
    string pkgManager;
    foreach(string program; ["brew", "port"])
    {
        if(execute(["which", program]).status == 0)
        {
            pkgManager = program;
            break;
        }
    }
    if(pkgManager is null)
    {
        t.writelnError("Please install either brew or port for PS Vita setup.");
        return false;
    }
    t.wait(spawnShell(pkgManager~" install wget cmake sevenzip gnu-sed"));

    string rc = getBashRcPath();

    mkdirRecurse("/tmp/gnu-bin");
    executeShell("ln -sf $(which gsed) /tmp/gnu-bin/sed");

    return setupVdpm(t, input, (scope string[] cmds...)
    {
        string toExec = "source "~rc~" && PATH=/tmp/gnu-bin/:$PATH && "~cmds.join(" ");
        t.writelnHighlighted("Executing: " ~ toExec); 
        return t.wait(spawnShell(toExec));
    });
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
            string toExec = "source " ~ getBashRcPath ~ " && " ~ arg;
            t.writelnHighlighted("Executing: ", toExec);
            return wait(spawnShell(toExec));
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


private bool setupVdpm(ref Terminal t, ref RealTimeConsoleInput input, int delegate(scope string[] cmd...) execFn)
{
    import std.file;

    string vitaPath = buildNormalizedPath(getVitaSdkPath, "..");

    if(!exists(vitaPath))
        mkdirRecurse(vitaPath);
    with(WorkingDir(vitaPath))
    {
        if(!std.file.exists("vdpm"))
        {
            if(execFn("git clone", vdpmRepo) != 0)
            {
                t.writelnError("Could not clone vdpm");
                return false;
            }
        }
    }
    with(WorkingDir(buildPath(vitaPath, "vdpm")))
    {
        if(execFn(bootstrapVsdk) != 0)
        {
            t.writelnError("Could not execute "~bootstrapVsdk);
            version(OSX)
            {
                t.writelnHighlighted("Your Python installation might not have valid SSL certificate bundle." ~
                "\nYou might need to execute a command like `/Applications/Python 3.13/Install Certificates.command`");
            }
            execFn("sudo rm -rf "~getVitaSdkPath());
            return false;
        }
        if(execFn(installAllVsdk) != 0)
        {
            t.writelnError("Could not execute "~installAllVsdk);
            return false;
        }
    }
    if(execFn("vitasdk-update") != 0)
    {
        t.writelnError("Could not update vitasdk");
        return false;
    }
    return true;
}

private string getVitaSdkPath()
{
    return getHipPath("tools", "hbuild", "PSVita", "vitasdk");
}


private string getBashRcPath()
{
    version(Windows)
        return buildPath(environment["USERPROFILE"], ".bashrc");
    else version(linux)
        return buildPath(environment["HOME"], ".bashrc");
    else version(OSX)
        return buildPath(environment["HOME"], ".zshrc");
    else assert(false, "No known bashrc found.");
}

private void updateShell()
{
    string exports = "\n"~"export VITASDK=\""~getVitaSdkPath()~"\""~vitasdkExports;
    string shellRcPath = getBashRcPath();
    if(std.file.exists(shellRcPath))
    {
        import std.algorithm.searching:countUntil;
        string data = std.file.readText(shellRcPath);
        if(countUntil(data, "VITASDK") != -1)
            return;
    }
    std.file.append(shellRcPath, exports);
}


private bool setupPsvitaWindows(ref Terminal t, ref RealTimeConsoleInput input)
{
    if(findProgramPath("wsl") == null)
    {
        t.writelnError("Please, run a command prompt with administrator access and run `wsl --install` before developing for PSV on Windows.");
        return false;
    }
    string fileToSource = getWslSource();
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

    return setupVdpm(t, input, wslExec);
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

    bool ret;

    updateShell();
    version(Windows) ret = setupPsvitaWindows(t, input);
    else version(linux) ret = setupPsvitaLinux(t, input);
    else version(OSX) ret = setupPsvitaOSX(t, input);
    else assert(false, "Not supported");

    if(ret)
    {
        configs["vitaSdkPath"] = getVitaSdkPath();
        configs["firstPsvConfig"] = true;
        updateConfigFile();
    }
    return ret;

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

    string dflags = 
		"-I="~getHipPath("modules", "d_std", "source") ~" "~
		"-I="~getHipPath("dependencies", "runtime", "druntime", "source") ~" " ~
        "-d-version=PSVita " ~
        "-d-version=PSV " ~
        "--revert=dtorfields "~
        "-mcpu=cortex-a9 "~
        "-mattr=+neon,+neonfp,+thumb-mode "~
        // "-Os " ~
        "-fvisibility=hidden "~
        "-float-abi=hard "~
        "-gcc="~buildNormalizedPath(configs["vitaSdkPath"].str, "bin", "arm-vita-eabi-gcc")~" "~
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
        if(waitRedub(t, input, DubArguments().command("build").configuration("psvita").arch("armv7a-unknown-unknown-eabi").opts(cOpts), d,
            getHipPath("build", "vita", "hipreme_engine", "libs"), LibIncludesType.txt) != 0)
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