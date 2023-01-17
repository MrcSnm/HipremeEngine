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

private string _formatPrettyFunction(string f)
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
        Console.DEFAULT.hipLog("HIP: ", a, " [[", file, ":", line, "]]\n");
    else
        Console.DEFAULT.hipLog("HIP: ", a, "\n");
}


void logln(Args...)(Args a, string file = __FILE__,
string func = __PRETTY_FUNCTION__,
ulong line = __LINE__)
{
    Console.DEFAULT.log(a, "\n\t\t", file, ":", line, " at ", func._formatPrettyFunction);
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


void rawlog(Args... )(Args a){Console.DEFAULT.log(a);}
void rawwarn(Args... )(Args a){Console.DEFAULT.warn(a);}
void rawinfo(Args... )(Args a){Console.DEFAULT.info(a);}
void rawerror(Args... )(Args a){Console.DEFAULT.error(a);}
void rawfatal(Args... )(Args a){Console.DEFAULT.fatal(a);}