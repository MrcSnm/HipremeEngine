module core.sync.mutex;

class Mutex
{
    @nogc:
    void lock(){}
    void unlock(){}
    void lock_nothrow() nothrow{}
    void unlock_nothrow() nothrow{}
    ~this() nothrow {}
}