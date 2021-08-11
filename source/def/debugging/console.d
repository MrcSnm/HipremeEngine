module def.debugging.console;
import bind.external;
private import global.opts;
import util.reflection : isLiteral;
import std.conv:to;
import std.format : format;
import std.string : toStringz;
import implementations.imgui.imgui_debug : InterfaceImplementation;

static enum androidTag = "HipremeEngine";
enum GUI_CONSOLE = true;

void function(string toPrint) _log;
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
    import bindbc.cimgui;
    Console c = cast(Console)console;
    
    igBegin(c.name.toStringz, &c.isShowing, 0);
    foreach_reverse(line; c.lines)
    {
        igText(line.toStringz);
    }
    igEnd();
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
    static Console DEFAULT;
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
                break;
            case ANDROID:
                _log = function(string s)
                {
                    version(Android) 
                    {
                        import jni.helper.androidlog; 
                        aloge(androidTag, s.ptr);
                    }
                };
                break;
            case UWP:
                _log = printFunc;
                break;
            case DEFAULT:
            case DESKTOP:
            default:
                _log = function(string s)
                {
                    import std.stdio;
                    writeln(s);
                };
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

    private void _defaultLog(ref string log)
    {
        log~= indentation;
        lines~= log;
        if(lines.length > maxLines)
            lines = lines[1..$];
        if(_log != null)
            _log(log);
    }
    
    void log(alias fmt, Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = _format!(fmt, a);
            _defaultLog(toLog);
        }
    }
    void log(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = "";
            foreach(_a; a) toLog~= to!string(_a);
            _defaultLog(toLog);
        }
    }

    void warn(alias fmt, Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = _format!(fmt, a);
            _defaultLog(toLog);
        }
        
    }
    void warn(Args...)(Args a)
    {
        static if(!HE_NO_LOG && !HE_ERR_ONLY)
        {
            string toLog = _format!(fmt, a);
            _defaultLog(toLog);
        }
    }
    void error(alias fmt, Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            string toLog = _format!(fmt, a);
            _defaultLog(toLog);
        }
        
    }
    void error(Args...)(Args a)
    {
        static if(!HE_NO_LOG)
        {
            string toLog = _format!(fmt, a);
            _defaultLog(toLog);
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