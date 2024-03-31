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

pragma(lib, "ole32.lib");
pragma(lib, "oleaut32.lib");
bool hasMSVCLinker()
{
	import core.sys.windows.winbase;
	import core.sys.windows.winnt;
	import core.sys.windows.com;
	import core.sys.windows.wtypes;
	immutable supportedPre2017Versions = ["14.0"];
	const GUID iid_SetupConfiguration = { 0x177F0C4A, 0x1CD3, 0x4DE7, [ 0xA3, 0x2C, 0x71, 0xDB, 0xBB, 0x9F, 0xA3, 0x6D ] };

	static interface ISetupInstance : IUnknown
	{
		// static const GUID iid = uuid("B41463C3-8866-43B5-BC33-2B0676F7F42E");
		static const GUID iid = { 0xB41463C3, 0x8866, 0x43B5, [ 0xBC, 0x33, 0x2B, 0x06, 0x76, 0xF7, 0xF4, 0x2E ] };

		int GetInstanceId(BSTR* pbstrInstanceId);
		int GetInstallDate(LPFILETIME pInstallDate);
		int GetInstallationName(BSTR* pbstrInstallationName);
		int GetInstallationPath(BSTR* pbstrInstallationPath);
		int GetInstallationVersion(BSTR* pbstrInstallationVersion);
		int GetDisplayName(LCID lcid, BSTR* pbstrDisplayName);
		int GetDescription(LCID lcid, BSTR* pbstrDescription);
		int ResolvePath(LPCOLESTR pwszRelativePath, BSTR* pbstrAbsolutePath);
	}

	static interface IEnumSetupInstances : IUnknown
	{
		// static const GUID iid = uuid("6380BCFF-41D3-4B2E-8B2E-BF8A6810C848");

		int Next(ULONG celt, ISetupInstance* rgelt, ULONG* pceltFetched);
		int Skip(ULONG celt);
		int Reset();
		int Clone(IEnumSetupInstances* ppenum);
	}

	static interface ISetupConfiguration : IUnknown
	{
		// static const GUID iid = uuid("42843719-DB4C-46C2-8E7C-64F1816EFD5B");
		static const GUID iid = { 0x42843719, 0xDB4C, 0x46C2, [ 0x8E, 0x7C, 0x64, 0xF1, 0x81, 0x6E, 0xFD, 0x5B ] };

		int EnumInstances(IEnumSetupInstances* ppEnumInstances) ;
		int GetInstanceForCurrentProcess(ISetupInstance* ppInstance);
		int GetInstanceForPath(LPCWSTR wzPath, ISetupInstance* ppInstance);
	}


	if("VSINSTALLDIR" in environment && !("LDC_VSDIR_FORCE" in environment))
	{
		if(!("VSCMD_ARG_TGT_ARCH" in environment))
			return true;
		string tgtArch = environment["VSCMD_ARG_TGT_ARCH"];
		if(tgtArch == "x64" || tgtArch == "x32")
			return true;
	}
	if("LDC_VSDIR" in environment && std.file.exists(environment["LDC_VSDIR"]))
		return true;

	bool detectVSInstallDirViaCOM()
	{
		import core.sys.windows.windows;
		import core.stdc.wchar_:wcscmp;

		CoInitialize(null); scope(exit) CoUninitialize();

		ISetupConfiguration setup;
    	IEnumSetupInstances instances;
		ISetupInstance instance;
		DWORD fetched;

		HRESULT hr = CoCreateInstance(&iid_SetupConfiguration, null, CLSCTX_ALL, &ISetupConfiguration.iid, cast(void**) &setup);
		if(hr != S_OK || !setup) return false;

		scope(exit) setup.Release();
		if(setup.EnumInstances(&instances) != S_OK)
			return false;
		scope(exit) instances.Release();

		BSTR thisVersionString, thisInstallDir;
		while (instances.Next(1, &instance, &fetched) == S_OK && fetched)
		{
			if(instance.GetInstallationVersion(&thisVersionString) != S_OK || 
			instance.GetInstallationPath(&thisInstallDir) != S_OK)
				continue;
			return true;
		}
		return false;
	}

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

	auto ret = wait(spawnShell(vcredist~" /install /quiet /norestart")) == 0;
	if(ret)
		t.writelnSuccess("Successfully installed Microsoft Visual C++ Redistributable.");
	else 
		t.writelnError("Could not install Microsoft Visual C++ Redistributable.");
	return ret;
}

private bool installMSLinker(ref Terminal t, ref RealTimeConsoleInput input)
{
	string vcBuildTools = buildNormalizedPath(std.file.getcwd(), "buildtools", "vc_BuildTools.exe");
	enum vcBuildToolsLink = "https://aka.ms/vs/17/release/vs_BuildTools.exe";
	if(!downloadFileIfNotExists("Get Windows SDK for being able  to compile D programming language", vcBuildToolsLink, vcBuildTools, t, input))
	{
		t.writelnError("Need to download vs_BuildTools.exe");
		return false;
	}
	t.writelnHighlighted("Starting Windows SDK Installation.");

	string[] installList = 
	[
		"Microsoft.VisualStudio.Workload.VCTools",
		"Microsoft.VisualStudio.Component.TestTools.BuildTools",
		"Microsoft.VisualStudio.Component.VC.ASAN",
		"Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
	];

	import std.algorithm:reduce;

	auto ret = wait(spawnShell(vcBuildTools~" --wait --passive --norestart " ~installList.reduce!((str, last) => "--add "~last~" "~str))) == 0;
	return ret == 0;
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
		if(timed(waitDub(t, DubArguments().command("build").configuration("script").opts(cOpts)) != 0))
			return ChoiceResult.Error;
			// return false;
		// return true;
	// },
	// {
		if(!c.scriptOnly)
		{
			std.file.chdir(getHipPath);
			if(timed(waitDub(t, DubArguments().command("build").configuration("script").opts(cOpts))) != 0)
				return ChoiceResult.Error;
		}
		// return true;
	// }]);
	
	wait(spawnShell((getHipPath("bin", "desktop", "hipreme_engine.exe") ~ " "~ configs["gamePath"].str)));

	return ChoiceResult.Continue;
}