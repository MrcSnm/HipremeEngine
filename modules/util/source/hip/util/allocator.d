module hip.util.allocator;

/// Enables the FrameAllocator guard. Must be set before `FrameAllocator.create()`.
/// Read by the engine at startup (`--frame-guard` / `engine_opts.json`).
version(assert)
    __gshared bool frameAllocatorGuardEnabled = true;
else version(HipremeFrameAllocatorGuard)
    __gshared bool frameAllocatorGuardEnabled = true;
else
    __gshared bool frameAllocatorGuardEnabled = false;

/// Detects references that escaped the previous frame: a second buffer is
/// poisoned (or page-protected where available) and checked on `reset`.
version(HipremeNoFramePageGuard) {}
else version(WebAssembly) {}
else version(PSVita) {}
else version(NintendoSwitch) {}
else version(Posix) version = FramePageGuard;
else version(Windows)
{
    version(UWP) {}
    else version = FramePageGuard;
}

version(FramePageGuard)
{
    private ubyte[] pageAlloc(size_t size) @trusted
    {
        version(Posix)
        {
            import core.sys.posix.sys.mman : mmap, MAP_PRIVATE, MAP_ANON,
                PROT_READ, PROT_WRITE, MAP_FAILED;
            void* p = mmap(null, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
            return p == MAP_FAILED ? null : (cast(ubyte*)p)[0..size];
        }
        else version(Windows)
        {
            import core.sys.windows.windows : VirtualAlloc;
            import core.sys.windows.winnt : MEM_COMMIT, MEM_RESERVE, PAGE_READWRITE;
            void* p = VirtualAlloc(null, size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
            return p is null ? null : (cast(ubyte*)p)[0..size];
        }
    }

    private void pageSetAccess(ubyte[] mem, bool accessible) @trusted
    {
        version(Posix)
        {
            import core.sys.posix.sys.mman : mprotect, PROT_NONE, PROT_READ, PROT_WRITE;
            assert(mprotect(mem.ptr, mem.length, accessible ? PROT_READ | PROT_WRITE : PROT_NONE) == 0,
                "FrameAllocator: mprotect failed");
        }
        else version(Windows)
        {
            import core.sys.windows.windows : VirtualProtect;
            import core.sys.windows.winnt : PAGE_NOACCESS, PAGE_READWRITE;
            uint oldState;
            assert(VirtualProtect(mem.ptr, mem.length, accessible ? PAGE_READWRITE : PAGE_NOACCESS, &oldState) != 0,
                "FrameAllocator: VirtualProtect failed");
        }
    }
}

version(WebAssembly)    version = CustomRuntimeAbort;
version(PSVita)         version = CustomRuntimeAbort;
version(NintendoSwitch) version = CustomRuntimeAbort;

/// Used by the sentinel fallback, including release builds (where `assert` is off).
private void frameGuardFailed() @trusted
{
    version(assert)
        assert(false, "FrameAllocator: frame memory was used after reset(). A reference escaped the frame.");
    else version(CustomRuntimeAbort)
    {
        import rt.hooks : abort;
        abort();
    }
    else
    {
        import core.stdc.stdlib : abort;
        abort();
    }
}

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

    ///Second buffer used to detect references that escaped the previous frame.
    private ubyte[] retiredHeap;
    private bool guard;
    private enum ubyte staleSentinel = 0xDE;

    alias allocator this;
    
    static FrameAllocator create(size_t heapSize)
    {
        FrameAllocator ret;
        ret.guard = frameAllocatorGuardEnabled;
        if(ret.guard)
        {
            version(FramePageGuard)
            {
                ret.heap = pageAlloc(heapSize);
                ret.retiredHeap = pageAlloc(heapSize);
                assert(ret.heap !is null && ret.retiredHeap !is null,
                    "FrameAllocator: could not allocate guard pages");
                pageSetAccess(ret.retiredHeap, false);
            }
            else
            {
                ret.heap.length = heapSize;
                ret.retiredHeap.length = heapSize;
                ret.retiredHeap[] = staleSentinel;
            }
        }
        else
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
        if(guard)
        {
            version(FramePageGuard)
            {
                // Rotate first: the buffer that just finished its frame becomes
                // read-protected, so a stale access faults at the offending line.
                ubyte[] tmp = heap;
                heap = retiredHeap;
                retiredHeap = tmp;
                pageSetAccess(heap, true);
                pageSetAccess(retiredHeap, false);
            }
            else
            {
                // The retired buffer was poisoned with `staleSentinel` at the previous
                // reset. Any other byte means a reference from the previous frame wrote
                // to it after reset: the frame memory escaped its frame.
                foreach(ref b; retiredHeap)
                    if(b != staleSentinel)
                        frameGuardFailed();

                // Rotate buffers and poison the one that just finished its frame.
                ubyte[] tmp = heap;
                heap = retiredHeap;
                retiredHeap = tmp;
                retiredHeap[] = staleSentinel;
            }
        }
        else
            heap[0..offset] = 0;
        offset = 0; 
    }
}

version(assert) unittest
{
    bool oldGuard = frameAllocatorGuardEnabled;

    frameAllocatorGuardEnabled = true;
    auto a = FrameAllocator.create(64);
    void[] first = a.alloc(8);
    (cast(ubyte[])first)[] = 1;

    a.reset();
    void[] second = a.alloc(8);
    assert(second.ptr != first.ptr, "FrameAllocator must alternate buffers after reset");
    (cast(ubyte[])second)[] = 2;

    version(FramePageGuard)
    {
        // Accessing `first` now would fault by design, so only the sentinel
        // fallback can verify detection in-process.
    }
    else
    {
        import core.exception : AssertError;
        import std.exception : assertThrown;

        (cast(ubyte[])first)[0] = 3; // stale reference writing to the retired frame
        assertThrown!AssertError(a.reset());
    }

    frameAllocatorGuardEnabled = false;
    auto b = FrameAllocator.create(64);
    void[] third = b.alloc(8);
    (cast(ubyte[])third)[] = 1;
    b.reset();
    assert(b.alloc(8).ptr is third.ptr, "Without the guard the same heap must be reused");

    frameAllocatorGuardEnabled = oldGuard;
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