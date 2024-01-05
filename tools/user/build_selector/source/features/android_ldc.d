module features.android_ldc;
public import feature;
import commons;

Feature AndroidLDCLibraries;

private bool androidLibrariesExists(ref Terminal t, int targetVer)
{
    return std.file.exists(buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs", "android", "lib", "libdruntime-ldc.a"));
}
void initialize()
{
    AndroidLDCLibraries = Feature(
        "Android LDC Libraries",
        "LDC Phobos and DRuntime libraries compiled for running in the Android platform",
        ExistenceChecker(null, null, &androidLibrariesExists),
        Installation([Download(
            DownloadURL.any("https://github.com/MrcSnm/HipremeEngine/releases/download/BuildAssets.v1.0.0/android.zip")
        )], null, ["$CWD/Android/ldcLibs/android/lib/libdruntime-ldc.a"])
    );
}
void start(){}