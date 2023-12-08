module hip.console.log;



void loglnImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__);
void loglnInfoImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__);
void loglnWarnImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__);
void loglnErrorImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__);
void rawlogImpl(string str);
void rawwarnImpl(string str);
void rawinfoImpl(string str);
void rawerrorImpl(string str);
void rawfatalImpl(string str);

mixin template mxGenLogDefs()
{
    static foreach(mem; __traits(allMembers, hip.console.log))
    {
        static if(mem[0..3] == "raw")
        {
            mixin("void ", mem[0..$-"Impl".length], 
            " (Args...)(Args a){import hip.util.string; ",mem,"(String(a).toString);}");
        }
        else
        mixin("void ", mem[0..$ -"Impl".length], 
        " (Args...)(Args a, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__)",
        " {import hip.util.string; ",mem,"(String(a).toString, f, fn, l);}");
    }
}