/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.reflection;
int asInt(alias enumMember)()
{
    alias T = typeof(enumMember);
    foreach(i, mem; __traits(allMembers, T))
    {
        if(mem == enumMember.stringof)
            return i;
    }
    ErrorHandler.assertLazyExit(0, "Member "~enumMember.stringof~" from type " ~ T.stringof~ " does not exist");
}

/**
*   Used when wanting to represent any struct compatible with a static array.
*/
bool isTypeArrayOf(Type, Array, int Count)()
{
    static if(is(Array == Type[Count]))
        return true;
    else static if(!is(Array == struct))
        return false;
    else
    {
        int count = 0;
  		static foreach(v; Array.tupleof)
    		static if(is(typeof(v) == Type))
      			count++;
            else static if(__traits(isStaticArray, typeof(v)) && is(typeof(v.init[0]) == Type))
            	count+= v.length;
  		return count == Count;
    }
}

bool isLiteral(alias variable)(string var = variable.stringof)
{
    assert(__ctfe);
    import hip.util.string : isNumeric;
    return (isNumeric(var) || (var[0] == '"' && var[$-1] == '"'));
}

template isDynamicArray(T)
{
    static if (is(T == U[], U))
        enum bool isDynamicArray = true;
    else static if (is(T U == enum))
        // BUG: isDynamicArray / isStaticArray considers enums
        // with appropriate base types as dynamic/static arrays
        // Retain old behaviour for now, see
        // https://github.com/dlang/phobos/pull/7574
        enum bool isDynamicArray = isDynamicArray!U;
    else
        enum bool isDynamicArray = false;
}

enum bool isArray(T) = isDynamicArray!T || __traits(isStaticArray, T);

/**
 * Detect whether type `T` is a pointer.
 */
enum bool isPointer(T) = is(T == U*, U);

/**
 * Detect whether `T` is a built-in numeric type (integral or floating
 * point).
 */
template isNumeric(T)
{
    static if (!__traits(isArithmetic, T))
        enum isNumeric = false;
    else static if (__traits(isFloating, T))
        enum isNumeric = is(T : real); // Not __vector, imaginary, or complex.
    else static if (is(T U == enum))
        enum isNumeric = isNumeric!U;
    else
        enum isNumeric = __traits(isZeroInit, T) // Not char, wchar, or dchar.
            && !is(immutable T == immutable bool) && !is(T == __vector);
}



///Copy pasted from std.traits for not importing too many things
template isFunction(X...)
if (X.length == 1)
{
    static if (is(typeof(&X[0]) U : U*) && is(U == function) ||
               is(typeof(&X[0]) U == delegate))
    {
        // x is a (nested) function symbol.
        enum isFunction = true;
    }
    else static if (is(X[0] T))
    {
        // x is a type.  Take the type of it and examine.
        enum isFunction = is(T == function);
    }
    else
        enum isFunction = false;
}

template getParams (alias fn) 
{
	static if ( is(typeof(fn) params == __parameters) )
    	alias getParams = params;
}
alias Parameters = getParams;
enum hasModule(string modulePath) = (is(typeof((){mixin("import ", modulePath, ";");})));
enum hasType(string TypeName) = __traits(compiles, {mixin(TypeName, " _;");});

template isEnum(alias s)
{
    static if(is(s == enum))
        enum bool isEnum = true;
    else
        enum bool isEnum = false;
}


template getUDAs(alias symbol)
{
    enum getUDAs = __traits(getAttributes, symbol);
}

template hasUDA(alias symbol, alias UDA)
{
    enum helper = ()
    {
        bool ret = false;
        foreach(att; __traits(getAttributes, symbol))
        {
            static if(is(typeof(UDA)))
            {
                if(att == UDA) ret = true;
            }
            else
            {
                if(is(typeof(att) == UDA) || is(att == UDA)) ret = true;
            } 
        }
        return ret;
    }();
    enum hasUDA = helper;
}
template isReference(T)
{
    enum isReference = is(T == class) || is(T == interface);
}
template hasMethod(T, string method, Params...)
{
    enum hasMethod = __traits(hasMember, T, method) && is(getParams!(__traits(getMember, T, method)) == Params);
}

auto inverseLookup(alias lookupTable)()
{
    alias O = typeof(lookupTable.keys[0]);
    alias I = typeof(lookupTable.values[0]);
    O[I] output;
    static foreach(k, v; lookupTable)
        output[v] = k;
    return output;
}

/** 
*   Generates a function that executes a switch case from the associative array.
*
*   Pass true as the second parameter if reverse is desired.
*/
template aaToSwitch(alias aa, bool reverse = false)
{
    auto aaToSwitch(T)(T value)
    {
        switch(value)
        {
            static foreach(k, v; aa)
                static if(reverse)
                    case v: return k;
                else
                    case k: return v;                
            default:
                return typeof(return).init;
        }
    }
}


size_t enumLength(T)()
if(is(T == enum))
{
    return __traits(allMembers, T).length;
}


/**
* Used on: 
*   - Static Methods
*   - Class Names
*   Used in conjunction to ExportDFunctions.
*   You may specify a suffix, if you so, `_suffix` is added
*   ExportD will do nothing to static methods when building release. However, it will still produce
*   a function for returning a new class.
*/
struct ExportD{string suffix;}


/**
*   Will basically generate an export name such as className_funcSymbol
*   If it has ExportD with a suffix, it will be basically className_funcSymbol(suffix)
*/
template generateExportName(string className, alias funcSymbol)
{
	//Means that it has a suffix
	static if(is(typeof(__traits(getAttributes, funcSymbol)[0]) == ExportD))
		enum generateExportName = className~"_"~__traits(identifier, funcSymbol)~"_"~__traits(getAttributes, funcSymbol)[0].suffix;
	else
		enum generateExportName = className~"_"~__traits(identifier, funcSymbol);
}

/**
*   Returns a code to be mixed in.
*   If isRef, it will call with hipSaveRef for not being colled
*   funcCallCode can be anything as `className.functionName` or even `new Class`
*/
private string getExportedFuncImpl(bool isRef, string funcCallCode)
{
    assert(__ctfe);
    string ret;
    if(isRef)
    {
        ret = q{
            import hip.util.lifetime;
            return cast(typeof(return))hipSaveRef(cast(Object)
        } ~ funcCallCode~"(__traits(parameters)));}";
    }
    else
    {
        ret = "return "~funcCallCode~"(__traits(parameters));}";
    }
    return ret;
}


///ClassT, Ctor, string className
///This class MUST have an interface, because it will bug out when calling the function with `need opCmp for class`
template generateExportConstructor(ClassT, string className)
{
    enum impl = ()
    {
        return "export extern(System) I" ~ className ~ " new" ~ className ~ //export extern(System) Class newClass
        "(getParams!(__traits(getMember, Class, \"__ctor\"))){"~ //(A a, B b...)
        getExportedFuncImpl
        (
            true, //IsReference
            "new "~className
        );
    }();

    enum generateExportConstructor = impl;
}

/**
*   It will create a `export extern(System)` function, thus, making it a C callable code.
*   This function comes from a static method, and has special code injection for making the
*   GC not collect if it is an object
*/
template generateExportFunc(string className, alias funcSymbol)
{
    import std.traits:ReturnType;
    enum impl = ()
    {
        assert(__ctfe);

        alias RetType = ReturnType!funcSymbol;
        string ret = "export extern(System) "~RetType.stringof~" "~generateExportName!(className, funcSymbol);
        ret~= "(getParams!(sym)){";

        ret~= getExportedFuncImpl
        (
            isReference!(RetType),
            className~"."~__traits(identifier, funcSymbol)
        );

        return ret;
    }();

    enum generateExportFunc = impl;
}


struct Version
{
    template opDispatch(string s)
    {
        mixin(`version(`~s~`)enum opDispatch=true;else enum opDispatch=false;`);
    }
}



///Intermediary step for getting an alias to the Class type
mixin template ExportDFunctionsImpl(string className, Class)
{
    //If the class has ExportD, it will export a function called new(ClassName)
    //It can't contain more than one constructor.
    static if(hasUDA!(Class, ExportD))
    {
        static assert(
            __traits(getOverloads, Class, "__ctor").length == 1, 
            "Can't export class with more than one constructor ("~className~")"
        );
        mixin(
            generateExportConstructor!(Class, className)
        );
        pragma(msg, "Exported Class "~className);
    }
    //Get all static methods that has ExportD
    static foreach(sym; getSymbolsByUDA!(Class, ExportD))
    {
        static if(!is(sym == Class))
        {
            //Assert that the symbol to generate does not exists yet
            static assert(__traits(compiles, mixin(generateExportName!(className, sym))),
            "ExportD '" ~ generateExportName!(className, sym) ~
            "' is not unique, use ExportD(\"SomeName\") for overloading with a suffix");

            pragma(msg, "Exported "~(generateExportName!(className, sym)));
            //Func signature
            //Check if it is a non value type
            mixin(generateExportFunc!(className, sym));
        }
    }
}


/**
*   Iterates through a module and generates `export` function declaration for each
*   @ExportD function found on it.
*   If the class itself is @ExportD, it will create a method new(ClassName) to be exported too
*/
mixin template ExportDFunctions(alias mod)
{
	import std.traits:getSymbolsByUDA, ParameterIdentifierTuple;
    pragma(msg, "Exporting ", mod.stringof);
	static foreach(mem; __traits(allMembers, mod))
	{
        //Currently only supported on classes and structs
		static if( (is(__traits(getMember, mod, member) == class) || is(__traits(getMember, mod, member) == struct) ))
		{
            mixin ExportDFunctionsImpl!(mem, __traits(getMember, mod, member));
		}
	}
}


/**
*   Intermediary step for getting an alias to the Class type
*   The difference with HipExportDFunctionsImpl is that it does not generate
*   Static method output when not in script version.
*/
mixin template HipExportDFunctionsImpl(string className, Class)
{
    //If the class has ExportD, it will export a function called new(ClassName)
    //It can't contain more than one constructor.
    static if(hasUDA!(Class, ExportD))
    {
        static assert(
            __traits(getOverloads, Class, "__ctor").length == 1, 
            "Can't export class with more than one constructor ("~className~")"
        );
        mixin(
            generateExportConstructor!(Class, className)
        );
        pragma(msg, "Exported Class "~className);
    }
    version(Load_DScript)
    {
        //Get all static methods that has ExportD
        static foreach(sym; getSymbolsByUDA!(Class, ExportD))
        {
            static if(!is(sym == Class))
            {
                //Assert that the symbol to generate does not exists yet
                static assert(__traits(compiles, mixin(generateExportName!(className, sym))),
                "ExportD '" ~ generateExportName!(className, sym) ~
                "' is not unique, use ExportD(\"SomeName\") for overloading with a suffix");

                pragma(msg, "Exported "~(generateExportName!(className, sym)));
                //Func signature
                //Check if it is a non value type
                mixin(generateExportFunc!(className, sym));
            }
        }
    }
}

/**
*   Iterates through a module and generates `export` function declaration for each
*   @ExportD function found on it.
*   If the class itself is @ExportD, it will create a method new(ClassName) to be exported too
*   *   The difference with HipExportDFunctions is that it does not generate
*   *   Static method output when not in script version.
*/
mixin template HipExportDFunctions(alias mod)
{
	import std.traits:getSymbolsByUDA;
    pragma(msg, "Exporting ", mod.stringof);
	static foreach(mem; __traits(allMembers, mod))
	{
        //Currently only supported on classes and structs
		static if( (is(__traits(getMember, mod, mem) == class) || is(__traits(getMember, mod, mem) == struct) ))
		{
            mixin HipExportDFunctionsImpl!(mem, __traits(getMember, mod, mem));
		}
	}
}


string attributes(alias member)() 
{
    if(!__ctfe)
        return null;

	string ret;
	foreach(attr; __traits(getFunctionAttributes, member))
		ret~= attr ~ " ";
	return ret;
}




template hasOverload(T,string member, OverloadType)
{
    bool impl()
    {
        if(!__ctfe)
            return false;
        bool ret = false;
        static foreach(ov; __traits(getVirtualMethods, T, member))
            static if(is(typeof(ov) == OverloadType))
                ret = true;
        return ret;
    }

    enum hasOverload = impl;
}


bool isMethodImplemented(T, string member, FuncType)()
{
    if(!__ctfe)
        return false;
    bool ret;
    static foreach(overload; __traits(getVirtualMethods, T, member))
        if(is(typeof(overload) == FuncType) && !__traits(isAbstractFunction, overload))
            ret = true;
    return ret;
}


/** 
 * Private to forward interface
 */
string ForwardFunc(alias func, string funcName, string member)()
{
    if(!__ctfe) return null;

    return attributes!func~ " ReturnType!(ov) " ~ funcName ~ "(getParams!(ov))"~
         "{ return " ~ member ~ "." ~funcName ~ "(__traits(parameters));}";
}

/**
*   This function receives a string containing the member name which implements the interface I.   
*   
*   So, whenever something calls the interface.memberFunction, it will forward the call to that member by doing
*   `void memberFunction(){member.memberFunction();}`, if the function is already defined, it will be ignored.
*
*   [Dev: Futurely, it should be changed to use `alias member` instead of getting its string.]
*/
string ForwardInterface(string member, I)() if(is(I == interface))
{
    import hip.util.string:replaceAll;
    if(!__ctfe) return null;

    return q{
        import std.traits:ReturnType;
        import hip.util.reflection:isMethodImplemented, ForwardFunc, getParams;

        static assert(is(typeof($member) : $I),
            "For forwarding the interface, the member $member should be or implement $I"
        );

        static foreach(m; __traits(allMembers, $I)) 
        static foreach(ov; __traits(getVirtualMethods, $I, m))
        {
            //Check for overloads here
            static if(!isMethodImplemented!(typeof(this), m, typeof(ov)))
                mixin(ForwardFunc!(ov, m, "$member"));
        }
    }.replaceAll("$I", I.stringof).replaceAll("$member", member);
}

mixin template ForwardInterface2(string member, I) if(is(I == interface))
{
    import hip.util.reflection:isMethodImplemented, ForwardFunc;

    static assert(is(typeof(mixin(member)) : I),
        "For forwarding the interface, the member "~member~" should be or implement "~I.stringof
    );

    static foreach(m; __traits(allMembers, I)) 
    static foreach(ov; __traits(getVirtualMethods, I, m))
    {
        //Check for overloads here
        static if(!isMethodImplemented!(typeof(this), m, typeof(ov)))
            mixin(ForwardFunc!(ov, m, member));
    }
}

mixin template MultiInherit(I) if(is(I == interface))
{
    mixin("private I ",I.stringof,"_impl");
    mixin(ForwardInterface!(I.stringof~"_impl", I));
}


void GenerateGetterSettersInterfaceImpl(interface_)()
{
    if(!__ctfe) return;

    import hip.util.array;
    foreach(mem; __traits(allMembers, interface_))
    {
        alias member = __traits(getMember, interface_, mem);
        if(__traits(isFinalFunction, member))
            continue;
        auto attributes = __traits(getFunctionAttributes, member);
        if(attributes.contains("ref"))
            continue;
    }

}

/**
*   Generates getter and setter for given interface.
*   - Final methods are excluded.
*   - `void` return types are excluded
*   - `const` methods will only generate the const getter
*/
mixin template GenerateGettersSettersInterface(interface_) if(is(interface_ == interface))
{
    static foreach(mem; __traits(allMembers, interface_))
    {

    }
}

/**
* This mixin is able to generate runtime accessors. That means that by having a string, it is
*possible to modify 
*/
mixin template GenerateRuntimeAccessors()
{
    T* getProperty(T)(string prop)
    {
        alias T_this = typeof(this);

        switch(prop)
        {
            static foreach(member; __traits(allMembers, T_this))
            {
                static if(is(typeof(__traits(getMember, T_this, member)) == T))
                {
                    case member:
                        return &__traits(getMember, T_this, member);
                }
            }
            default:
                return null;
        }
    }

    void setProperty(T)(string propName, T value)
    {
        T* prop = getProperty!T(propName);
        if(prop !is null)
            *prop = value;
    }
}