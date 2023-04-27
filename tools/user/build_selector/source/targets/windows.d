module targets.windows;
version(Windows):
import commons;
import std.windows.registry;

bool hasVCRuntime140()
{
	Key hklm = Registry.localMachine;
	if(hklm is null) throw new Error("No HKEY_LOCAL_MACHINE in this system.");
	Key currKey = hklm;

	string arch = "X64";
	version(Win32) arch = "X32";
	string[] paths = ["SOFTWARE", "WOW6432Node", "Microsoft", "VisualStudio", "14.0", "VC", "Runtimes", arch];
	foreach(p; paths)
	{
		currKey = currKey.getKey(p);
		if(currKey is null) return false;
	}
	return currKey.getValue("Installed").value_DWORD == 1;
}

private string getVCDownloadLink()
{
	version(Win64) return "https://aka.ms/vs/17/release/vc_redist.x64.exe";
	else version(Win32) return "https://aka.ms/vs/17/release/vc_redist.x86.exe";
	else version(AArch64) return "https://aka.ms/vs/17/release/vc_redist.arm64.exe";
}

private bool installVCRuntime140(ref Terminal t, ref RealTimeConsoleInput input)
{
	string vcredist = buildNormalizedPath(std.file.getcwd(), "buildtools", "vcredist.exe");
	if(!downloadFileIfNotExists("Get Microsoft Visual C++ Redistributable", getVCDownloadLink, vcredist, t, input))
	{
		t.writelnError("Needs to download VCRuntime.");
		return false;
	}
	return wait(spawnShell(vcredist~" /install /quiet /norestart")) == 0;
}



void prepareWindows(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(!hasVCRuntime140)
	{
		if(!installVCRuntime140(t, input))
		{
			t.writelnError("Your system must install Microsoft Visual C++ 14 for using the D Programming Language.");
			return;
		}
	}
    std.file.chdir(configs["gamePath"].str);
	waitDub(t, "build -c script "~cOpts.getDubOptions, "");
	std.file.chdir(configs["hipremeEnginePath"].str);
	waitDub(t, "-c script "~cOpts.getDubOptions ~ " -- "~configs["gamePath"].str, "", true);
}