/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module imgui.imgui_debug;
version(CIMGUI):
import std.traits : getUDAs;
import bindbc.cimgui;
import hipaudio.audio;
import std.string:toStringz;
import core.stdc.string:strlen;
import debugging.gui;

immutable float FLOAT_MIN = cast(float)int.min;
immutable float FLOAT_MAX = cast(float)int.max;




void addDebug(alias variable, T = typeof(variable))(ref typeof(variable) var = variable)
{
    static if(is(T == float))
    {
        igInputFloat(variable.stringof, &var, 0.01f, 5f, null, 0);
    }
    else static if(is(T == int))
    {
        igInputInt(variable.stringof, &var, int.min, int.max, null, 0);
    }
    else static if(is(T == string))
    {
        char* val = var.toStringz;
        igInputText(variable.stringof.toStringz, val, 0, 0, null, null);
    }
    else static if(is(T == enum))
    {
        import util.reflection:asInt;
        static const(char)*[] opts; //Make it static for generating only one time
        static int currentOption = asInt!var; //Gets the current selected 
        static if(opts.length == 0) //Populate it only once
        {
            foreach (mem; __traits(allMembers, T))
            {
                static if(__traits(compiles, __traits(getMember, T, mem)))
                {
                    opts~=mem;
                }
            }
        }
        igComboStr_arr(variable.stringof, &currentOption, opts, opts, opts.length, DI.MAX_COMBO_BOX_HEIGHT);   
        
    }
    else static if(is(T == struct) || is(T == class))
    {
        static if(getUDAs!(T, InterfaceImplementation).length >= 1)
        {
            static assert(getUDAs!(T, InterfaceImplementation).length == 1, "Type "~ T.stringof~" should not have more than one InterfaceImplementation");
            void* varRef = cast(void*)&var;
            getUDAs!(T, InterfaceImplementation)[0].interfaceFunc(varRef);
        }
        else
        {
            igBeginGroup();
            MEMBERS: foreach(mem; __traits(allMembers, T))
            {
                static if(__traits(compiles, __traits(getMember, T, mem)))
                {
                    enum name = "cls."~mem;
                    foreach(attr; __traits(getAttributes, mixin("T."~mem)))
                    {
                        static if(is(attr == Hidden))
                            continue MEMBERS;
                    }
                    // addDebug!mem;
                }
            }
            igEndGroup();
        }
    }
}