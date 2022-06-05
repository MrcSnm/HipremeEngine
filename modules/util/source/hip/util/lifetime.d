module hip.util.lifetime;


/** 
 * Not yet complete. Need more work.
 */
mixin template RefCounted()
{
    private int* countPtr;
    this(this)
    {
        if(countPtr != null)
            *countPtr = *countPtr + 1;
    }
    void startRefCount()
    {
        import core.stdc.stdlib:malloc;
        countPtr = malloc(int.sizeof);
        *countPtr = 1;
    }
    ~this()
    {
        if(countPtr != null)
        {
            *countPtr = *countPtr - 1;
            if(*countPtr == 0)
                dispose();
            import core.stdc.stdlib: free;
            free(countPtr);
            countPtr = null;
        }
    }
}

/**
*   Use this function to export 
*/
enum HipExportedTargets
{
    nativeScript_D = 0,
    lua,
    unknown,
    count
}


/**
*   That may be changed to an associative array in case of slowdowns
*/
private __gshared Object[][HipExportedTargets.count] _hipExportedSharedUserData;

export extern(C) void hipDestroy(Object reference, int target = HipExportedTargets.nativeScript_D)
{
    for(ulong i = 0; i < _hipExportedSharedUserData.length; i++)
    {
        if(_hipExportedSharedUserData[target][i] == reference)
        {
            _hipExportedSharedUserData[target][i] = null;
            destroy(reference);
        }
    }
}

Object hipSaveRef(Object reference, int target = HipExportedTargets.nativeScript_D)
{
    for(ulong i = 0; i < _hipExportedSharedUserData.length; i++)
    {
        if(_hipExportedSharedUserData[target][i] is null)
        {
            _hipExportedSharedUserData[target][i] = reference;
            return reference;
        }
    }
    _hipExportedSharedUserData[target] ~= reference;
    return reference;
}

/**
*   Destroys every reference inside the target. This function is useful
*   for managing the destruction for the targets
*/
void hipDestroyTarget(int target = HipExportedTargets.nativeScript_D)
{
    for(int i = 0; i < _hipExportedSharedUserData[target].length; i++)
    {
        if(_hipExportedSharedUserData[target][i] is null)
            break;
        hipDestroy(_hipExportedSharedUserData[target][i], target);
    }
}