module hip.data.jsonc;
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
    size_t i = 0;
    size_t length = str.length;
    ret.reserve(str.length);

    while(i < length)
    {
        //Don't parse comments inside strings
        if(str[i] == '"')
        {
            size_t left = i;
            i++;
            while(i < length && str[i] != '"')
            {
                if(str[i] == '\\')
                    i++;
                i++;
            }
            i++; //Skip '"'
            ret~= str[left..i];
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
