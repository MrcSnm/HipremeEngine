module global_opts;

///Used on targets.wasm 
bool serverStarted;
bool appleClean;


import std.concurrency;
import commons;
private Tid serverTid;
void startServer()
{
    if(serverStarted) return;
    import serve;
    static void startTheServer()
    {
        hipengineCgiMain!(serveGameFiles)([], getHipPath("build", "wasm"));
    }
    serverStarted = true;
	serverTid = spawn(&startTheServer);
}

void exitServer()
{
    if(!serverStarted) return;
    import serve;
    serverStarted = false;
    serverTid = Tid.init;
    stopServer();   
}