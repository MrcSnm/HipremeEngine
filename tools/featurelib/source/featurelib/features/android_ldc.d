module featurelib.features.android_ldc;

import featurelib;
import featurelib.features._7zip : _7zFeature;
import featurelib.features.ldc : LdcVersion;
import std.file;
import std.path : buildNormalizedPath;

Feature AndroidLDCLibraries;

Task!(getAndroidLDCLibrariesPathImpl) getAndroidLDCLibrariesPath;

private string getAndroidLDCLibrariesPathImpl(Feature*[] dependencies, ref Terminal t, ConsoleInput input)
{
    string installPath = dependencies[0].installer.getExtractionPath(0, dependencies[0].currentVersion);
    string ver = dependencies[0].currentVersion.toString();
    return buildNormalizedPath(installPath, "ldc2-" ~ ver ~ "-android-aarch64", "lib");
}

private bool androidLibrariesExists(ref Terminal t, TargetVersion ver, out ExistenceStatus status)
{
    string path = buildNormalizedPath(getConfigFolder(), "Android", "ldcLibs", "ldc2-" ~ ver.toString ~ "-android-aarch64", "lib", "libdruntime-ldc.a");
    if (exists(path))
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
        )], null, ["$CONFIG_DIR/Android/ldcLibs"]),
        null, VersionRange.parse(LdcVersion)
    );
    AndroidLDCLibraries.shareable = true;
}

void start()
{
    AndroidLDCLibraries.dependencies = [&_7zFeature];
    getAndroidLDCLibrariesPath = Task!(getAndroidLDCLibrariesPathImpl)([&AndroidLDCLibraries]);
}
