module hip.concurrency.mutex;
import hip.config.opts;





static if(HipConcurrency)
class DebugMutex
{
    import core.sync.mutex : Mutex;
    import core.thread;
    
    private string lastFileLock;
    private size_t lastLineLock;
    private ThreadID lastID;

    private string lastFileUnlock;
    private size_t lastLineUnlock;

    private Mutex mtx;

    private ThreadID mainThreadId;

    this(ThreadID mainId = ThreadID.init)
    {
        this.mainThreadId = mainId;
        mtx = new Mutex();
    }
    void lock(string file = __FILE__, size_t line = __LINE__)
    {
        import hip.concurrency.internal;
        if(lastLineLock == 0)
        {
            lastLineUnlock = 0;
            lastFileUnlock = null;

            lastFileLock = file;
            lastLineLock = line;
            lastID = thisThreadID;
        }
        else
        {
            version(Desktop)
            {
                import hip.console.log;
                import hip.util.conv:to;
                string last = (lastID == mainThreadId ? "Main " : "") ~ "Thread("~to!string(lastID)~")";
                string curr = (thisThreadID == mainThreadId ? "Main " : "") ~ "Thread("~to!string(thisThreadID)~")";


                logln("Tried to lock a locked mutex at ", file, ":", line,
                "\n\tLast locked at ", lastFileLock, ":",lastLineLock, " ", last, 
                " Current Thread is ",curr);
            }
        }
        mtx.lock();
    }
    void unlock(string file = __FILE__, size_t line = __LINE__)
    {
        version(Desktop)
        {
            if(lastLineLock == 0)
            {
                import hip.concurrency.internal;
                import hip.console.log;
                import hip.util.conv:to;
                string last = (lastID == mainThreadId ? "Main " : "") ~ "Thread("~to!string(lastID)~")";
                string curr = (thisThreadID == mainThreadId ? "Main " : "") ~ "Thread("~to!string(thisThreadID)~")";
                
                logln(
                    "Tried to unlock an unlocked mutex at ", file, ":", line, 
                    "\n\tLast unlocked at ",  lastFileUnlock, ":",lastLineUnlock, " ", last,
                    " Current Thread is ",curr
                );
                // throw new Error("Tried to unlock an unlocked mutex");
            }
        }
        lastLineUnlock = line;
        lastFileUnlock = file;
        lastFileLock = null;
        lastLineLock = 0;
        mtx.unlock();
    }

}
else
class DebugMutex
{
    this(ulong id = 0){}
    final void lock(){}
    final void unlock(){}
}