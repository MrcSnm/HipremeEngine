module global_opts;

///Used on targets.wasm 
bool serverStarted;
bool appleClean;


import core.thread;
import core.sync.semaphore;
import commons;
private Thread serverThread;

shared ushort gameServerPort;
shared string gameServerHost;


private Terminal* term;

void startServer(shared ushort* usingPort, shared string* usingHost, ref Terminal t)
{
    if(serverStarted) return;
    import server;
    import core.stdc.stdlib;
    serverStarted = true;
    term = &t;
    Semaphore s = new Semaphore();
	serverThread = new Thread(()
    {
        hipengineStartServer([], usingPort, usingHost, getHipPath("build", "wasm"), cast(shared)s);
    }).start();


    version(Windows)
    {
        import core.sys.windows.windef; // Windows API bindings
        import core.sys.windows.wincon; // Windows API bindings

        static extern(Windows) BOOL handleCtrlC(DWORD ctrlType) nothrow
        {
            if (ctrlType == CTRL_C_EVENT) // CTRL+C signal
            {
                try 
                {
                    exitServer(*term);
                    destroy(*term);
                }
                catch(Exception e){}
                exit(0);
            }
            return FALSE;
        }

        if (!SetConsoleCtrlHandler(&handleCtrlC, TRUE))
        {
            throw new Exception("Failed to register CTRL+C handler.");
        }

    }
    else version(Posix)
    {
        import core.sys.posix.signal;
        static extern(C) void handleCtrlC(int signum)
        {
            exitServer(*term);
            destroy(*term);
            exit(0);
        }
        alias fn = extern(C) void function(int) nothrow @nogc;
        signal(SIGINT, cast(fn)&handleCtrlC);
    }

    s.wait;
}

void exitServer(ref Terminal t)
{
    if(!serverStarted) 
        return;
    import std.conv: to;
    import server;
    t.writelnHighlighted("Shutting down the server at ", cast()gameServerHost, ":", cast()gameServerPort.to!string);
    serverThread = null;
    serverStarted = false;
    stopServer();
}