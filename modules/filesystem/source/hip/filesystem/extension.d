module hip.filesystem.extension;

/** 
 * Mixes `bool loadFromFile(T, string)`
 * If pathProperty not default, mixes `bool load(T)`
 */
mixin template HipFSExtend(T, string pathProperty = "")
{
    static assert(__traits(hasMember, T, "loadFromMemory"), "For being file system extended, it required loadFromMemory");
    bool loadFromFile(T instance, string path)
    {
        ubyte[] data;
        import std.stdio;
        if(!HipFS.read(path, data))
            return false;
        return instance.loadFromMemory(data);
        
    }
    static if(pathProperty != "")
    {
        bool load(T instance)
        {
            return instance.loadFromFile(mixin("instance.",pathProperty));
        }
    }
}