module features.devkitpro;
import feature;
import commons;

Feature DevKitProFeature;

private bool hasDevkitPro(ref Terminal t, TargetVersion ver, out ExistenceStatus status)
{
    import std.file;
    import std.path;
    version(Posix)
    {
        if("DEVKITPRO" in environment)
        {
            string where = buildNormalizedPath(environment["DEVKITPRO"], "libnx", "lib", "libnx.a");
            if(exists(where))
            {
                status = ExistenceStatus(ExistenceStatus.Place.custom, environment["DEVKITPRO"]);
                return true;
            }
        }
        if(exists("/opt/devkitpro/libnx/lib/libnx.a"))
        {
            status = ExistenceStatus(ExistenceStatus.Place.custom, "/opt/devkitpro");
        t.writeln = status;

            return true;
        }
    }
    else
    {
        if("DEVKITPRO" in environment && exists(buildNormalizedPath(environment["DEVKITPRO"], "libnx", "libnx.a")))
            return true;
        return exists(`C:\devkitpro\libnx\libnx.a`);
    }
    return false;
}

private bool installDevkitPro(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] content, string[] extractionPaths)
{
    version(OSX)
    {
        string pkgPath = buildPath(extractionPaths[0], "devkitpro-pacman-installer.pkg");
        t.writelnHighlighted("Executing sudo installer -pkg ", pkgPath, " -target / for installing dkp-pacman");
        t.flush;
        if(t.wait(spawnProcess(["sudo", "installer", "-pkg", pkgPath, "-target", "/"])) != 0)
        {
            t.writelnError("Failed installing devkitPro");
            return false;
        }
        t.writelnHighlighted("Executing sudo dkp-pacman -S switch-dev");
        t.flush;
        if(t.wait(spawnProcess(["sudo", "dkp-pacman", "-S", "switch-dev"])) != 0)
        {
            t.writelnError("Failed installing development for Nintendo Switch on DevkitPro");
            return false;
        }

    }
    else
    {
        makeFileExecutable(extractionPaths[0]);
    }
	return true;
}

void initialize()
{
    import std.conv:to;
    DevKitProFeature = Feature(
        "DevKitPRO LibNX",
        "Required for being able to develop applications for Nintendo Switch",
        ExistenceChecker(["pacmanPath"], null, toDelegate(&hasDevkitPro)),
        Installation([Download(
            DownloadURL(
                windows: "https://apt.devkitpro.org/install-devkitpro-pacman",
                linux: "https://apt.devkitpro.org/install-devkitpro-pacman",
                osx: "https://github.com/devkitPro/pacman/releases/download/v6.0.2/devkitpro-pacman-installer.pkg",
            )
        )], toDelegate(&installDevkitPro), extractionPathList: ["$CONFIG_DIR/buildtools/dkp-pacman"]),
        (ref Terminal t, string where){
            environment["DEVKITPRO"] = where;
            t.writeln = where;
        }
    );
}
void start(){}