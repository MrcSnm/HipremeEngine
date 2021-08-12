/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module def.debugging.runtime;
import global.udas;
import std.traits : isFunction;

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