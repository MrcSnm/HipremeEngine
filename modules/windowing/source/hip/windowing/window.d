module hip.windowing.window;

version(Android){}
else version(linux) version = X11;

version(UWP){}
else version(Windows) version = WindowsNative;


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

    string[] errors;

    version(WindowsNative)
    {
        import hip.windowing.platforms.windows;
        HWND hwnd;
    }
    else version(X11)
    {
        import hip.windowing.platforms.x11;
    }
    else version(WebAssembly)
    {
        import hip.windowing.platforms.browser;
    }
    else version(AppleOS)
    {
        import hip.windowing.platforms.appleos;
        void* MTKView;
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
        version(WindowsNative)
            openWindow(hwnd, width, height);
        else version(WebAssembly)
        {
            openWindow(width, height);
        }
        else version(AppleOS)
        {
            openWindow(&MTKView, width, height);
        }
        else version(X11)
        {
            version(SharedX11)
                loadX11();
            openWindow(width, height);
        }
    }
    bool startOpenGLContext(int majorVersion = 3, int minorVersion = 3)
    {
        //Windows must reinitialize the window if it uses modern gl, so, it must update the window here
        version(WindowsNative)
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
    void rendererPresent()
    {
        swapBuffer();
    }
    void setName(string name)
    {
        version(WindowsNative)
            hip.windowing.platforms.windows.setWindowName(hwnd, name);
        else version(X11)
            hip.windowing.platforms.x11.setWindowName(name);
        else version(AppleOS)
            hip.windowing.platforms.appleos.setWindowName(name);
        else
            errors~= "setName is not implemented for this platform";
    }
    void setSize(uint width, uint height)
    {
        version(WindowsNative)
            hip.windowing.platforms.windows.setWindowSize(hwnd, width, height);
        else version(X11)
            return hip.windowing.platforms.x11.setWindowSize(width, height);
        else version(AppleOS)
            return hip.windowing.platforms.appleos.setWindowSize(width, height);
        else version(WebASsembly)
            return hip.windowing.platforms.browser.setWindowSize(width, height);
        else
            errors~= "setSize is not implemented for this platform";
    }
    int[2] getSize()
    {
        version(WindowsNative)
            return hip.windowing.platforms.windows.getWindowSize(hwnd);
        else version(X11)
            return hip.windowing.platforms.x11.getWindowSize();
        else version(WebAssembly)
            return hip.windowing.platforms.browser.getWindowSize();
        else version(AppleOS)
            return hip.windowing.platforms.appleos.getWindowSize();
        else
        {
            errors~= "getSize is not implemented for this platform";
            return [0,0];
        }
    }
    void setVSyncActive(bool active)
    {
         //Windows must reinitialize the window if it uses modern gl, so, it must update the window here
        version(WindowsNative)
            hip.windowing.platforms.windows.setVsyncActive(active);
        else version(X11)
            hip.windowing.platforms.x11.setVsyncActive(active);
        else
            errors~= "VSync is not implemented for this platform";

    }
    void setFullscreen(bool fullscreen)
    {
        version(AppleOS)
            hip.windowing.platforms.appleos.setFullscreen(fullscreen);
        else
            errors~= "Fullscreen is not implemented for this platform";
    }
    
    void show()
    {
        version(WindowsNative)
            return hip.windowing.platforms.windows.show(hwnd);
        else version(X11)
            return hip.windowing.platforms.x11.show();
        else version(WebAssembly){} //Has no show
        else version(AppleOS){} //Has no show
        else
            errors~= "Show is not implemented for this platform";
    }
    void hide(){}
    void exit()
    {
        version(SharedX11)
            unloadX11();
    } 


}