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
string javaGenerateMethodName(alias javaPackage)(string method)
{
    string packName;
    string pName = javaPackage._packageName;
    for(ulong i = 0; i < pName.length; i++)
    {
        if(pName[i] == '.')
            packName~= '_';
        else
            packName~= pName[i];
    }
    return "Java_"~packName~"_"~method;
}

/**
*   This function should provide the module to import for it being able to get the type
*/
string javaGenerateMethod(alias javaPackage, string funcSymbol, string m = __MODULE__)()
{
    static assert(__traits(hasMember, javaPackage, "_packageName"), "JavaFunc error: "~javaPackage.stringof~" is not a java package");
    import std.algorithm:countUntil;
    import std.array:split;
    import std.format:format;
    mixin("import "~m~";");


    enum metName = javaGenerateMethodName!(javaPackage)(funcSymbol);
    enum funcData = typeof(mixin(funcSymbol)).stringof;

    long firstParensIndex = funcData.countUntil("(");
    string funcRet = funcData[0..firstParensIndex];
    string funcParams = funcData[firstParensIndex+1..$-1];

    string[] paramsTemp = funcParams.split(",");

    string paramsCall;
    for(int i = 0; i < paramsTemp.length; i++)
    {
        if(i != 0)
            paramsCall~=",";
        paramsCall~= (paramsTemp[i].split(" "))[$-1]; //Last string after space is the argument name
    }


    return format!q{
        extern(C) %s %s (%s)
        {
            pragma(inline, true)
            %s(%s);
        }
    }(funcRet, metName, funcParams, funcSymbol, paramsCall);
}


mixin template javaGenerateModuleMethodsForPackage(alias javaPackage, alias module_, bool showGeneration = false)
{
    static foreach(m;  __traits(allMembers, module_))
    {
        static if(hasUDA!(mixin(m), JavaFunc!javaPackage))
        {
            static if(showGeneration)
            {
                pragma(msg, m,":");
                pragma(msg, javaGenerateMethod!(javaPackage, m));
            }
            mixin(javaGenerateMethod!(javaPackage, m));
        }
    }
}

/**
*   By not using templated struct, no instantiation will be required, and it will 
*   be easier for searching when using __traits
*/
struct JavaFunc_{string packageName;}

enum JavaFunc(alias T)()
{
    static assert(__traits(hasMember, T, "_packageName"), "JavaFunc error: "~T.stringof~" is not a java package");
    return JavaFunc_(T._packageName);
}

template javaGetPackage(string packageName)
{
    JNIEnv* _env = null;
    immutable(string) _packageName = packageName;
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
        {
            return cast(T)mixin(q{(*env).CallStatic}~javaTypeUpper~q{Method(env, cls, id } ~s~")");
        }
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


// mixin template ExportJavaFuncs(alias module_, alias javaPackage)
// {

// }

alias javaCall = javaGetPackage!("").javaCall;