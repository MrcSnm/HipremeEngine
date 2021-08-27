module jni.helper.jnicall;
import std.conv:to;
import std.format:format;
import std.ascii:toUpper;
import std.array:split;
import std.string:toStringz;
import std.traits : isArray;
import std.algorithm:countUntil;
import jni.jni;

version(Android):

enum javaRep =
[
    "byte"  : "B",
    "ubyte" : "B",
    "char"  : "C",
    "bool"  : "Z",
    "int"   : "I",
    "uint"  : "I",
    "void"  : "V",
    "long"  : "J",
    "ulong" : "J",
    "float" : "F",
    "double": "D",
    "short" : "S",
    "ushort": "S",
    "string": "Ljava/lang/String;",
    "Object": "Ljava/lang/Object;"
];

enum javaGetTypeRepresentation(T)()
{
    static if(isArray!T && !is(T == string))
    {
        return "["~javaGetTypeRepresentation!(typeof(T.init[0]));
    }
    else
    {
        static assert((T.stringof in javaRep) !is null, "Type name "~T.stringof~" not found when searching for java type representation");
        return javaRep[T.stringof];
    }
}

string javaGetType(T)()
{
    long ind = T.stringof.countUntil("[");
    string ret = T.stringof;
    if(ind != -1)
        ret = ret[0..ind];
    switch(ret)
    {
        case "string":
            ret = "Ljava/lang/String;";
            break;
        case "Object":
            ret = "LJava/lang/Object;";
            break;
        case "uint":
            ret = "int";
            break;
        case "bool":
            ret~= "ean";
            break;
        case "ushort":
            ret = "short";
            break;
        case "ulong":
            ret = "long";
            break;
        default:break;
    }
    return ret;
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

template javaGetPackage(string packageName)
{
    JNIEnv* _env = null;
    void setEnv(JNIEnv* env){_env = env;}

    auto javaCall(T, string path, Args...)(JNIEnv* env = _env)
    {
        static if(is(T == void*))
            return javaCall!(Object, path, Args);
        static if(packageName[$-1] != '.' && path[0] != '.')
            enum where = packageName~"."~path;
        else
            enum where = packageName~path;
        enum s = getArgs!Args;
        string t = "(";
        string rep = "";
        enum ind = T.stringof.countUntil("[");
        enum isArray = ind != -1;
        static if(isArray)
            enum dType = T.stringof[0..ind];
        else
            enum dType = T.stringof;
        enum javaType = javaGetType!T;
        enum javaTypeUpper = toUpper(javaType[0]) ~ javaType[1..$];


        foreach (i, a; Args)
        {
            rep = javaGetTypeRepresentation!(typeof(a));
            t~= rep;
            if(i < Args.length - 1)
                t~=",";
        }
        t~=")"~javaGetTypeRepresentation!T;
        
        import console.log;

        jclass cls = javaGetClass(env, where);
        jmethodID id = (*env).GetStaticMethodID(env, cls, javaGetMethodName(where).toStringz, t.toStringz);

        static if(is(T == Object))
        {
            jobject obj = mixin(q{(*env).CallStaticObjectMethod(env, cls, id } ~s ~")");
            return cast(void*)obj;
        }
        else static if(is(T == string))
        {
            jstring obj = mixin(q{(*env).CallStaticObjectMethod(env, cls, id } ~ s~")");
            const(char)* chs = (*env).GetStringUTFChars(env, obj, null);
            string str = to!string(chs);
            (*env).ReleaseStringUTFChars(env, obj, chs);
            return str;
        }
        else static if(!isArray)
            return mixin(q{(*env).CallStatic}~javaTypeUpper~q{Method(env, cls, id } ~s~")");
        else
        {
            jarray obj = mixin(q{(*env).CallStaticObjectMethod(env, cls, id } ~ s~")");

            mixin(format!q{
                j%s* javaArr = (*env).Get%sArrayElements(env, cast(j%sArray)obj, null);
            }(javaType, javaTypeUpper, javaType));

            int arrL = (*env).GetArrayLength(env, obj);
            T ret;
            static if(T.length == 0)
                ret.length = arrL;

            for(int i = 0; i < arrL; i++)
                mixin("ret[i] = cast("~dType~")javaArr[i];");

            mixin(format!q{(*env).Release%sArrayElements(env, obj, javaArr, 0);}(javaTypeUpper));
            return ret;
        }
    }
}

alias javaCall = javaGetPackage!"".javaCall;