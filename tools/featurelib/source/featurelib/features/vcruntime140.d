module featurelib.features.vcruntime140;

import featurelib;

Feature VCRuntime140Feature;

version (Posix)
{
    void initialize() {}
    void start() {}
}
else version (Windows)
{
    import std.file;
    import std.process : spawnShell;
    import std.windows.registry;

    enum VCRuntimeVer = "14.0";

    bool hasVCRuntime140(ref Terminal t, TargetVersion ver, out ExistenceStatus status)
    {
        string arch = "X64";
        version (Win32) arch = "X32";
        Key currKey = windowsGetKeyWithPath("SOFTWARE", "WOW6432Node", "Microsoft", "VisualStudio", ver.toString, "VC", "Runtimes", arch);
        return currKey.getValue("Installed").value_DWORD == 1;
    }

    private string getVCDownloadLink()
    {
        version (Win64) return "https://aka.ms/vs/17/release/vc_redist.x64.exe";
        else version (Win32) return "https://aka.ms/vs/17/release/vc_redist.x86.exe";
        else version (AArch64) return "https://aka.ms/vs/17/release/vc_redist.arm64.exe";
    }

    private bool installVCRuntime140(ref Terminal t, ConsoleInput input, TargetVersion ver, Download[] content, string[] extractionPaths)
    {
        auto ret = t.wait(spawnShell(content[0].getOutputPath(ver) ~ " /install /quiet /norestart")) == 0;
        if (ret)
            t.writelnSuccess("Successfully installed Microsoft Visual C++ Redistributable.");
        else
            t.writelnError("Could not install Microsoft Visual C++ Redistributable.");
        return ret;
    }

    void initialize()
    {
        VCRuntime140Feature = Feature(
            "VCRuntime140",
            "VCRuntime is a binary necessary for running D compiler.",
            ExistenceChecker(null, null, toDelegate(&hasVCRuntime140)),
            Installation(
                [
                    Download(
                        DownloadURL(
                            windows: getVCDownloadLink
                        ),
                        outputPath: "$CONFIG_DIR/buildtools/vcredist.exe"
                    )
                ], toDelegate(&installVCRuntime140)
            ),
            null,
            VersionRange.parse(VCRuntimeVer),
        );
        VCRuntime140Feature.shareable = true;
    }

    void start() {}
}
