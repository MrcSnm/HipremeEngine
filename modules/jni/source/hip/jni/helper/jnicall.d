module hip.jni.helper.jnicall;
import hip.util.conv:to;
import hip.util.format;
import hip.util.string;
import std.traits : isArray;
import hip.jni.jni;

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
            if(isUpperCase(path[i]))
                hasClass = true;
            className~=path[i];
        }
    }
    return className;
}

jclass javaGetClass(JNIEnv* env, string path)
{
    path = javaGetClassPath(path);
    if(path == "" || env == null)
        return null;
    return (*env).FindClass(env, path.toStringz);
}
string javaGetMethodName(string where)
{
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

enum D_TO_JAVA_TYPE_TABLE = 
[
    "ubyte"  : "jboolean",
    "byte"   : "jbyte",
    "ushort" : "jchar",
    "short"  : "jshort",
    "int"    : "jint",
    "long"   : "jlong",
    "float"  : "jfloat",
    "double" : "jdouble",
    "string" : "jstring"
];

D javaTypeToD(D, J)(JNIEnv* env, J value)
{
    enum javaType = javaGetType!D;
    enum javaTypeUpper = toUpper(javaType[0]) ~ javaType[1..$];

    static if(is(D == Object))
        return cast(void*)value;
    else static if(is(D == string))
    {
        const(char)* chs = (*env).GetStringUTFChars(env, value, null);
        string str = to!string(chs);
        (*env).ReleaseStringUTFChars(env, value, chs);
        return str;
    }
    else static if(!isArray!D)
        return cast(D)value;
    else
    {
        jarray obj = value;

        mixin(format!q{
            j%s* javaArr = (*env).Get%sArrayElements(env, cast(j%sArray)obj, null);
        }(javaType, javaTypeUpper, javaType));
        int arrL = (*env).GetArrayLength(env, obj);
        D ret;
        alias D_singleType = typeof(D.init[0]);
        static if(D.length == 0)
            ret.length = arrL;

        for(int i = 0; i < arrL; i++)
            ret[i] = cast(D_singleType)javaArr[i];

        mixin(format!q{(*env).Release%sArrayElements(env, obj, javaArr, 0);}(javaTypeUpper));
        return ret;
    }
}

string java_dType_to_javaType(string dType)()
{
    static assert((dType in D_TO_JAVA_TYPE_TABLE) != null, "Type "~dType~" not found in D_TO_JAVA table");
    return D_TO_JAVA_TYPE_TABLE[dType];
}

string java_convertParameterToD(string typeName, string varName)()
{
    enum isTypeArray = typeName.countUntil("[") != -1;

    static if(typeName.countUntil("string") != -1)
        return format!q{javaTypeToD!string(env, %s)}(varName);
    else static if(isTypeArray)
        return format!q{javaTypeToD!(%s)(env, %s)}(typeName, varName);
    else
        return varName;
}

string java_getParametersDef(string funcParams)()
{
    string ret = "";
    enum string[] argsSplit = funcParams.split(",");
    static foreach(i, v; argsSplit)
    {
        if(i != 0)
            ret~=",";
        ret~= java_dType_to_javaType!(argsSplit[i].split(" ")[0..$-1].join) //jstring, jboolean
        ~ " "~argsSplit[i].split(" ")[$-1]; //Variables names is the last after the split
    }
    return ret;
}

string java_getParametersCall(string funcParams)()
{
    string paramsCall = "";
    enum string[] paramsTemp = funcParams.split(",");

    static foreach(i, v; paramsTemp)
    {
        static if(i != 0)
            paramsCall~=",";
        mixin(format!q{enum string[] typeAndName_%s = v.split(" ");}(i));
        mixin(format!q{enum string type_%s = typeAndName_%s[0..$-1].join;}(i, i));
        mixin(format!q{enum string name_%s = typeAndName_%s[$-1];}(i, i));

        //Last string after space is the argument name
        paramsCall~= java_convertParameterToD!(
            mixin(format!q{type_%s}(i)), //Get type_0, type_1, type_n
            mixin(format!q{name_%s}(i)) ////Get name_0, name_1, name_n
        );
    }
    return paramsCall;
}


/**
*   This function should provide the module to import hip.for it being able to get the type.
*   Currently only supports basic types
*/
string javaGenerateMethod(alias javaPackage, string funcSymbol, string m = __MODULE__)()
{
    static assert(__traits(hasMember, javaPackage, "_packageName"), "JavaFunc error: "~javaPackage.stringof~" is not a java package");
    mixin("import "~m~";");


    enum metName = javaGenerateMethodName!(javaPackage)(funcSymbol);
    enum funcData = typeof(mixin(funcSymbol)).stringof;

    enum firstParensIndex = funcData.countUntil("(");
    enum string funcRet = funcData[0..firstParensIndex];
    enum string funcParams = funcData[firstParensIndex+1..$-1];

    enum string funcParamsConverted = java_getParametersDef!(funcParams);
    enum string paramsCall = java_getParametersCall!(funcParams);
    


    return format!q{
        export extern(C) %s %s (JNIEnv* env, jclass clazz, %s)
        {
            pragma(inline, true)
            %s(%s);
        }
    }(funcRet, metName, funcParamsConverted, funcSymbol, paramsCall);
}

/**
*
*   It would pretty much work as if extern(Java) existed. Generates the java side names function
*   definitions for functions marked with @JavaFunc
*   Don't yet support functions with underlines (I think that the mangling is _1, but need to test)
*/
mixin template javaGenerateModuleMethodsForPackage(alias javaPackage, alias module_, bool showGeneration = false)
{
    ///Must mix the hasUDA trait.
    import std.traits:hasUDA;
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
    immutable(string) _packageName = packageName;


    
    auto javaCall(T, string path, Args...)()
    {
        JNIEnv* env = _env;
        static if(is(T == void*))
            return javaCall!(Object, path, Args);
        static if(packageName[$-1] != '.' && path[0] != '.')
            enum where = packageName~"."~path;
        else
            enum where = packageName~path;
        enum s = getArgs!Args;
        string typeRepresentation = "(";
        
        enum javaType = javaGetType!T;
        enum javaTypeUpper = toUpper(javaType[0]) ~ javaType[1..$];


        foreach (i, a; Args)
        {
            typeRepresentation~= javaGetTypeRepresentation!(typeof(a));
            if(i < Args.length - 1)
                typeRepresentation~=",";
        }
        typeRepresentation~=")"~javaGetTypeRepresentation!T;
        

        jclass cls = javaGetClass(env, where);
        jmethodID id = (*env).GetStaticMethodID(env, cls,
        javaGetMethodName(where).toStringz, typeRepresentation.toStringz);

        static if(is(T == Object))
        {
            jobject obj = mixin(q{(*env).CallStaticObjectMethod(env, cls, id } ~s ~")");
            return cast(void*)obj;
        }
        else static if(is(T == string))
        {
            jstring obj = mixin(q{(*env).CallStaticObjectMethod(env, cls, id } ~ s~")");
            return javaTypeToD!T(env, obj);
        }
        else static if(!isArray!T)
            return cast(T)mixin(q{(*env).CallStatic}~javaTypeUpper~q{Method(env, cls, id } ~s~")");
        else
        {
            jarray obj = mixin(q{(*env).CallStaticObjectMethod(env, cls, id } ~ s~")");
            return javaTypeToD!T(env, obj);
        }
    }

}


// mixin template ExportJavaFuncs(alias module_, alias javaPackage)
// {

// }

void JNISetEnv(JNIEnv* env){_env = env;}
private __gshared JNIEnv* _env = null;