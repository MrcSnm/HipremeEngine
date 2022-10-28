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


void rawlog(Args... )(Args a){Console.DEFAULT.log(a);}
void rawinfo(Args... )(Args a){Console.DEFAULT.info(a);}
void rawerror(Args... )(Args a){Console.DEFAULT.error(a);}
void rawfatal(Args... )(Args a){Console.DEFAULT.fatal(a);}