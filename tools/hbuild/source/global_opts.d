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

void startServer(shared ushort* usingPort, shared string* usingHost)
{
    if(serverStarted) return;
    import server;
    import core.stdc.stdlib;
    serverStarted = true;
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
                try exitServer();
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
            exitServer();
            exit(0);
        }
        alias fn = extern(C) void function(int) nothrow @nogc;
        signal(SIGINT, cast(fn)&handleCtrlC);
    }

    s.wait;
}

void exitServer()
{
    if(!serverStarted) return;
    import core.stdc.stdlib;
    import server;
    serverStarted = false;
    serverThread = null;
    stopServer();
    exit(0);
}