module util.lifetime;

/**
*   That may be changed to an associative array in case of slowdowns
*/
private __gshared Object[] _hipExportedSharedUserData;
export extern(C) void hipDestroy(Object reference)
{
    for(ulong i = 0; i < _hipExportedSharedUserData.length; i++)
    {
        if(_hipExportedSharedUserData[i] == reference)
        {
            _hipExportedSharedUserData[i] = null;
            destroy(reference);
        }
    }
}

Object hipSaveRef(Object reference)
{
    for(ulong i = 0; i < _hipExportedSharedUserData.length; i++)
    {
        if(_hipExportedSharedUserData[i] is null)
        {
            _hipExportedSharedUserData[i] = reference;
            return reference;
        }
    }
    _hipExportedSharedUserData~= reference;
    return reference;
}