module hip.data.csv;

struct CSV
{
    string[][] data;
    string path;
}


CSV parseCSV(string data, const char fieldDelimiter = ',', const char textDelimiter = '"', string path = "")
{
    CSV ret;
    ret.path = path;
    size_t left = 0;
    bool hadDelimiter = false;
    bool lookingForEndOfTextDelimiter = false;
    string[] currentLine;
    foreach(i, ch; data)
    {
        switch(ch)
        {
            case fieldDelimiter:
                if(!lookingForEndOfTextDelimiter)
                {
                    if(hadDelimiter)
                    {
                        hadDelimiter = false;
                        currentLine~= data[left+1..i-1];
                    }
                    else
                    {
                        currentLine~= data[left..i];
                    }
                    left = i+1;
                }
                break;
            case '\n':
                if(!lookingForEndOfTextDelimiter)
                {
                    if(hadDelimiter)
                    {
                        hadDelimiter = false;
                        currentLine~= data[left+1..i-1];
                    }
                    else
                    {
                        currentLine~= data[left..i];
                    }
                    ret.data~= currentLine;
                    currentLine.length = 0;
                    left = i+1;
                }
                break;
            case textDelimiter:
                hadDelimiter = true;                
                //If the first character at left is the text delimiter, the entire slot is filled with text delimiter
                lookingForEndOfTextDelimiter = !lookingForEndOfTextDelimiter;
                break;
            default:break;
        }
    }
    return ret;
}
