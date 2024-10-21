module hip.concurrency.volatile;
import hip.config.opts;


static if(HipConcurrency):
///Tries to implement a `volatile` java style
struct Volatile(T)
{
    import core.volatile;
    private T value;

    auto synchronized opAssign(T)(T value)
    {    
        volatileStore(&this.value, value);
        return value;
    }
    private @property synchronized T v(){return volatileLoad(value);}
    alias v this;   
}