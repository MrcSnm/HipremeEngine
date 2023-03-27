module hip.windowing.platforms.appleos;

version(AppleOS):

extern(C) void hipSetMTKView(void** MTKView, int* outWidth, int* outHeight);

void openWindow(void** MTKView, ref int width, ref int height)
{
    hipSetMTKView(MTKView, &width, &height);
}

void show(){}
void poll(){}
void swapBuffer(){}
bool destroy_GL_Context(){return true;}