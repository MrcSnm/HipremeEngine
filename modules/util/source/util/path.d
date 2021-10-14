module util.path;

string[] pathSplitter(string path)
{
    string[] ret;
    string current;
    for(ulong i = 0; i < path.length; i++)
    {
        if(path[i] == '/' || path[i] == '\\')
        {
            ret~= current;
            current = null;
            continue;
        }
        current~= path[i];
    }
    if(current.length != 0)
        ret~= current;
    return ret;
}