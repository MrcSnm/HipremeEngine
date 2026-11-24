module backtraced;
version(Windows) version = UseBacktraced;
else version(Android) version = UseNullBacktraced;
else version(linux) version = UsePosixBacktraced;
else version(OSX) version = UsePosixBacktraced;
else version = UseNullBacktraced;

version(UseNullBacktraced)
void backtraced_Register() { }

version(UseBacktraced)
{
import core.demangle;

version (Windows)
{

    pragma(lib, "dbghelp.lib");
    import core.sys.windows.windef;
    import core.sys.windows.imagehlp;
    import core.sys.windows.winbase;
    import core.sys.windows.dbghelp;
    import core.stdc.stdlib : free, calloc;
    import core.stdc.stdio : fprintf, stderr;
    import core.stdc.string : memcpy, strncmp, strlen;

    struct SYMBOL_INFO
    {
        ULONG SizeOfStruct;
        ULONG TypeIndex;
        ULONG64[2] Reserved;
        ULONG Index;
        ULONG Size;
        ULONG64 ModBase;
        ULONG Flags;
        ULONG64 Value;
        ULONG64 Address;
        ULONG Register;
        ULONG Scope;
        ULONG Tag;
        ULONG NameLen;
        ULONG MaxNameLen;
        CHAR[1] Name;
    }

    extern (Windows) USHORT RtlCaptureStackBackTrace(ULONG FramesToSkip, ULONG FramesToCapture, PVOID* BackTrace, PULONG BackTraceHash);
    extern (Windows) BOOL SymFromAddr(HANDLE hProcess, DWORD64 Address, PDWORD64 Displacement, SYMBOL_INFO* Symbol);
    extern (Windows) BOOL SymGetLineFromAddr64(HANDLE hProcess, DWORD64 dwAddr, PDWORD pdwDisplacement, IMAGEHLP_LINEA64* line);

    version(DigitalMars)
    void printStackTrace()
    {
        import hip.util.string;
        enum MAX_DEPTH = 256;
        void*[MAX_DEPTH] stack;

        HANDLE process = GetCurrentProcess();
        ushort frames = RtlCaptureStackBackTrace(0, MAX_DEPTH, stack.ptr, null);
        SYMBOL_INFO* symbol = cast(SYMBOL_INFO*) calloc((SYMBOL_INFO.sizeof) + 256, 1);
        symbol.MaxNameLen = 255;
        symbol.SizeOfStruct = SYMBOL_INFO.sizeof;

        IMAGEHLP_LINEA64 line = void;
        line.SizeOfStruct = SYMBOL_INFO.sizeof;

        DWORD dwDisplacement;

        static int ends_with(const(char)* str, const(char)* suffix)
        {
            if (!str || !suffix)
                return 0;
            size_t lenstr = strlen(str);
            size_t lensuffix = strlen(suffix);
            if (lensuffix > lenstr)
                return 0;
            return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
        }

        for (uint i = 0; i < frames; i++)
        {
            SymFromAddr(process, cast(DWORD64)(stack[i]), null, symbol);
            SymGetLineFromAddr64(process, cast(DWORD64)(stack[i]), &dwDisplacement, &line);

            // auto f = frames - i - 1;
            char[] funcName = demangle(symbol.Name.ptr[0..symbol.NameLen]);
            auto fname = line.FileName;
            auto lnum = line.LineNumber;

                if (ends_with(fname, __FILE__))
                    continue; // skip trace from this module
                if(funcName.indexOf("_d_run_main2") != -1)
                    break;

            fprintf(stderr, "%s:%i - %.*s\n", fname, lnum, cast(int)funcName.length, funcName.ptr);
        }

        free(symbol);
    }
    extern (Windows) LONG TopLevelExceptionHandler(PEXCEPTION_POINTERS pExceptionInfo)
    {
        import hip.util.system;
        enum NullPointerMessage = 0xC0000005;
        import hip.util.conv;

        string msg;
        switch(pExceptionInfo.ExceptionRecord.ExceptionCode)
        {
            case NullPointerMessage:
                msg = "Caught NullPointerException (0xC0000005)";
                break;
            default:
                msg = "Caught Exception (0x"~toHex(pExceptionInfo.ExceptionRecord.ExceptionCode)~")";
                break;
        }

        version(DigitalMars) ///DMD can't print the stack trace.
        {
            fprintf(stderr, "%.*s\n", cast(int)msg.length, msg.ptr);
            // Dump the hidden verbose trace so the last engine steps survive the crash.
            import hip.console.console : Console;
            if(Console.DEFAULT !is null)
                Console.DEFAULT.dumpLogs();
            printStackTrace();
        }
        else
            throw new Exception(msg);
        return EXCEPTION_CONTINUE_SEARCH;
    }

    void backtraced_Register()
    {
        SymInitialize(GetCurrentProcess(), null, true);
        SymSetOptions(SYMOPT_LOAD_LINES | SYMOPT_DEBUG);
        SetUnhandledExceptionFilter(&TopLevelExceptionHandler);
    }
}
}

version(UsePosixBacktraced)
{
    import core.stdc.signal : SIG_DFL, signal, raise;
    import core.stdc.stdio : fprintf, fflush, stderr;
    import core.stdc.stdlib : exit;
    import core.sys.posix.signal : SIGSEGV, SIGBUS, SIGFPE, SIGILL, SIGABRT, SIGUSR1;
    import core.sys.posix.unistd : _exit;

    version (linux)
        import core.sys.linux.execinfo : backtrace;
    else version (OSX)
        import core.sys.darwin.execinfo : backtrace;

    private __gshared bool handlingCrash;

    void backtraced_Register()
    {
        signal(SIGSEGV, &handler);
        signal(SIGBUS, &handler);
        signal(SIGFPE, &handler);
        signal(SIGILL, &handler);
        signal(SIGABRT, &handler);
        signal(SIGUSR1, &handler);
    }

    private extern(C) void handler(int sig) nothrow @nogc
    {
        if (handlingCrash)
            _exit(1);
        handlingCrash = true;

        enum MAX_DEPTH = 64;

        string signal_string;
        switch (sig)
        {
            case SIGSEGV: signal_string = "SIGSEGV"; break;
            case SIGBUS:  signal_string = "SIGBUS";  break;
            case SIGFPE:  signal_string = "SIGFPE";  break;
            case SIGILL:  signal_string = "SIGILL";  break;
            case SIGABRT: signal_string = "SIGABRT"; break;
            case SIGUSR1: signal_string = "SIGUSR1"; break;
            default:      signal_string = "unknown"; break;
        }

        fprintf(stderr, "-------------------------------------------------------------------+\n");
        fprintf(stderr, "Received signal '%s' (%d)\n", signal_string.ptr, sig);
        fprintf(stderr, "-------------------------------------------------------------------+\n");

        void*[MAX_DEPTH] trace;
        int stack_depth = backtrace(cast(void**)&trace[0], MAX_DEPTH);
        fprintf(stderr, "backtrace: %d\n", stack_depth);

        printBacktrace(trace[0 .. stack_depth]);

        fflush(stderr);

        signal(sig, SIG_DFL);
        version (linux)
            exit(-1);
        else version (OSX)
            raise(sig);
    }

    version (linux)
    {
        import core.demangle : demangle;
        import core.stdc.string : strlen, memcpy;
        import core.stdc.stdio : sprintf, fgets, FILE;
        import core.sys.posix.unistd : readlink;
        import core.sys.posix.stdio : popen, pclose;
        import core.sys.linux.execinfo : backtrace_symbols;
        import core.sys.linux.dlfcn : Dl_info, RTLD_DL_LINKMAP, dladdr1;
        import core.sys.linux.link : link_map;

        private @trusted @nogc nothrow
        const(char)[] demangleInto(const(char)[] mangled, char[] buffer)
        {
            alias DemangleFn = char[] function(const(char)[], char[], void*) pure nothrow @safe @nogc;
            return (cast(DemangleFn)&demangle)(mangled, buffer, null);
        }

        private void printBacktrace(void*[] trace) nothrow @nogc
        {
            enum BUF_SIZE = 1024;
            char[BUF_SIZE] syscom = 0;
            char[BUF_SIZE] my_exe = 0;
            char[BUF_SIZE] output = 0;

            readlink("/proc/self/exe", &my_exe[0], BUF_SIZE);
            fprintf(stderr, "executable: %s\n", &my_exe[0]);

            char** strings = backtrace_symbols(cast(const(void*)*)&trace[0], cast(int)trace.length);

            for (size_t i = 2; i < trace.length; ++i)
            {
                auto line = strings[i];
                auto len = strlen(line);
                bool insideParenthesis;
                bool hasSymbol;
                int startParenthesis;
                int endParenthesis;
                for (int j = 0; j < len; j++)
                {
                    if (!insideParenthesis && line[j] == '(')
                    {
                        insideParenthesis = true;
                        startParenthesis = j + 1;
                    }
                    else if (insideParenthesis && line[j] == ')')
                    {
                        insideParenthesis = false;
                        endParenthesis = j;
                        hasSymbol = true;
                    }
                }
                auto addr = convertToVma(cast(size_t) trace[i]);

                sprintf(&syscom[0], "addr2line -e %s %p", &my_exe[0], addr);
                FILE* fp = popen(&syscom[0], "r");

                output[0] = 0;
                fgets(&output[0], output.length, fp);
                pclose(fp);

                auto getLen = strlen(output.ptr);
                if (getLen > 0)
                    output[getLen - 1] = ' ';
                fprintf(stderr, "%s", output.ptr);

                if (hasSymbol && endParenthesis > startParenthesis)
                {
                    char[256] func = void;
                    auto funcLen = endParenthesis - startParenthesis;
                    if (funcLen > func.length)
                        funcLen = func.length;
                    memcpy(func.ptr, &line[startParenthesis], funcLen);

                    char[BUF_SIZE] demangled = void;
                    auto funcName = demangleInto(func[0 .. funcLen], demangled[]);
                    if (funcName.ptr !is demangled.ptr)
                        funcName = func[0 .. funcLen];
                    fprintf(stderr, "%.*s", cast(int)funcName.length, funcName.ptr);
                }
                fprintf(stderr, "\n");
            }
        }

        private size_t convertToVma(size_t addr) nothrow @nogc
        {
            Dl_info info;
            link_map* link_map;
            dladdr1(cast(void*) addr, &info, cast(void**)&link_map, RTLD_DL_LINKMAP);
            return addr - link_map.l_addr;
        }
    }
    else version (OSX)
    {
        import core.sys.darwin.execinfo : backtrace_symbols_fd;
        import core.sys.posix.unistd : STDERR_FILENO;

        private void printBacktrace(void*[] trace) nothrow @nogc
        {
            int start = trace.length > 2 ? 2 : 0;
            backtrace_symbols_fd(cast(const(void*)*)&trace[start], cast(int)(trace.length - start), STDERR_FILENO);
            fprintf(stderr, "Symbolize with: atos -o <executable> -arch <arch> <address> ...\n");
        }
    }
}
