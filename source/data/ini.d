/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module data.ini;
import std.conv:to;
import util.file;

struct IniVar
{
    string name;
    string value;

    T get(T)(){return to!T(value);}
    string get(){return value;}
    auto opAssign(T)(T value)
    {
        this.value = to!string(value);
        return value;
    }

    string toString() const @safe pure nothrow{return name~" = "~ value;}
}

struct IniBlock
{
    string name;
    string comment;
    IniVar[string] vars;

    string toString() const @safe pure
    {
        string ret = "["~name~"]\n";
        foreach (v; vars)
            ret~= v.toString();
        return ret;
    }
    auto opDispatch(string member)()
    {
        return vars[member];
    }

    alias vars this;
}

class IniFile
{
    IniBlock[string] blocks;
    string path;
    bool configFound = false;
    bool noError = true;

    /**
    *   Simple parser for the .conf or .ini files commonly found.
    */
    static IniFile parse(string path)
    {
        IniFile ret = new IniFile();
        ret.path = path;
        string content = getFileContent(path);
        if(content != "")
            ret.configFound = true;

        for(int i = 0; i < content.length; i++)
        {
            char c = content[i];
            if(c == ';' || c == '#')
            {
                while(i < content.length && content[++i] != '\n'){}
                continue;
            }
            else if(c == '[')
            {
                import std.array:split;
                import util.string : replaceAll;
                import std.stdio;
                string capture = "";
                while(content[++i] != ']'){capture~=content[i];}
                if(i >= content.length)
                {
                    ret.noError = false;
                    break;
                }
                IniBlock block;
                block.name = capture;
                capture = "";
                while(++i < content.length && (c = content[i]) != '['){capture~=c;}
                string[] lines = capture.split("\n");
                foreach(l; lines)
                {
                    if(l == "")
                        continue;
                    string[] kv = l.split("=");
                    if(kv.length < 2)
                    {
                        ret.noError = false;
                        break;
                    }
                    string name = kv[0].replaceAll(' ', "");
                    string _val  = kv[1];
                    string val = "";
                    for(int z = 0; z < _val.length; z++)
                    {
                        if(_val[z] == '#' || _val[z] == ';')
                            break;
                        val~= _val[z];
                    }
                    val = val.replaceAll(' ', "");

                    block.vars[name] =  IniVar(name, val);
                }
                ret.blocks[block.name] = block;
                i--;
            }
        }
        return ret;
    }


    public T tryGet(T)(string varPath, T defaultVal = T.init)
    {
        import std.array:split;
        string[] accessors = varPath.split(".");
        if(accessors.length < 2)
            return defaultVal;
        IniBlock* b = (accessors[0] in this);
        if(b is null)
            return defaultVal;
        IniVar* v = (accessors[1] in *b);
        if(v is null)
            return defaultVal;
        return v.get!T;
    }

    auto opDispatch(string member)()
    {
        return blocks[member];
    }
    alias blocks this;
}