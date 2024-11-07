module features.msvclinker;
public import feature;
import commons;

///Feature which gets the msvclinker
Feature MSVCLinker;

version(Posix)
{
    void initialize(){}
    void start(){}
}
else version(Windows):


pragma(lib, "ole32.lib");
pragma(lib, "oleaut32.lib");
bool hasMSVCLinker(ref Terminal t, TargetVersion v, out ExistenceStatus where)
{
	import core.sys.windows.winbase;
	import core.sys.windows.winnt;
	import core.sys.windows.com;
	import core.sys.windows.wtypes;
	import std.windows.registry;
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

private bool installMSLinker(ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] content)
{
	string[] installList = 
	[
		"Microsoft.VisualStudio.Workload.VCTools",
		"Microsoft.VisualStudio.Component.TestTools.BuildTools",
		"Microsoft.VisualStudio.Component.VC.ASAN",
		"Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
	];

	import std.algorithm:reduce;

	auto ret = t.wait(spawnShell(content[0].getOutputPath(ver)~" --wait --passive --norestart " ~installList.reduce!((str, last) => "--add "~last~" "~str))) == 0;
	return ret == 0;
}


void initialize()
{
    MSVCLinker = Feature(
        "MSVCLinker",
        "Windows SDK for being able to compile using D programming language",
        ExistenceChecker(null, null, toDelegate(&hasMSVCLinker)),
        Installation([
            Download(
                DownloadURL(
                    windows: "https://aka.ms/vs/17/release/vs_BuildTools.exe"
                ),
                outputPath: "$CWD/buildtools/vc_BuildTools.exe"
            )], toDelegate(&installMSLinker)
        ),
    );
}
void start()
{
    
}