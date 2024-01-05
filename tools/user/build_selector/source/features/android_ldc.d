module features.android_ldc;
public import feature;
import commons;

Feature AndroidLDCLibraries;

private bool androidLibrariesExists(ref Terminal t, TargetVersion ver, out ExistenceStatus status)
{
    string path = buildNormalizedPath(std.file.getcwd(), "Android", "ldcLibs", "android", "lib", "libdruntime-ldc.a");
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
        ExistenceChecker(null, null, &androidLibrariesExists),
        Installation([Download(
            DownloadURL.any("https://github.com/MrcSnm/HipremeEngine/releases/download/BuildAssets.v1.0.0/android.zip")
        )], null, ["$CWD/Android/ldcLibs"])
    );
}
void start(){}