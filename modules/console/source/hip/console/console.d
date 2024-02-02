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
import hip.util.format;


enum Platforms
{
    DEFAULT,
    DESKTOP,
    ANDROID,
    UWP,
    WASM,
    PSVITA,
    APPLEOS,
    NULL
}
static enum androidTag = "HipremeEngine";
enum GUI_CONSOLE = true;

///If it is inside thread local storage, then, it won't work being called from another thread
__gshared void function(string toPrint) _log;
__gshared void function(string toPrint) _info;
__gshared void function(string toPrint) _warn;
__gshared void function(string toPrint) _err;
__gshared void function(string toPrint) _fatal;
version(PSVita) extern(C) void hipVitaPrint(uint length, const(char)* str);

version(UWP){}
else version(Windows)
    version = WindowsNative;


enum WindowsConsoleColors
{
    lightBlue = 1,
    darkGreen = 2,
    darkTeal = 3,
    lightRed = 4,
    pink = 5,
    yellow = 6,
    lightGrey = 7,
    grey = 8,
    blue = 9,
    green = 10,
    lightTeal = 11,
    red = 12,
    white = 15
}

class Console
{
    string name;
    String[] lines;

    __gshared ushort idCount = 0;
    ushort id;

    private uint logCounter = 0;
    __gshared Console DEFAULT;
    
    string indentation;
    int indentationCount;
    int maxLines = 255;
    int indentationSize = 4; //? Don't know if it should be used instead of \t
    bool useTab = true;
    bool isShowing = true;
    

    static void install(Platforms p = Platforms.DEFAULT, void function(string) printFunc = null)
    {
        DEFAULT = new Console("Output", 99);
        version(WindowsNative)
        {
            import core.sys.windows.winbase;
            import core.sys.windows.wincon;
            static void* windowsConsole;
            if(windowsConsole is null)
                windowsConsole = GetStdHandle(STD_OUTPUT_HANDLE);
        }
        switch(p) with(Platforms)
        {
            case NULL:
                _log = function(string s){};
                _info = _log;
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
            case ANDROID:
                version(Android)
                {
                    import hip.jni.helper.androidlog; 
                    _log   = function(string s){alogi(androidTag, (s~"\0").ptr);};
                    _info = _log;
                    _warn  = function(string s){alogw(androidTag, (s~"\0").ptr);};
                    _err   = function(string s){aloge(androidTag, (s~"\0").ptr);};
                    _fatal = function(string s){alogf(androidTag, (s~"\0").ptr);};
                }
                break;  
            case PSVITA:
            {
                version(PSVita)
                {
                    _log = function(string s){hipVitaPrint(s.length, s.ptr);};
                    _info = _warn = _err = _fatal = _log;
                }
                break;
            }
            case WASM:
                version(WebAssembly)
                {
                    import arsd.webassembly;
                    _log = function(string s){eval(q{console.log.apply(null, arguments)}, s);};
                    _fatal = _err = function(string s){eval(q{console.error.apply(null, arguments)}, s);};
                    _warn = function(string s){eval(q{console.warn.apply(null, arguments)}, s);};
                    _info = function(string s){eval(q{console.info.apply(null, arguments)}, s);};
                }
                break;
            case UWP:
                _log = printFunc;
                _info = _log;
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
            case DEFAULT:
            case APPLEOS:
            case DESKTOP:
            default:
            {
                _log = function(string s)
                {
                    version(WebAssembly) assert(false, s);
                    else
                    {
                        import core.stdc.stdio;
                        printf("%.*s\n", cast(int)s.length, s.ptr);
                        version(PSVita){}
                        else version(CustomRuntimeTest){}
                        else fflush(stdout);
                    }
                };
                _info = function(string s)
                {
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.blue);}
                    _log(s);
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.white);}
                };
                _warn = function(string s)
                {
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.yellow);}
                    _log(s);
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.white);}
                };
                _err = function(string s)
                {
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.red);}
                    _log(s);
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.white);}
                };
                _fatal = function(string s)
                {
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.pink);}
                    _log(s);
                    version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.white);}
                };
                break;
            }
        }
    }
    private this(string consoleName, ushort id)
    {
        lines = new String[maxLines];
        name = consoleName;
        this.id = id;
    }

    this(string consoleName)
    {
        lines = new String[maxLines];
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
    
    void hipLog(Args...)(Args a)
    {
        lines~= formatArguments(a);
        _log(lines[$-1].toString);
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

    void logStr(string str)
    {
        _info(str);
    }
    void info(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            //mtx.lock();
            _info("INFO: " ~ formatArguments(a).toString);
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