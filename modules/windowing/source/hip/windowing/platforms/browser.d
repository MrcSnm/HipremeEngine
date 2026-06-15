module hip.windowing.platforms.browser;

version(WebAssembly):
@nogc:

extern(C) void WasmSetWindowSize(int width, int height) @nogc;
extern(C) ubyte* WasmGetWindowSize() @nogc;
extern(C) ubyte* WasmGetMaxScreenSize() @nogc;
extern(C) float hipGetWindowScaleFactor() @nogc;
extern(C) void WasmSetWindowTitle(uint nameLen, const(char)* namePtr) @nogc;
extern(C) void WasmSetFullscreen(bool bFullscreen); 

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

int[2] getMaxScreenSize()
{
    import core.memory;
    ubyte* intArray = WasmGetMaxScreenSize();
    int[2] ret;
    size_t sz = *cast(size_t*)intArray;
    assert(sz == 2, "Wrong toDArray received.");
    int[] arr = cast(int[])intArray[size_t.sizeof..size_t.sizeof*(sz+1)];
    ret[] = arr[];
    GC.free(intArray);
    return ret;
}

float getDevicePixelRatio(void* WindowHandle){return hipGetWindowScaleFactor();}


void setWindowSize(int width, int height, void* WindowHandle, ref string[] errors)
{
    WasmSetWindowSize(width, height);
}

import hip.windowing.platforms.null_;
void setWindowName(string name, void* WindowHandle, ref string[] errors)
{
    WasmSetWindowTitle(name.length, name.ptr);
}

void setFullscreen(bool bFullscreen, void* WindowHandle, ref string[] errors)
{
    WasmSetFullscreen(bFullscreen);
}

alias setVsyncActive = hip.windowing.platforms.null_.setVsyncActive;
alias initializeOpenGL = hip.windowing.platforms.null_.initializeOpenGL;
alias show = hip.windowing.platforms.null_.show;
alias poll = hip.windowing.platforms.null_.poll;
alias swapBuffer = hip.windowing.platforms.null_.swapBuffer;
alias destroy_GL_Context = hip.windowing.platforms.null_.destroy_GL_Context;