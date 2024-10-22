module common_windows;

version(Windows)
{
    pragma(lib, "ole32.lib");
    pragma(lib, "oleaut32.lib");
	import core.sys.windows.objbase;
	import core.sys.windows.winbase;
	import core.sys.windows.windef;
	import core.sys.windows.com;
	import core.sys.windows.basetyps;

	import core.stdc.wchar_:wcscmp;
	import core.sys.windows.oleauto:SysStringLen;
	import core.sys.windows.wtypes:BSTR;
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

    bool detectVSInstallDirViaCOM(out wchar[] versionStr, out wchar[] installStr)
	{
		import commons;
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
			import std.conv:to;
			if(instance.GetInstallationVersion(&thisVersionString) != S_OK ||
			instance.GetInstallationPath(&thisInstallDir) != S_OK)
				continue;
            versionStr = thisVersionString[0..SysStringLen(thisVersionString)];
			installStr = thisInstallDir[0..SysStringLen(thisInstallDir)];

			if(!("vsInstallDir" in configs))
			{
				configs["vsInstallDir"] = installStr.to!string;
				updateConfigFile();
			}
			return true;
		}
		return false;
	}
	bool detectVSInstallDirViaCOM()
	{
		wchar[] vers, install;
		return detectVSInstallDirViaCOM(vers, install);
	}
}