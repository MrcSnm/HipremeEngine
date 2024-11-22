module hip.windowing.platforms.appleos;

version(AppleOS):
@nogc:

///Those are defined in Hipreme Engine Shared/Renderer.m
extern(C) void   hipSetMTKView(void** MTKView, int* outWidth, int* outHeight);
extern(C) int[2] hipGetWindowSize();
extern(C) void   hipSetWindowSize(uint width, uint height);
extern(C) void   hipSetApplicationFullscreen(bool);
extern(C) void   hipSetApplicationTitle(const(char)* title);

void openWindow(ref int width, ref int height, out void* MTKView)
{
    hipSetMTKView(&MTKView, &width, &height);
}

void setWindowName(string name, void* WindowHandle, ref string[] errors)
{
    string nullEndedStr = name ~ '\0';
    hipSetApplicationTitle(nullEndedStr.ptr);
}

//Null ops
import hip.windowing.platforms.null_;
alias setVsyncActive     = hip.windowing.platforms.null_.setVsyncActive;
alias show               = hip.windowing.platforms.null_.show;
alias poll               = hip.windowing.platforms.null_.poll;
alias swapBuffer         = hip.windowing.platforms.null_.swapBuffer;
alias destroy_GL_Context = hip.windowing.platforms.null_.destroy_GL_Context;


int[2] getWindowSize(void* WindowHandle, ref string[] errors)
{
    return hipGetWindowSize();
}

void setWindowSize(uint width, uint height, void* WindowHandle, ref string[] errors)
{
    hipSetWindowSize(width, height);
}
void setFullscreen(bool bFullscreen, void* WindowHandle, ref string[] errors)
{
    hipSetApplicationFullscreen(bFullscreen);
}
bool initializeOpenGL(int majorVersion, int minorVersion, void* WindowHandle){return false;}