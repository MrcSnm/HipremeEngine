module hip.util.format;
import hip.util.string:count;
import hip.util.conv:to;

string format(string fmt, Args...)(Args a)
{
    string ret = "";
    int currArg = 0;

    string[] converted;
    static foreach(arg; a)
        converted~= to!string(arg);

    static assert(fmt.count("%s") == a.length, "Format specifiers count must match arguments count");

    for(int i = 0; i < fmt.length; i++)
    {
        if(i + 1 < fmt.length && fmt[i] == '%' && fmt[i+1] == 's')
        {
            i++;
            ret~= converted[currArg++];
        }
        else
            ret~= fmt[i];
    }
    return ret;
}


/** 
*   Unsafe function. It requires the programmer to use it correctly as the buffer size is preallocated.
*/
string fastUnsafeCTFEFormat(in string str, string[] replaceWith...) @trusted
{
    assert(__ctfe, "Can't be called on runtime. To force a CTFE usage, call as `enum variable = \"%s a = 500;\".fastUnsafeCTFEFormat(\"int\");`");
    char[] buffer;
    ptrdiff_t replaceSize;
    foreach(r; replaceWith)
        replaceSize+= cast(ptrdiff_t)r.length - cast(ptrdiff_t)"%s".length;
    buffer = new char[str.length + replaceSize];
    size_t leftBound = 0;
    size_t leftBoundInput = 0;
    size_t rightBound = 0;
    size_t currArg = 0;
    for(int i = 0; i < str.length; i++)
    {
        if(i + 1 < str.length && str[i] == '%' && str[i+1] == 's')
        {
            buffer[leftBound..rightBound] = str[leftBoundInput..i];
            i++;
            leftBoundInput = i+1;
            string r = replaceWith[currArg++];
            buffer[rightBound..rightBound+r.length] = r[];
            leftBound = rightBound = rightBound+r.length;
            if(currArg == replaceWith.length)
                break;
        }
        else
            rightBound++;
    }
    buffer[leftBound..$] = str[leftBoundInput..$];
    return cast(string)buffer;
}