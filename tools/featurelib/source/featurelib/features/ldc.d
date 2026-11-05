module featurelib.features.ldc;

import featurelib;
import featurelib.features._7zip : _7zFeature;
import std.file;
import std.path : buildNormalizedPath;

enum LdcVersion = "1.41.0";

/// LDC looks for ldc2.conf next to the executable first, then ~/.ldc.
/// Copying the release config there keeps the build reproducible.
private void overrideLdcConf(ref Terminal t, string outputPath)
{
    string ldc2Conf = buildNormalizedPath(outputPath, "etc", "ldc2.conf");
    t.writelnHighlighted("Overriding ldc2.conf to use one next to ldc executable.");
    std.file.copy(ldc2Conf, buildNormalizedPath(outputPath, "bin", "ldc2.conf"));
}

bool installLdc(ref Terminal t, ConsoleInput input, TargetVersion ver, Download[] downloads, string[] extractionPaths)
{
    string ldcPath = buildNormalizedPath(extractionPaths[0], downloads[0].url.getDownloadFileName(ver).removeExtension);
    auto binPath = buildNormalizedPath(ldcPath, "bin");
    foreach (executable; ["ldc2", "dub"])
        makeFileExecutable(buildNormalizedPath(binPath, executable));
    overrideLdcConf(t, ldcPath);

    configs["ldcVersion"] = ver.toString;
    configs["ldcPath"] = ldcPath;
    updateConfigFile();
    return true;
}

Feature LDCFeature;

void initialize()
{
    LDCFeature = Feature(
        "LDC 2",
        "LLVM Backend D Compiler. Used for development on various platforms",
        ExistenceChecker(["ldcPath"]),
        Installation([
            Download(
                DownloadURL(
                    windows: "https://github.com/ldc-developers/ldc/releases/download/v$VERSION/ldc2-$VERSION-windows-x64.7z",
                    linux: "https://github.com/ldc-developers/ldc/releases/download/v$VERSION/ldc2-$VERSION-linux-x86_64.tar.xz",
                    osx: "https://github.com/ldc-developers/ldc/releases/download/v$VERSION/ldc2-$VERSION-osx-universal.tar.xz"
                ),
                outputPath: "$TEMP$NAME",
            )
        ], toDelegate(&installLdc), ["$CONFIG_DIR/D/"]),
        (ref Terminal t, string ldcPath)
        {
            addToPath(ldcPath.buildNormalizedPath("bin"));
        },
        VersionRange.parse(LdcVersion),
    );
    LDCFeature.shareable = true;
}

void start()
{
    LDCFeature.dependencies = [&_7zFeature];
}
