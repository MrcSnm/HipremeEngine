module data.ini;
import std.conv:to;
import util.file;

struct IniVar
{
    string name;
    string value;

    T get(T)(){return to!T(value);}
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

    auto opDispatch(string member)()
    {
        return blocks[member];
    }
    alias blocks this;
}