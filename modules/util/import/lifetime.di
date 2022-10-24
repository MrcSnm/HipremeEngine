// D import file generated from 'source\hip\util\lifetime.d'
module hip.util.lifetime;
template RefCounted()
{
	private int* countPtr;
	this(this)
	{
		if (countPtr != null)
			*countPtr = *countPtr + 1;
	}
	void startRefCount()
	{
		import core.stdc.stdlib : malloc;
		countPtr = malloc((int).sizeof);
		*countPtr = 1;
	}
	~this()
	{
		if (countPtr != null)
		{
			*countPtr = *countPtr - 1;
			if (*countPtr == 0)
				dispose();
			import core.stdc.stdlib : free;
			free(countPtr);
			countPtr = null;
		}
	}
}
enum HipExportedTargets
{
	nativeScript_D = 0,
	lua,
	unknown,
	count,
}
version (HipScriptingAPI)
{
	private __gshared Object[][HipExportedTargets.count] _hipExportedSharedUserData;
	export extern (C) void hipDestroy(Object reference, int target = HipExportedTargets.nativeScript_D);
	Object hipSaveRef(Object reference, int target = HipExportedTargets.nativeScript_D);
	void hipDestroyTarget(int target = HipExportedTargets.nativeScript_D);
}
