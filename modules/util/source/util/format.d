module util.format;

string format(string fmt, Args...)(Args a)
{
    string ret;
    for(int i = 0; i < fmt.length; i++)
    {
        if(fmt[i] == "%")
        {
            indices[i]~= i;
            i++;
            continue;
        }
        else
            ret~= fmt[i];
    }

}