module features.opend;
import commons;
import feature;

enum OpenDVersion = "latest";

Feature OpenDFeature;

bool installOpenD(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] downloads)
{

    return true;
}

void initialize()
{
    OpenDFeature =(
        "OpenD LDC and DMD",
        "Open D language compiler. Reference implementation at https://opendlang.org/index.html",
        ExistenceChecker(["opendPath"]),
        Installation([
            Download(
                DownloadURL(
                    windows: "https://github.com/opendlang/opend/releases/download/CI/opend-latest-windows-x64.7z",
                    linux: "https://github.com/opendlang/opend/releases/download/CI/opend-latest-linux-x86_64.tar.xz",
                    osx: "https://github.com/opendlang/opend/releases/download/CI/opend-latest-osx-x86_64.tar.xz"
                )
            ),
            outputPath: "$TEMP$NAME"
        ], toDelegate(&installOpenD), ["$CWD/OpenD/"]),
        (ref Terminal t, string ldcPath)
        {
            addToPath(ldcPath.buildNormalizedPath("bin"));
        }
    )
}


void start()
{
    import features._7zip;
    OpenDFeature.dependencies = [&_7zFeature];
}