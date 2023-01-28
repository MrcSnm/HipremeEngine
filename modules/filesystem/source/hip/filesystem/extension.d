module hip.filesystem.extension;

/** 
 * Mixes `bool loadFromFile(T, string)`
 * If pathProperty not default, mixes `bool load(T)`
 */
mixin template HipFSExtend(T, string pathProperty = "", Args...)
{
    static assert(__traits(hasMember, T, "loadFromMemory"), "For being file system extended, it required loadFromMemory");
    bool loadFromFile(T instance, string path, Args args)
    {
        HipFS.read(path).addOnError((err)
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage(T.stringof, "Could not load " ~ path);
        }).addOnSuccess((in ubyte[] data)
        {
            instance.loadFromMemory(cast(ubyte[])data, args);
        });
        return true;
        
    }
    static if(pathProperty != "")
    {
        bool load(T instance)
        {
            return instance.loadFromFile(__traits(getMember, instance, pathProperty));
        }
    }
}