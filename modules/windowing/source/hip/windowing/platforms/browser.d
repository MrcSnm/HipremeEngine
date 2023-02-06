module hip.windowing.platforms.browser;

version(WebAssembly):

extern(C) void WasmSetWindowSize(int width, int height);
extern(C) ubyte* WasmGetWindowSize();

void openWindow(int width, int height)
{
    WasmSetWindowSize(width, height);
}
///Returns [width, height]
int[2] getWindowSize()
{
    import core.memory;
    ubyte* intArray = WasmGetWindowSize();
    int[2] ret;
    size_t sz = *cast(size_t*)intArray;
    assert(sz == 2, "Wrong toDArray received.");
    int[] arr = cast(int[])intArray[size_t.sizeof..size_t.sizeof*(sz+1)];
    ret[] = arr[];
    GC.free(intArray);
    return ret;
}

void setWindowSize(int width, int height)
{
    WasmSetWindowSize(width, height);
}

void show(){}
void poll(){}
void swapBuffer(){}
bool destroy_GL_Context(){return true;}