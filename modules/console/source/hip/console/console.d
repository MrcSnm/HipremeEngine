/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.console.console;
import hip.config.opts;
import hip.util.reflection : isLiteral;
import hip.util.conv:to;
import hip.util.string : toStringz, String;
import hip.debugging.gui:InterfaceImplementation;
import hip.util.format;


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

    private uint logCounter = 0;
    
    string indentation;
    int indentationCount;
    int maxLines = 255;
    int indentationSize = 4; //? Don't know if it should be used instead of \t
    bool useTab = true;
    bool isShowing = true;
    static __gshared Console DEFAULT;
    static void initialize()
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
                    import hip.jni.helper.androidlog; 
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
                    import core.stdc.stdio:printf, fflush, stdout;
                    printf("%.*s\n", cast(int)s.length, s.ptr);
                    fflush(stdout);
                };
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
        }
    }
    private this(string consoleName, ushort id)
    {
        lines = new string[](maxLines);
        name = consoleName;
        this.id = id;
    }

    this(string consoleName)
    {
        lines = new string[](maxLines);
        name = consoleName;
        id = idCount;
        idCount++;
    }

    private void _formatLog(ref string log)
    {
        log~= indentation;
        lines[logCounter++] = log;
        if(logCounter > maxLines)
        {
            lines = lines[1..$];
            logCounter--;
        }
    }
    private String formatArguments(Args...)(Args a)
    {
        String toLog = String(a);
        // _formatLog(toLog);
        return toLog;
    }
    
    
    void log(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            //mtx.lock();
            _log(formatArguments(a).toString);
            //mtx.unlock();
        }
    }
    void info(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            //mtx.lock();
            _log("INFO: " ~ formatArguments(a).toString);
            //mtx.unlock();
        }
    }

    void warn(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            //mtx.lock();
            _warn("WARNING: " ~ formatArguments(a).toString);
            //mtx.unlock();
        }
    }
    
    void error(Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            //mtx.lock();
            _err("ERROR: " ~ formatArguments(a).toString);
            //mtx.unlock();
        }
    }
  
    void fatal(Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            //mtx.lock();
            _fatal("FATAL ERROR: " ~formatArguments(a).toString);
            //mtx.unlock();
        }
    }

    void indent()
    {
        //mtx.lock();
        if(useTab)
            indentation~= "\t";
        else
            for(int i = 0; i < indentationSize; i++)
                indentation~= " ";
        indentationCount++;
        //mtx.unlock();
    }

    void unindent()
    {
        //mtx.lock();
        if(useTab)
            indentation = indentation[1..$];
        else
            indentation = indentation[indentationSize..$];
        indentationCount--;
        //mtx.unlock();
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