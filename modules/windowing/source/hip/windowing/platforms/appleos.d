module hip.windowing.platforms.appleos;

version(AppleOS):

extern(C) void hipSetMTKView(void** MTKView);

void openWindow(void** MTKView, ref int width, ref int height)
{
    hipSetMTKView(MTKView);
    width = 0;
    height = 0;
}

void show(){}
void poll(){}
void swapBuffer(){}
bool destroy_GL_Context(){return true;}