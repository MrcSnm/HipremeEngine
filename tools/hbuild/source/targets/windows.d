module targets.windows;

import features.hipreme_engine;
import features.ldc;

version(Windows):
import commons;
import feature;
import features.msvclinker;
import features.vcruntime140;
import std.windows.registry;
static import std.file;


bool hasVCRuntime140()
{
	string arch = "X64";
	version(Win32) arch = "X32";
	Key currKey = windowsGetKeyWithPath("SOFTWARE", "WOW6432Node", "Microsoft", "VisualStudio", "14.0", "VC", "Runtimes", arch);
	return currKey.getValue("Installed").value_DWORD == 1;
}

bool hasMSVCLinker()
{
	import common_windows;
	immutable supportedPre2017Versions = ["14.0"];
	
	if(detectVSInstallDirViaCOM())
		return true;

	if(Key k = windowsGetKeyWithPath("SOFTWARE", "Microsoft", "VisualStudio", "SxS", "VS7"))
	if(k.getValue("15.0").value_SZ)
		return true;
	
	foreach (ver; supportedPre2017Versions)
	{
		Key k = windowsGetKeyWithPath("SOFTWARE", "Microsoft", "VisualStudio", ver);
		try
		{
			if(k !is null && k.getValue("InstallDir"))
				return true;
		}
		catch(Exception e){return false;}
	}
	return false;
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
	if(!downloadFileIfNotExists("Get Microsoft Visual C++ Redistributable for being able to compile D Programming Language", getVCDownloadLink, vcredist, t, input))
	{
		t.writelnError("Needs to download VCRuntime.");
		return false;
	}
	t.writelnHighlighted("Installing Microsoft Visual C++ Redistributable");

	auto ret = t.wait(spawnShell(vcredist~" /install /quiet /norestart")) == 0;
	if(ret)
		t.writelnSuccess("Successfully installed Microsoft Visual C++ Redistributable.");
	else 
		t.writelnError("Could not install Microsoft Visual C++ Redistributable.");
	return ret;
}

private bool installMSLinker(ref Terminal t, ref RealTimeConsoleInput input)
{
	import features.vs_buildtools_installer;

	return installFromVSBuildTools.execute(t, input, "Get Windows SDK for being able  to compile D programming language",
	[
		"Microsoft.VisualStudio.Workload.VCTools",
		"Microsoft.VisualStudio.Component.TestTools.BuildTools",
		"Microsoft.VisualStudio.Component.VC.ASAN",
		"Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
	]);
}

ChoiceResult prepareWindows(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(!hasVCRuntime140)
	{
		if(!installVCRuntime140(t, input))
		{
			t.writelnError("Your system must install Microsoft Visual C++ 14 for using the D Programming Language.");
			return ChoiceResult.Error;
		}
	}
	if(!hasMSVCLinker)
	{
		if(!installMSLinker(t, input))
		{
			if(hasMSVCLinker)
				t.writelnSuccess("Succesfully installed Windows SDK.");
			else
			{
				t.writelnError("Could not install Windows SDK.");
				return ChoiceResult.Error;
			}
		}
		else
		{
			t.writelnError("Your system must install the MSLinker. This is important for creating binaries without dependencies.");
			return ChoiceResult.Error;
		}
	}

	// waitOperations([{
		std.file.chdir(configs["gamePath"].str);
		if(timed(t, waitDub(t, DubArguments().command("build").configuration("script").opts(cOpts)) != 0))
			return ChoiceResult.Error;
			// return false;
		// return true;
	// },
	// {
		if(!c.scriptOnly)
		{
			std.file.chdir(getHipPath);
			if(timed(t, waitDub(t, DubArguments().command("build").configuration("script").opts(cOpts))) != 0)
				return ChoiceResult.Error;
		}
		// return true;
	// }]);
	
	t.wait(spawnShell((getHipPath("bin", "desktop", "hipreme_engine.exe") ~ " "~ configs["gamePath"].str)));

	return ChoiceResult.Continue;
}