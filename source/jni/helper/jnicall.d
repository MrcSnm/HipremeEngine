module jni.helper.jnicall;
import std.array:split;
import std.string:toStringz;
import std.traits : isArray;
import std.algorithm:countUntil;
import jni.jni;


string javaGetTypeRepresentation(T)()
{
    static if(isArray!T)
        return "["~javaGetTypeRepresentation!(mixin(T.stringof[0..T.stringof.countUntil("[")]));
    final switch(T.stringof)
    {
        case "byte":
        case "ubyte":
            return "B";
        case "char":
            return "C";
        case "bool":
            return "Z";
        case "int":
        case "uint":
            return "I";
        case "void":
            return "V";
        case "long":
        case "ulong":
            return "J";
        case "float":
            return "F";
        case "double":
            return "D";
        case "short":
        case "ushort":
            return "S";
    }
}

private string getArgs(Args...)()
{
    string s;
    static foreach(i, a; Args)
    {
        static if(i < Args.length - 1)
            s~= a.stringof~",";
        else    
            s~= a.stringof;
    }
    return (s.length > 0 ? (","~s) : "") ;
}

string javaGetClassPath(string path)
{
    import std.ascii:isUpper;
    string className;

    bool hasClass = false;

    for(int i = 0; i < path.length; i++)
    {
        if(path[i] == '.')
        {
            if(hasClass)
                break;
            className~="/";
        }
        else
        {
            if(isUpper(path[i]))
                hasClass = true;
            className~=path[i];
        }
    }
    return className;
}

jclass javaGetClass(JNIEnv* env, string path)
{
    path = javaGetClassPath(path);
    if(path == "")
        return null;
    return (*env).FindClass(env, path.toStringz);
}
string javaGetMethodName(string where)
{
    import std.string:lastIndexOf;
    long ind = lastIndexOf(where, '.');
    bool isMethodOnly = ind == -1;

    if(isMethodOnly)
        return where;
    else
        return where[ind+1..$];
}

T javaCall(T, string where, Args...)(JNIEnv* env)
{
    enum s = getArgs!Args;
    string t = "(";
    string rep = "";
    foreach (i, a; Args)
    {
        rep = javaGetTypeRepresentation!(typeof(a));
        t~= rep;
        if(i < Args.length - 1)
            t~=",";
    }
    t~=")"~javaGetTypeRepresentation!T;
    

    jclass cls = javaGetClass(env, where);
    jmethodID id = (*env).GetStaticMethodID(env, cls, javaGetMethodName(where).toStringz, t.toStringz);
    static if(is(T == int) || is(T == uint))
    {
        return mixin(q{(*env).CallStaticIntMethod(env, cls, id }~s~")");
    }
    else static if(is(T == bool))
    {
        return mixin(q{(*env).CallStaticBooleanMethod(env, cls, id }~s~");");
    }
    else static if(is(T == char))
    {
        return mixin(q{(*env).CallStaticCharMethod(env, cls, id }~s~");");
    }
    else static if(is(T == short) || is(T == ushort))
    {
        return mixin(q{(*env).CallStaticShortMethod(env, cls, id }~s~");");
    }
    else static if(is(T == float))
    {
        return mixin(q{(*env).CallStaticFloatMethod(env, cls, id }~s~");");
    }
    else static if(is(T == double))
    {
        return mixin(q{(*env).CallStaticDoubleMethod(env, cls, id }~s~");");
    }
    else static if(is(T == long) || is(T == ulong))
    {
        return mixin(q{(*env).CallStaticLongMethod(env, cls, id }~s~");");
    }
    else static if(is(T == void))
    {
        return mixin(q{(*env).CallStaticVoidMethod(env, cls, id }~s~");");
    }

}