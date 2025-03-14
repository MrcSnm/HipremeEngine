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
import hip.util.string;
import hip.util.format;

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
ulong line = __LINE__)
{
    import hip.config.opts;
    static if(HIP_TRACK_HIPLOG)
        Console.DEFAULT.hipLog(BigString("HIP: ", a, " [[", file, ":", line, "]]").toString);
    else
        Console.DEFAULT.hipLog(BigString("HIP: ", a).toString);
}


void logln(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__) @nogc
{

    Console.DEFAULT.log(BigString(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction).toString);
}


void loglnInfo(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    Console.DEFAULT.info(BigString(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction).toString);
}


void loglnWarn(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    Console.DEFAULT.warn(BigString(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction).toString);
}


void loglnError(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    Console.DEFAULT.error(BigString(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction).toString);
}

void rawlog(string msg){Console.DEFAULT.log(msg);}
void rawwarn(string msg){Console.DEFAULT.warn(msg);}
void rawinfo(string msg){Console.DEFAULT.info(msg);}
void rawerror(string msg){Console.DEFAULT.error(msg);}
void rawfatal(string msg){Console.DEFAULT.fatal(msg);}