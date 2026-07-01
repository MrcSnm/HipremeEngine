module hip.util.allocator;

struct Allocator
{
    @nogc:
    private void[] function(Allocator* allocator, size_t amount, size_t alignment) allocFn;
    private void[] function(Allocator* allocator, void[] ptr, size_t amount, size_t alignment) reallocFn;
    private void function(Allocator* allocator, void[] ptr) freeFn;

    pragma(inline, true)
    {
        void[] alloc(size_t amount, size_t alignment = size_t.sizeof){return allocFn(&this, amount, alignment);}
        void[] realloc(void[] ptr, size_t amount, size_t alignment = size_t.sizeof){return reallocFn(&this, ptr, amount, alignment);}
        void free(void[] ptr){return freeFn(&this, ptr);}
    }
    void[] calloc(size_t count, size_t elementCount)
    {
        auto ret = alloc(count*elementCount);
        (cast(ubyte[])ret)[] = 0;
        return ret;
    }

    Allocator* ptr(){return &this;}
    alias ptr this;
}

struct FrameAllocator
{
    public Allocator allocator;
    private ubyte[] heap;
    private ptrdiff_t offset;

    alias allocator this;
    
    static FrameAllocator create(size_t heapSize)
    {
        FrameAllocator ret;
        ret.heap.length = heapSize;
        ret.allocator.allocFn = &allocImpl;
        ret.allocator.freeFn = &freeImpl;
        ret.allocator.reallocFn = &reallocImpl;
        return ret;
    }

    static void[] allocImpl(Allocator* alloc, size_t amount, size_t alignment) @nogc
    {
        FrameAllocator* f = cast(FrameAllocator*)alloc;
        if(f.offset+amount > f.heap.length)
            assert(false, "Please create a bigger frame allocator.");
        
        void[] ret = f.heap[f.offset..f.offset+amount];
        f.offset+= amount;
        return ret;
    }

    static void[] reallocImpl(Allocator* alloc, void[] ptr, size_t amount, size_t alignment) @nogc
    {
        if(ptr.length == amount)
            return ptr;
        FrameAllocator* f = cast(FrameAllocator*)alloc;

        if(f.heap.ptr + f.offset == ptr.ptr)
        {
            ptrdiff_t deltaSize = amount - cast(ptrdiff_t)ptr.length;
            if(deltaSize > 0 && f.offset + deltaSize > f.heap.length)
                assert(false, "Please create a bigger frame allocator.");

            f.offset+= deltaSize;
            return f.heap[0..amount];
        }
        else
        {
            if(amount < ptr.length)
                return ptr[0..amount];
            else
            {
                void[] ret = alloc.alloc(amount);
                if(ret.length)
                {
                    ret[0..ptr.length] = ptr[];
                    debug {
                        (cast(ubyte[])ptr)[0..$] = 0;
                    }
                }
                return ret;
            }
        }
        
    }

    static void freeImpl(Allocator* alloc, void[] ptr) @nogc
    {
        FrameAllocator* f = cast(FrameAllocator*)alloc;
        if(f.heap.ptr + f.offset == ptr.ptr)
            f.offset-= ptr.length;
        debug
        {
            (cast(ubyte[])ptr)[0..$] = 0;
        }
    }

    void reset()
    {
        // debug
        {
            heap[0..offset] = 0;
        }
        offset = 0; 
    }
}

struct MallocAllocator
{
    Allocator allocator;
    import core.stdc.stdlib;

    alias allocator this;

    static MallocAllocator create()
    {
        MallocAllocator ret;
        ret.allocator.allocFn = &allocImpl;
        ret.allocator.freeFn = &freeImpl;
        ret.allocator.reallocFn = &reallocImpl;
        return ret;
    }

    @nogc
    {
        static void[] allocImpl(Allocator* alloc, size_t amount, size_t alignment){return malloc(amount)[0..amount];}
        static void[] reallocImpl(Allocator* alloc, void[] ptr, size_t amount, size_t alignment){return realloc(ptr.ptr, amount)[0..amount];}
        static void freeImpl(Allocator* alloc, void[] ptr){ free(ptr.ptr);}
    }
}

__gshared MallocAllocator mallocAllocator = MallocAllocator.create();

version(none):
struct GCAllocator
{
    Allocator allocator;
    alias allocator this;
    import core.memory;

    static GCAllocator create()
    {
        GCAllocator ret;
        ret.allocator.allocFn = &allocImpl;
        ret.allocator.freeFn = &freeImpl;
        ret.allocator.reallocFn = &reallocImpl;
        return ret;
    }

    static void[] allocImpl(Allocator* alloc, size_t amount){return GC.malloc(amount)[0..amount];}
    static void[] reallocImpl(Allocator* alloc, void[] ptr, size_t amount){return GC.realloc(ptr.ptr, amount)[0..amount];}
    static void freeImpl(Allocator* alloc, void[] ptr){ GC.free(ptr.ptr);}

}