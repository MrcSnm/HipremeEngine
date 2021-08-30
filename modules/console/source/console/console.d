/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module console.console;
import config.opts;
import util.reflection : isLiteral;
import std.conv:to;
import std.format : format;
import std.string : toStringz;
import debugging.gui:InterfaceImplementation;


enum Platforms
{
    DEFAULT,
    DESKTOP,
    ANDROID,
    UWP,
    NULL
}

static enum androidTag = "HipremeEngine";
enum GUI_CONSOLE = true;

///If it is inside thread local storage, then, it won't work being called from another thread
__gshared void function(string toPrint) _log;
__gshared void function(string toPrint) _warn;
__gshared void function(string toPrint) _err;
__gshared void function(string toPrint) _fatal;

static string _format(alias fmt, Args...)(Args a){return format!fmt(a);}
static string _format(Args...)(Args args)
{
    import std.traits : isIntegral, isBoolean;
    import std.conv : to;
    string ret = "";

    foreach(i, arg; args)
    {
        alias T = typeof(arg);
        static if(__traits(hasMember, arg, "toString")
        && is(typeof(arg.toString) == string))
            ret~= arg.toString;
        else
        {
            static if(is(T == string))
                ret~= arg;
            else
                ret~= to!string(arg);
        }
    }
    return ret;
}

@InterfaceImplementation(function(ref void* console)
{
    version(CIMGUI)
    {
        Console c = cast(Console)console;
        
        igBegin(c.name.toStringz, &c.isShowing, 0);
        foreach_reverse(line; c.lines)
        {
            igText(line.toStringz);
        }
        igEnd();
    }
}) class Console
{
    string name;
    string[] lines;

    static ushort idCount = 0;
    ushort id;
    
    string indentation;
    int indentationCount;
    int maxLines = 255;
    int indentationSize = 4; //? Don't know if it should be used instead of \t
    bool useTab = true;
    bool isShowing = true;
    static __gshared Console DEFAULT;
    static this()
    {
        DEFAULT = new Console("Output", 99);
    }

    static void install(Platforms p = Platforms.DEFAULT, void function(string) printFunc = null)
    {
        switch(p) with(Platforms)
        {
            case NULL:
                _log = function(string s){};
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
            case ANDROID:
                version(Android)
                {
                    import jni.helper.androidlog; 
                    _log   = function(string s){alogi(androidTag, (s~"\0").ptr);};
                    _warn  = function(string s){alogw(androidTag, (s~"\0").ptr);};
                    _err   = function(string s){aloge(androidTag, (s~"\0").ptr);};
                    _fatal = function(string s){alogf(androidTag, (s~"\0").ptr);};
                }
                break;
            case UWP:
                _log = printFunc;
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
            case DEFAULT:
            case DESKTOP:
            default:
                _log = function(string s)
                {
                    import std.stdio;
                    writeln(s);
                };
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
        }
    }
    private this(string consoleName, ushort id)
    {
        lines.reserve(255);
        name = consoleName;
        this.id = id;
    }

    this(string consoleName)
    {
        lines.reserve(255);
        name = consoleName;
        id = idCount;
        idCount++;
    }

    private void _formatLog(ref string log)
    {
        log~= indentation;
        lines~= log;
        if(lines.length > maxLines)
            lines = lines[1..$];
    }
    
    void log(alias fmt, Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = _format!(fmt, a);
            _log(toLog);
        }
    }
    void log(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = "";
            foreach(_a; a) toLog~= to!string(_a);
            _formatLog(toLog);
            _log(toLog);
        }
    }

    void warn(alias fmt, Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = _format!(fmt, a);
            _formatLog(toLog);
            _log(toLog);
        }
        
    }
    void warn(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = _format!(fmt, a);
            _formatLog(toLog);
            _log(toLog);
        }
    }
    void error(alias fmt, Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            string toLog = _format!(fmt, a);
            _formatLog(toLog);
            _err(toLog);
        }
        
    }
    void error(Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            string toLog;
            static foreach(arg; a)
                toLog~= to!string(arg);
            _formatLog(toLog);
            _err(toLog);
        }
    }
    void fatal(alias fmt, Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            string toLog = _format!(fmt, a);
            _formatLog(toLog);
            _fatal(toLog);
        }
        
    }
    void fatal(Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            string toLog;
            static foreach(arg; a)
                toLog~= to!string(arg);
            _formatLog(toLog);
            _fatal(toLog);
        }
    }

    void indent()
    {
        if(useTab)
            indentation~= "\t";
        else
            for(int i = 0; i < indentationSize; i++)
                indentation~= " ";
        indentationCount++;
    }

    void unindent()
    {
        if(useTab)
            indentation = indentation[1..$];
        else
            indentation = indentation[indentationSize..$];
        indentationCount--;
    }
}

void varPrint(A...)()
{
    foreach(i, arg; A)
    {
        static if(isLiteral!(A[i]))
        {
        	writeln(A[i]);
        }
        else
        {
            static if(is(typeof(A[i]) == string))
                writeln(typeof(A[i]).stringof ~ " ", A[i].stringof, " = ", "\"", A[i], "\"");
            else
    		    writeln(typeof(A[i]).stringof ~ " ", A[i].stringof, " = ", A[i]);
        }
    }
}