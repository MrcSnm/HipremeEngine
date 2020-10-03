module implementations.imgui.imgui_debug;
import bindbc.cimgui;
import std.string:toStringz;
import core.stdc.string:strlen;
import def.debugging.gui;

immutable float FLOAT_MIN = cast(float)int.min;
immutable float FLOAT_MAX = cast(float)int.max;

void addVecType(T, int dimensions, string vecName)()
{

}


void addDebug(alias variable)(ref typeof(variable) var = variable)
{
    alias T = typeof(variable);
    static if(is(T == float))
    {
        igDragFloat(variable.stringof, &var, 1, FLOAT_MIN, FLOAT_MAX, null, 0);
    }
    else static if(is(T == int))
    {
        igDragInt(variable.stringof, &var, int.min, int.max, null, 0);
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
    else static if(is(T == struct))
    {
        igBeginGroup();
        MEMBERS: foreach(mem; __traits(T, allMembers))
        {
            static if(__traits(compiles, __traits(getMember, T, mem)))
            {
                enum name = "cls."~mem;
                foreach(attr; __traits(getAttributes, mixin("T."~mem)))
                {
                    static if(is(attr == Hidden))
                        continue MEMBERS;
                }
                addDebug!(typeof(mem))(mem);
            }
        }
        igEndGroup();
    }
}