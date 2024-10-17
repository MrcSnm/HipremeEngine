module features.android_ldc;
public import feature;
import features.ldc;
import commons;

Feature AndroidLDCLibraries;

/**
```d
  string function(ref Terminal t, ref RealTimeConsoleInput);
```
*/
Task!(getAndroidLDCLibrariesPathImpl) getAndroidLDCLibrariesPath;

private string getAndroidLDCLibrariesPathImpl(Feature*[] dependencies, ref Terminal t, ref RealTimeConsoleInput input)
{
    string installPath = dependencies[0].installer.getExtractionPath(0, dependencies[0].currentVersion);
    string ver = dependencies[0].currentVersion.toString();
    return buildNormalizedPath(installPath, "ldc2-"~ver~"-android-aarch64", "lib");
}


private bool androidLibrariesExists(ref Terminal t, TargetVersion ver, out ExistenceStatus status)
{
    string path = buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs", "ldc2-"~ver.toString~"-android-aarch64", "lib", "libdruntime-ldc.a");
    if(std.file.exists(path))
    {
        status.where = path;
        status.place = ExistenceStatus.Place.custom;
        return true;
    }
    return false;
}
void initialize()
{
    AndroidLDCLibraries = Feature(
        "Android LDC Libraries",
        "LDC Phobos and DRuntime libraries compiled for running in the Android platform",
        ExistenceChecker(null, null, toDelegate(&androidLibrariesExists)),
        Installation([Download(
            DownloadURL.any("https://github.com/ldc-developers/ldc/releases/download/v$VERSION/ldc2-$VERSION-android-aarch64.tar.xz")
        )], null, ["$CWD/Android/ldcLibs"]),
        null, VersionRange.parse(LdcVersion), TargetVersion.parse(LdcVersion)
    );
}

void start()
{
    getAndroidLDCLibrariesPath = Task!(getAndroidLDCLibrariesPathImpl)([&AndroidLDCLibraries]);
}