module hip.windowing.platforms.appleos;

version(AppleOS):

///Those are defined in Hipreme Engine Shared/Renderer.m
extern(C) void   hipSetMTKView(void** MTKView, int* outWidth, int* outHeight);
extern(C) int[2] hipGetWindowSize();
extern(C) void   hipSetWindowSize(uint width, uint height);
extern(C) void   hipSetApplicationFullscreen(bool);
extern(C) void   hipSetApplicationTitle(const(char)* title);

void openWindow(void** MTKView, ref int width, ref int height)
{
    hipSetMTKView(MTKView, &width, &height);
}

void setWindowName(string name)
{
    string nullEndedStr = name ~ '\0';
    hipSetApplicationTitle(nullEndedStr.ptr);
}

alias getWindowSize = hipGetWindowSize;
alias setWindowSize = hipSetWindowSize;
alias setFullscreen = hipSetApplicationFullscreen;

void show(){}
void poll(){}
void swapBuffer(){}
bool destroy_GL_Context(){return true;}