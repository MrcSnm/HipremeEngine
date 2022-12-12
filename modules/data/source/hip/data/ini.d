/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.data.ini;
public import hip.api.data.ini;
import hip.util.conv:to;


class IniFile : IHipIniFile
{
    IniBlock[string] _blocks;
    string path;
    bool configFound = false;
    bool _noError = true;
    string[] errors;

    bool noError() const{return _noError;}
    ref IniBlock[string] blocks(){return _blocks;}
    const(string[]) getErrors() const{return cast(const)errors;}

    /**
    *   Simple parser for the .conf or .ini files commonly found.
    */
    static IniFile parse(string content, string path = "")
    {
        IniFile ret = new IniFile();
        ret.path = path;
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
                import hip.util.string : replaceAll, trim, splitRange;
                import hip.util.algorithm:put;
                string capture = "";
                while(i < content.length)
                {
                    i++;
                    if(i >= content.length)
                        return ret;
                    else if(content[i] == ']')
                        break;
                    else
                        capture~=content[i];
                }

                IniBlock block;
                block.name = capture;
                capture = "";
                //Read until finding a key.
                while(++i < content.length && (c = content[i]) != '['){capture~=c;}

                
                foreach(l; capture.splitRange("\n"))
                {
                    l = l.trim;
                    if(l == "")
                        continue;
                    string k, v;
                    l.splitRange("=").put(&k, &v);
                    if(v == "")
                    {
                        ret.errors~= "No value for key '"~k~"'";
                        ret._noError = false;
                        break;
                    }
                    string name = k.replaceAll(' ', "");
                    block.vars[name] =  IniVar(name, formatValue(v));
                }
                ret.blocks[block.name] = block;
                i--;
            }
        }
        return ret;
    }

    IniVar* getIniVar(string varPath)
    {
        import hip.util.string:splitRange;
        import hip.util.algorithm;
        string accessorA, accessorB;
        varPath.splitRange(".").put(&accessorA, &accessorB);
        if(accessorB == "")
            return null;
        IniBlock* b = (accessorA in blocks);
        if(b is null)
            return null;
        return (accessorB in *b);
    }
}

/**
*   Remove comments and spaces from the Value from KeyValue pair
*/
private string formatValue(string unformattedValue)
{
    string ret;
    foreach(ch; unformattedValue)
    {
        if(ch == '#' || ch == ';') //Remove comments
            break;
        if(ch == ' ') //Remove spaces for to!int and friends working correctly
            continue;
        ret~= ch;
    }
    return ret;
}
