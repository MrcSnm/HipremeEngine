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
import hip.util.string : BigString, String;
import hip.util.format;


enum Platforms
{
    default_,
    desktop,
    android,
    uwp,
    wasm,
    psvita,
    appleos,
    nintendo_switch,
    null_
}
static enum androidTag = "HipremeEngine";
enum GUI_CONSOLE = true;

///If it is inside thread local storage, then, it won't work being called from another thread
@nogc __gshared void function(string toPrint) _log;
@nogc __gshared void function(string toPrint) _info;
@nogc __gshared void function(string toPrint) _warn;
@nogc __gshared void function(string toPrint) _err;
@nogc __gshared void function(string toPrint) _fatal;
version(PSVita) extern(C) void hipVitaPrint(uint length, const(char)* str) @nogc;
version(NintendoSwitch)
{
    extern(System) void close(int);
    extern(System) void socketExit();
    extern(System) int socketInitialize(void*);
    /// Initalize the socket driver using the default configuration.
    int socketInitializeDefault()
    {
        return socketInitialize(null);
    }

    /**
    * @brief Connects to the nxlink host, setting up an output stream.
    * @param[in] redirStdout Whether to redirect stdout to nxlink output.
    * @param[in] redirStderr Whether to redirect stderr to nxlink output.
    * @return Socket fd on success, negative number on failure.
    * @note The socket should be closed with close() during application cleanup.
    */
    extern(System) int nxlinkConnectToHost(bool redirStdout, bool redirStderr);

    /// Same as \ref nxlinkConnectToHost but redirecting both stdout/stderr.
    int nxlinkStdio() {
        return nxlinkConnectToHost(true, true);
    }

    /// Same as \ref nxlinkConnectToHost but redirecting only stderr.
    int nxlinkStdioForDebug() {
        return nxlinkConnectToHost(false, true);
    }

}

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
private struct TextColor
{
    @nogc:
    version(WindowsNative)
        static void* windowsConsole;
    this(WindowsConsoleColors color)
    {
        version(WindowsNative){SetConsoleTextAttribute(windowsConsole, color);}
    }
    ~this()
    {
        version(WindowsNative){SetConsoleTextAttribute(windowsConsole, WindowsConsoleColors.white);}
    }
}


class Console
{
    string name;
    string[] lines;

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
    

    alias printFuncT = @nogc void function(string);
    version(NintendoSwitch)
    {
        __gshared int nxLinkSock = -1;
        private static void deInitNxLink()
        {
            if(nxLinkSock >= 0)
            {
                close(nxLinkSock);
                socketExit();
                nxLinkSock = -1;
            }
        }
    }
    static void install(Platforms p = Platforms.default_, printFuncT printFunc = null)
    {
        DEFAULT = new Console("Output", 99);
        version(WindowsNative)
        {
            import core.sys.windows.winbase;
            import core.sys.windows.wincon;
            if(TextColor.windowsConsole is null)
                TextColor.windowsConsole = GetStdHandle(STD_OUTPUT_HANDLE);
        }
        switch(p) with(Platforms)
        {
            case null_:
                _log = function(string s){};
                _info = _log;
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
            case android:
                version(Android)
                {
                    import hip.jni.helper.androidlog; 
                    alias fnType = @nogc void function(string);
                    _log   = cast(fnType)function(string s){alogi(androidTag, "%.*s", s.length, s.ptr);};
                    _info = _log;
                    _warn  = cast(fnType)function(string s){alogw(androidTag, "%.*s", s.length, s.ptr);};
                    _err   = cast(fnType)function(string s){aloge(androidTag, "%.*s", s.length, s.ptr);};
                    _fatal = cast(fnType)function(string s){alogf(androidTag, "%.*s", s.length, s.ptr);};
                }
                break;  
            case psvita:
            {
                version(PSVita)
                {
                    _log = function(string s){hipVitaPrint(s.length, s.ptr);};
                    _info = _warn = _err = _fatal = _log;
                }
                break;
            }
            case wasm:
                version(WebAssembly)
                {
                    import arsd.webassembly;
                    import std.stdio;
                    alias nogcfn = @nogc void function(string s);
                    _log = cast(nogcfn)function(string s){writeln(s);};
                    _fatal = _err = cast(nogcfn)function(string s){eval(q{console.error.apply(null, arguments)}, s);};
                    _warn = cast(nogcfn)function(string s){eval(q{console.warn.apply(null, arguments)}, s);};
                    _info = cast(nogcfn)function(string s){eval(q{console.info.apply(null, arguments)}, s);};
                }
                break;
            case uwp:
                _log = printFunc;
                _info = _log;
                _warn = _log;
                _err = _log;
                _fatal = _err;
                break;
            case nintendo_switch:
                version(NintendoSwitch)
                {
                    if(socketInitializeDefault() != 0)
                        throw new Error("No initialization on switch console.");
                    nxLinkSock = nxlinkStdio();
                    if(nxLinkSock >= 0)
                    {
                        import core.stdc.stdio;
                        printf("Hipreme Engine: Connected to Nintendo Switch NXLink.\n");
                    }
                    else
                        deInitNxLink();
                }
                goto default;
            case default_:
            case appleos:
            case desktop:
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
                        else version(NintendoSwitch){}
                        else fflush(stdout);
                    }
                };
                _info = function(string s)
                {
                    with(TextColor(WindowsConsoleColors.blue)) _log(s);
                };
                _warn = function(string s)
                {
                    with(TextColor(WindowsConsoleColors.yellow)) _log(s);
                };
                _err = function(string s)
                {
                    with(TextColor(WindowsConsoleColors.red)) _log(s);
                };
                _fatal = function(string s)
                {
                    with(TextColor(WindowsConsoleColors.pink)) _log(s);
                };
                break;
            }
        }
    }
    private this(string consoleName, ushort id)
    {
        lines = new string[maxLines];
        name = consoleName;
        this.id = id;
    }

    this(string consoleName)
    {
        lines = new string[maxLines];
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
    void hipLog(string msg)
    {
        lines~= msg;
        _log(lines[$-1]);
    }
    
    
    void log(string msg) @nogc
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            //mtx.lock();
            _log(msg);
            //mtx.unlock();
        }
    }

    void logStr(string str)
    {
        _info(str);
    }
    void info(string msg)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            //mtx.lock();
            _info(BigString("INFO: ",  msg).toString);
            //mtx.unlock();
        }
    }

    void warn(string msg)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            //mtx.lock();
            _warn(BigString("WARNING: ",  msg).toString);
            //mtx.unlock();
        }
    }
    
    void error(string msg)
    {
        static if(!HE_NO_LOG)
        {
            //mtx.lock();
            _err(BigString("ERROR: ",  msg).toString);
            //mtx.unlock();
        }
    }
  
    void fatal(string msg)
    {
        static if(!HE_NO_LOG)
        {
            //mtx.lock();
            _fatal(BigString("FATAL ERROR: ", msg).toString);
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