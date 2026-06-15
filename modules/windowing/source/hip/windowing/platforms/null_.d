module hip.windowing.platforms.null_;

@nogc:
int openWindow(int width, int height, out void* WindowHandle){return 1;}
void show(void* WindowHandle){}
void poll(){}
float getDevicePixelRatio(void*){return 1;}

version(PSVita)
{
    extern(C) void vitaGetWindowSize(int* width, int* height) pure nothrow @nogc;
}

int[2] getWindowSize(void* WindowHandle, ref string[] errors)
{
    version(PSVita)
    {
        int[2] ret;
        vitaGetWindowSize(ret.ptr, ret.ptr+1);
        return ret;
    }
    else
        return [0,0];
    // errors~= "getWindowSize is not implemented for this platform";
}

int[2] getMaxScreenSize()
{
    version(PSVita)
    {
        int[2] ret;
        vitaGetWindowSize(ret.ptr, ret.ptr+1);
        return ret;
    }
    else
        return [0, 0];
}
void setWindowSize(int width, int height, void* WindowHandle, ref string[] errors)
{
    // errors~= "setWindowSize is not implemented for this platform";
}
void setWindowName(string name, void* WindowHandle, ref string[] errors)
{
    // errors~= "setWindowName is not implemented for this platform";
}

void setVsyncActive(bool bActive, void* WindowHandle, ref string[] errors)
{
    // errors~= "Vsync is not implemented for this platform";
}
void setFullscreen(bool bFullscreen, void* WindowHandle, ref string[] errors)
{
    // errors~= "Fullscreen is not implemented for this platform";
}

bool initializeOpenGL(int majorVersion, int minorVersion, void* WindowHandle){return true;}
void swapBuffer()
{

}
bool destroy_GL_Context(){return true;}