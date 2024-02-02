module hip.windowing.platforms.null_;

int openWindow(int width, int height, out void* WindowHandle){return 1;}
void show(void* WindowHandle){}
void poll(){}
int[2] getWindowSize(void* WindowHandle, ref string[] errors)
{
    errors~= "getWindowSize is not implemented for this platform";
    return [0,0];
}
void setWindowSize(int width, int height, void* WindowHandle, ref string[] errors)
{
    errors~= "setWindowSize is not implemented for this platform";
}
void setWindowName(string name, void* WindowHandle, ref string[] errors)
{
    errors~= "setWindowName is not implemented for this platform";
}

void setVsyncActive(bool bActive, void* WindowHandle, ref string[] errors)
{
    errors~= "Vsync is not implemented for this platform";
}
void setFullscreen(bool bFullscreen, void* WindowHandle, ref string[] errors)
{
    errors~= "Fullscreen is not implemented for this platform";
}

bool initializeOpenGL(int majorVersion, int minorVersion, void* WindowHandle){return true;}
void swapBuffer()
{

}
bool destroy_GL_Context(){return true;}