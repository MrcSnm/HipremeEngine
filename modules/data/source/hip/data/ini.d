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
import hip.api.data.asset;
import hip.util.conv:to;


class HipINI : HipAsset, IHipIniFile
{
    IniBlock[string] _blocks;
    string path;
    bool configFound = false;
    bool _noError = true;
    string[] errors;

    bool noError() const{return _noError;}
    ref IniBlock[string] blocks(){return _blocks;}
    const(string[]) getErrors() const{return cast(const)errors;}

    this()
    {
        super("HipINI");
        _typeID = assetTypeID!HipINI;
    }

    bool loadFromMemory(string data, string path)
    {
        this.path = path;
        if(data != "")
            configFound = true;

        for(int i = 0; i < data.length; i++)
        {
            char c = data[i];
            if(c == ';' || c == '#')
            {
                while(i < data.length && data[++i] != '\n'){}
                continue;
            }
            else if(c == '[')
            {
                import hip.util.string : replaceAll, trim, splitRange;
                import hip.util.algorithm:put;
                int captureStart = i+1;
                while(i < data.length)
                {
                    i++;
                    if(i >= data.length)
                        return true;
                    else if(data[i] == ']')
                        break;
                }

                IniBlock block;
                block.name = data[captureStart..i];
                string capture = "";
                captureStart = i+1;
                //Read until finding a key.
                while(++i < data.length && data[i] != '['){}
                capture = data[captureStart..i];

                
                foreach(l; capture.splitRange("\n"))
                {
                    l = l.trim;
                    if(l == "")
                        continue;
                    string k, v;
                    l.splitRange("=").put(&k, &v);
                    if(v == "")
                    {
                        errors~= "No value for key '"~k~"'";
                        _noError = false;
                        break;
                    }
                    string name = k.replaceAll(' ', "");
                    block.vars[name] =  IniVar(name, formatValue(v));
                }
                blocks[block.name] = block;
                i--;
            }
        }
        return true;
    }

    /**
    *   Simple parser for the .conf or .ini files commonly found.
    */
    static HipINI parse(string content, string path = "")
    {
        HipINI f = new HipINI();
        if(!f.loadFromMemory(content, path))
            return null;
        return f;
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

    override void onFinishLoading(){}
    override void onDispose(){}
    override bool isReady() const {return errors.length == 0;}

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
