module util.format;
import util.string:count;
import util.conv:to;

string format(alias fmt, Args...)(Args a)
{
    static assert(is(typeof(fmt) == string), "Format can only receive strings");
    string ret = "";
    int currArg = 0;

    string[] converted;
    static foreach(arg; a)
        converted~= to!string(arg);

    static assert(fmt.count("%s") == a.length, "Format specifiers count must match arguments count");

    for(int i = 0; i < fmt.length; i++)
    {
        if(i + 1 < fmt.length)
        {
            if(fmt[i] == '%' && fmt[i+1] == 's')
            {
                i++;
                ret~= converted[currArg++];
            }
            else
                ret~= fmt[i];
        }
    }
    return ret;
}
