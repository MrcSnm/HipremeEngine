module hip.concurrency.internal;
import hip.config.opts;


version(Windows) extern(Windows) @nogc nothrow @trusted uint GetCurrentThreadId();
package @property auto thisThreadID() @trusted nothrow @nogc //TODO: @safe
{
    static if(!HipConcurrency)
    {
        return 0;
    }
    else
    {
        version (Windows)
        {
            return GetCurrentThreadId();
        }
        else
        version (Posix)
        {
            import core.sys.posix.pthread : pthread_self;
            return pthread_self();
        }
    }
}