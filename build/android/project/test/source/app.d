module test;
import jni;
import core.runtime;
import object;

export extern(C) int Java_com_hipremeengine_app_HipremeEngine_get50()
{
    try{
        throw new Throwable("This is a freaking bat");
    }
    catch(Throwable e)
    {
        import std.stdio;
        e.toString();
        writeln(e);
    }
    return 50;
}
export extern(C) jstring Java_com_hipremeengine_app_HipremeEngine_toStr(JNIEnv* env, jclass clazz, jint integer)
{
    import std.conv:to;
    char* str = cast(char*)(to!string(integer)~" integer.\0").ptr;
    return (*env).NewStringUTF(env, str);
}

export extern(C) bool Java_com_hipremeengine_app_HipremeEngine_init()
{
    rt_init();
    return true;
}
