/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.debugging.runtime;
import std.traits : isFunction;

/**
* UDA used together with runtime debugger, it won't print if it has this attribute
*/
struct Hidden;

/**
* UDA used together with runtime debugger, mark your class member for being able to change
* the target property on the runtime console
*/
struct RuntimeConsole;


/**
* Each time a variable is registered, it goes in there for being able to runtime cast it
*/
private string[] REGISTERED_TYPES;

struct RuntimeVariable
{
    void* var;
    string name;
    string type;
}


class RuntimeDebug
{
    /**
    * Prints every member from a class instance
    */
    public static void instancePrint(alias instance)(const ref typeof(instance) cls = instance)
    {
        version(HIPREME_DEBUG)
        {
            import std.stdio:writefln;
            alias T = typeof(instance);
            MEMBERS: foreach(member; __traits(allMembers, T))
            {
                //Guards against potential erros like getting private members
                static if(__traits(compiles, __traits(getMember, T, member)))
                {
                    enum name = "cls."~member;
                    foreach(attr; __traits(getAttributes, mixin("T."~member)))
                    {
                        static if(is(attr == Hidden))
                            continue MEMBERS;
                    }
                    static if(!mixin("isFunction!("~cls.stringof~"."~member~")") && member != "Monitor")
                    {
                        mixin("writefln(\""~instance.stringof~"."~member~": %s\", mixin(name));");
                    }
                }
            }
        }
    }

    public static void attachVar(alias varSymbol)(const ref typeof(varSymbol) var = varSymbol)
    {
        version(HIPREME_DEBUG)
        {
            alias T = typeof(varSymbol);
            static if(is(T == class))
            {
                static foreach(member; __traits(allMembers, T))
                {
                    static if(__traits(compiles, __traits(getMember, T, member)))
                    {
                        foreach(attr; __traits(getAttributes, mixin("T."~member)))
                        {
                            static if(is(attr == RuntimeConsole))
                            {
                                
                                break;
                            }
                        }
                    }
                }
            }
            else
            {

            }
        }
    }

    // public static alias[] variables;
}