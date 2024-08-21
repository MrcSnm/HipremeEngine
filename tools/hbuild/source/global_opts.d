module global_opts;

///Used on targets.wasm 
bool serverStarted;
bool appleClean;


import std.concurrency;
import core.sync.semaphore;
import commons;
private Tid serverTid;

shared ushort gameServerPort;

void startServer(shared ushort* usingPort)
{
    if(serverStarted) return;
    import serve;
    static void startTheServer(shared ushort* usingPort, shared Semaphore sem)
    {
        hipengineCgiMain!(serveGameFiles)([], getHipPath("build", "wasm"), usingPort, sem);
    }
    serverStarted = true;

    Semaphore s = new Semaphore();
	serverTid = spawn(&startTheServer, usingPort, cast(shared)s);
    s.wait;


}

void exitServer()
{
    if(!serverStarted) return;
    import serve;
    serverStarted = false;
    serverTid = Tid.init;
    stopServer();   
}