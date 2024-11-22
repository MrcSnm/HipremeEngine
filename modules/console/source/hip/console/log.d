/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.console.log;
import hip.console.console;
import hip.util.conv:to;
import hip.util.format;

private string[] logHistory = [];


///Creates a variable which is always logged whenever modified.
struct Logged(T)
{
    T val;
    private string name;
    this(T initial, string name = "")
    {
        this.val = initial;
        this.name = name;
    }

    pragma(inline, true) void print(T value, string f = __FILE__, size_t l = __LINE__)
    {
        rawlog("Modified ", name, " from ", val, " to ", value, " at ", f, ":", l);
    }

    auto opAssign(T value, string f = __FILE__, size_t l = __LINE__)
    {
        print(value, f, l);
        val = value;
        return this;
    }
    auto opOpAssign(string op, T)(T value, string f = __FILE__, size_t l = __LINE__)
    {
        T newV = mixin("val",op,"value");
        print(newV, f, l);
        val = newV;
        return this;
    }
    bool opEquals(const T other) const{return val == other;}
    auto opUnary(string op)(string f = __FILE__, size_t l = __LINE__)
    {
        static if(op == "++" || op == "--")
        {
            T oldV = val;
            mixin(op,"val;");
            rawlog("Modified ", name, " from ", oldV, " to ", val, " at ", f, ":", l);
            return val;
        }
        else
            return mixin(op,"val;");
    }
}
private string _formatPrettyFunction(string f) @nogc
{
    import hip.util.string : lastIndexOf;

    return f[0..f.lastIndexOf("(")];
}


/**
*   hiplog is a special function and should be used only within the engine for documentation.
*   It generates less data by not taking the function name and simplifying the read load.
*   Think of that as a verbose of what the engine is currently doing.
*/
void hiplog(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    import hip.config.opts;
    static if(HIP_TRACK_HIPLOG)
        Console.DEFAULT.hipLog("HIP: ", a, " [[", file, ":", line, "]]");
    else
        Console.DEFAULT.hipLog("HIP: ", a);
}


void logln(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__) @nogc
{
    Console.DEFAULT.log(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction);
}


mixin template loglnVars(Args...)
{
    enum log = ()
    {
        import hip.console.console;
        static foreach(i; 0..Args.length)
            Console.DEFAULT.log(__traits(identifier, Args[i]),": ", Args[i]);
    };
}

void loglnInfo(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    Console.DEFAULT.info(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction);
}


void loglnWarn(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    Console.DEFAULT.warn(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction);
}


void loglnError(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    Console.DEFAULT.error(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction);
}


void loglnImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__){logln(s,f,fn,l);}
void loglnInfoImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__){loglnInfo(s,f,fn,l);}
void loglnWarnImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__){loglnWarn(s,f,fn,l);}
void loglnErrorImpl(string s, string f = __FILE__, string fn = __PRETTY_FUNCTION__, ulong l = __LINE__){loglnError(s,f,fn,l);}
void rawlogImpl(string str){Console.DEFAULT.log(str);}
void rawwarnImpl(string str){Console.DEFAULT.warn(str);}
void rawinfoImpl(string str){Console.DEFAULT.info(str);}
void rawerrorImpl(string str){Console.DEFAULT.error(str);}
void rawfatalImpl(string str){Console.DEFAULT.fatal(str);}

void rawlog(Args... )(Args a){Console.DEFAULT.log(a);}
void rawwarn(Args... )(Args a){Console.DEFAULT.warn(a);}
void rawinfo(Args... )(Args a){Console.DEFAULT.info(a);}
void rawerror(Args... )(Args a){Console.DEFAULT.error(a);}
void rawfatal(Args... )(Args a){Console.DEFAULT.fatal(a);}