module hip.windowing.window;

version(Posix)
    version = X11;

enum HipWindowFlags
{
    RESIZABLE   = 1,
    FULLSCREEN  = 1<<1,
    MAXIMIZABLE = 1<<2,
    MINIMIZABLE = 1<<4,

    DEFAULT = RESIZABLE | MAXIMIZABLE | MINIMIZABLE
}

/**
*   This is not a feature complete windowing abstraction. It only has the necessary resources
*   for making the engine work. Its feature is not to be an implementation as complete as SDL.
*   thus, reducing the external dependencies, binary size and compilation steps.
*/
class HipWindow
{
    int width, height;
    HipWindowFlags flags;
    version(Windows)
    {
        import hip.windowing.platforms.windows;
        HWND hwnd;
    }
    else version(X11)
    {
        import hip.windowing.platforms.x11;
    }
    else
    {
        import hip.windowing.platforms.null_;
    }

    this(int width, int height, HipWindowFlags flags)
    {
        this.width = width;
        this.height = height;
        this.flags = flags;
    }
    void start()
    {
        version(Windows)
            openWindow(hwnd, width, height);
        version(X11)
        {
            version(SharedX11)
                loadX11();
            openWindow(width, height);
        }
    }
    bool startOpenGLContext(int majorVersion = 3, int minorVersion = 3)
    {
        //Windows must reinitialize the window if it uses modern gl, so, it must update the window here
        version(Windows)
            return hip.windowing.platforms.windows.initializeOpenGL(hwnd, majorVersion, minorVersion);
        else version(X11)
            return hip.windowing.platforms.x11.initializeOpenGL(majorVersion, minorVersion);
        else
            return true; //Assume that OpenGL is started
    }
    bool destroyOpenGLContext()
    {
        return destroy_GL_Context();
    }
    void pollWindowEvents(){poll();}
    void rendererPresent(){swapBuffer();}
    void setName(string name){}
    void setSize(uint width, uint height){}
    void setVSyncActive(bool active)
    {
         //Windows must reinitialize the window if it uses modern gl, so, it must update the window here
        version(Windows)
            hip.windowing.platforms.windows.setVsyncActive(active);
        else version(X11)
            hip.windowing.platforms.x11.setVsyncActive(active);
        else
        {
            import std.stdio;
            writeln("VSync is not implemented for this platform");
        }

    }
    void setFullscreen(bool fullscreen){}
    
    void show()
    {
        version(Windows)
            return hip.windowing.platforms.windows.show(hwnd);
        else version(X11)
            return hip.windowing.platforms.x11.show();
        else
        {
            import std.stdio;
            writeln("Show is not implemented for this platform");
        }
    }
    void hide(){}
    void exit()
    {
        version(SharedX11)
            unloadX11();
    } 


}