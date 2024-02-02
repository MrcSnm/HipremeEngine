module hip.windowing.platforms.browser;

version(WebAssembly):

extern(C) void WasmSetWindowSize(int width, int height);
extern(C) ubyte* WasmGetWindowSize();

void openWindow(int width, int height, out void* WindowHandle)
{
    WasmSetWindowSize(width, height);
}
///Returns [width, height]
int[2] getWindowSize(void* WindowHandle, ref string[] errors)
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

void setWindowSize(int width, int height, void* WindowHandle, ref string[] errors)
{
    WasmSetWindowSize(width, height);
}

import hip.windowing.platforms.null_;
alias setWindowName = hip.windowing.platforms.null_.setWindowName;
alias setVsyncActive = hip.windowing.platforms.null_.setVsyncActive;
alias setFullscreen = hip.windowing.platforms.null_.setFullscreen;
alias initializeOpenGL = hip.windowing.platforms.null_.initializeOpenGL;
alias show = hip.windowing.platforms.null_.show;
alias poll = hip.windowing.platforms.null_.poll;
alias swapBuffer = hip.windowing.platforms.null_.swapBuffer;
alias destroy_GL_Context = hip.windowing.platforms.null_.destroy_GL_Context;