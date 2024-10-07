module hip.concurrency.ring_buffer;
import hip.concurrency.volatile;
import hip.config.opts;

static if(HipConcurrency):

struct RingBuffer(T, uint Length)
{
    import hip.concurrency.volatile;
    @nogc:

    T[Length] data;
    private Volatile!uint writeCursor;
    private Volatile!uint readCursor;

    this()
    {
        this.writeCursor = 0;
        this.readCursor = 0;
    }

    void push(T data)
    {
        this.data[writeCursor] = data;
        writeCursor = (writeCursor+1) % Length;
    }
    ///It may read less than count if it is out of bounds
    immutable T[] read(uint count)
    {
        uint temp = readCursor;
        if(temp + count > Length)
        {
            readCursor = 0;
            return data[temp..Length];
        }
        readCursor = (temp+count)%Length;
        return data[temp .. count];
    }

    immutable T read()
    {
        uint temp = readCursor;
        immutable T ret = data[temp];
        readCursor = (temp+1)%Length;
        return ret;
    }

    void dispose()
    {
        data = null;
        length = 0;
        writeCursor = 0;
        readCursor = 0;
    }

    ~this()
    {
        dispose();
    }
}
