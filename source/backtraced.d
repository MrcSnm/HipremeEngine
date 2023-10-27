module backtraced;

debug:
import core.demangle;
import std.algorithm.searching;

version (Windows)
{

    pragma(lib, "dbghelp.lib");
    import core.sys.windows.windows;
    import core.sys.windows.dbghelp;
    import core.stdc.stdlib : free, calloc;
    import core.stdc.stdio : fprintf, stderr;
    import core.stdc.string : memcpy, strncmp, strlen;
    import std.string;

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


    debug void printStackTrace()
    {
        // enum MAX_DEPTH = 256;
        // void*[MAX_DEPTH] stack;

        // HANDLE process = GetCurrentProcess();
        // ushort frames = RtlCaptureStackBackTrace(0, MAX_DEPTH, stack.ptr, null);
        // SYMBOL_INFO* symbol = cast(SYMBOL_INFO*) calloc((SYMBOL_INFO.sizeof) + 256 * char.sizeof, 1);
        // symbol.MaxNameLen = 255;
        // symbol.SizeOfStruct = SYMBOL_INFO.sizeof;

        // IMAGEHLP_LINEA64 line = void;
        // line.SizeOfStruct = SYMBOL_INFO.sizeof;

        // DWORD dwDisplacement;
        // 
        // static int ends_with(const(char)* str, const(char)* suffix)
        // {
        //     if (!str || !suffix)
        //         return 0;
        //     size_t lenstr = strlen(str);
        //     size_t lensuffix = strlen(suffix);
        //     if (lensuffix > lenstr)
        //         return 0;
        //     return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
        // }

        // for (uint i = 0; i < frames; i++)
        // {
        //     SymFromAddr(process, cast(DWORD64)(stack[i]), null, symbol);
        //     SymGetLineFromAddr64(process, cast(DWORD64)(stack[i]), &dwDisplacement, &line);

        //     // auto f = frames - i - 1;
        //     char[] funcName = demangle(symbol.Name.ptr[0..symbol.NameLen]);
        //     auto fname = line.FileName;
        //     auto lnum = line.LineNumber;

        //     if (ends_with(fname, __FILE__) || funcName.canFind("rt.dmain2._d_run_main2"))
        //         continue; // skip trace from this module

        //     fprintf(stderr, "%s:%i - %.*s\n", fname, lnum, cast(int)funcName.length, funcName.ptr);
        // }
        
        // free(symbol);
    }
    extern (Windows) LONG TopLevelExceptionHandler(PEXCEPTION_POINTERS pExceptionInfo)
    {
        debug
        {
            import hip.util.conv;
            throw new Exception("Caught Exception (0x"~toHex(pExceptionInfo.ExceptionRecord.ExceptionCode)~")");
        }
        return EXCEPTION_CONTINUE_SEARCH;
    }

    extern (C) export void backtraced_Register()
    {
        debug
        {
            SymInitialize(GetCurrentProcess(), null, true);
            SymSetOptions(SYMOPT_LOAD_LINES | SYMOPT_DEBUG);
            SetUnhandledExceptionFilter(&TopLevelExceptionHandler);
        }
    }
}

version (Posix)
{
    import core.stdc.signal : SIGSEGV, SIGFPE, SIGILL, SIGABRT, signal;
    import core.stdc.stdlib : free, exit;
    import core.stdc.string : strlen, memcpy;
    import core.stdc.stdio : fprintf, stderr, sprintf, fgets, fclose, FILE;
    import core.sys.posix.unistd : STDERR_FILENO, readlink;
    import core.sys.posix.signal : SIGUSR1;
    import core.sys.posix.stdio : popen, pclose;
    import core.sys.linux.execinfo : backtrace, backtrace_symbols;
    import core.sys.linux.dlfcn : dladdr, dladdr1, Dl_info, RTLD_DL_LINKMAP;
    import core.sys.linux.link : link_map;
    import core.demangle : demangle;

    extern (C) export void backtraced_Register()
    {
        signal(SIGSEGV, &handler);
        signal(SIGUSR1, &handler);
    }

    // TODO: clean this mess
    // TODO: use core.demangle instead
    extern (C) void handler(int sig) nothrow @nogc
    {
        enum MAX_DEPTH = 32;

        string signal_string;
        switch (sig)
        {
        case SIGSEGV:
            signal_string = "SIGSEGV";
            break;
        case SIGFPE:
            signal_string = "SIGFPE";
            break;
        case SIGILL:
            signal_string = "SIGILL";
            break;
        case SIGABRT:
            signal_string = "SIGABRT";
            break;
        default:
            signal_string = "unknown";
            break;
        }

        fprintf(stderr, "-------------------------------------------------------------------+\r\n");
        fprintf(stderr, "Received signal '%s' (%d)\r\n", signal_string.ptr, sig);
        fprintf(stderr, "-------------------------------------------------------------------+\r\n");

        void*[MAX_DEPTH] trace;
        int stack_depth = backtrace(&trace[0], MAX_DEPTH);
        char** strings = backtrace_symbols(&trace[0], stack_depth);

        enum BUF_SIZE = 1024;
        char[BUF_SIZE] syscom = 0;
        char[BUF_SIZE] my_exe = 0;
        char[BUF_SIZE] output = 0;

        readlink("/proc/self/exe", &my_exe[0], BUF_SIZE);

        fprintf(stderr, "executable: %s\n", &my_exe[0]);
        fprintf(stderr, "backtrace: %i\n", stack_depth);

        for (auto i = 2; i < stack_depth; ++i)
        {
            auto line = strings[i];
            auto len = strlen(line);
            bool insideParenthesis;
            int startParenthesis;
            int endParenthesis;
            for (int j = 0; j < len; j++)
            {
                // ()
                if (!insideParenthesis && line[j] == '(')
                {
                    insideParenthesis = true;
                    startParenthesis = j + 1;
                }
                else if (insideParenthesis && line[j] == ')')
                {
                    insideParenthesis = false;
                    endParenthesis = j;
                }
            }
            auto addr = convert_to_vma(cast(size_t) trace[i]);
            FILE* fp;

            auto locLen = sprintf(&syscom[0], "addr2line -e %s %p | ddemangle", &my_exe[0], addr);
            fp = popen(&syscom[0], "r");

            auto loc = fgets(&output[0], output.length, fp);
            fclose(fp);

            // printf("loc: %s\n", loc);

            auto getLen = strlen(output.ptr);

            char[256] func = 0;
            memcpy(func.ptr, &line[startParenthesis], (endParenthesis - startParenthesis));
            sprintf(&syscom[0], "echo '%s' | ddemangle", func.ptr);
            fp = popen(&syscom[0], "r");

            output[getLen - 1] = ' '; // strip new line
            auto locD = fgets(&output[getLen], cast(int)(output.length - getLen), fp);
            fclose(fp);

            fprintf(stderr, "%s", output.ptr);
        }
        exit(-1);
    }

    // https://stackoverflow.com/questions/56046062/linux-addr2line-command-returns-0/63856113#63856113
    size_t convert_to_vma(size_t addr) nothrow @nogc
    {
        Dl_info info;
        link_map* link_map;
        dladdr1(cast(void*) addr, &info, cast(void**)&link_map, RTLD_DL_LINKMAP);
        return addr - link_map.l_addr;
    }
}