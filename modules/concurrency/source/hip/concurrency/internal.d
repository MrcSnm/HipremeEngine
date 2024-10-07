module hip.concurrency.internal;


version(Windows) extern(Windows) @nogc nothrow @trusted uint GetCurrentThreadId();
package @property auto thisThreadID() @trusted nothrow @nogc //TODO: @safe
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