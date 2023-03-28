module hip.windowing.platforms.appleos;

version(AppleOS):

///Those are defined in Hipreme Engine Shared/Renderer.m
extern(C) void   hipSetMTKView(void** MTKView, int* outWidth, int* outHeight);
extern(C) int[2] hipGetWindowSize();
extern(C) void   hipSetWindowSize(uint width, uint height);

void openWindow(void** MTKView, ref int width, ref int height)
{
    hipSetMTKView(MTKView, &width, &height);
}

alias getWindowSize = hipGetWindowSize;
alias setWindowSize = hipSetWindowSize;

void show(){}
void poll(){}
void swapBuffer(){}
bool destroy_GL_Context(){return true;}