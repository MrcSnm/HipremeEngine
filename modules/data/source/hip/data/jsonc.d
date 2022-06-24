module hip.data.jsonc;

version(HipJSON):
public import std.json;

JSONValue parseJSONC(string jsonc)
{
    return parseJSON(stripComments(jsonc));
}


/** 
*   Strips single and multi line comments (C style)
*/
string stripComments(string str)
{
    string ret;
    ulong i = 0;
    ulong length = str.length;
    ret.reserve(str.length);

    while(i < length)
    {
        //Don't parse strings from comments
        if(str[i] == '"')
        {
            ret~= '"';
            i++;
            while(i < length)
            {
                ret~= str[i];
                if(str[i] == '\\' && i+1 < length && str[i+1] == '"')
                {
                    i++;
                    ret~= '"';
                }
                else if(str[i] == '"')
                    break;
                i++;
            }
        }
        //Parse single liner comments
        else if(str[i] == '/' && i+1 < length && str[i+1] == '/')
        {
            i+=2;
            while(i < length && str[i] != '\n')
                i++;
        }
        //Parse multi line comments
        else if(str[i] == '/' && i+1 < length && str[i+1] == '*')
        {
            i+= 2;
            while(i < length)
            {
                if(str[i] == '*' && i+1 < length && str[i+1] == '/')
                    break;
                i++;
            }
            i+= 2;
        }
        //Safe check to see if it is in range
        if(i < length)
            ret~= str[i];
        i++;
    }
    return ret;
}
