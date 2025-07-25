module hip.windowing.window;
import hip.api.input.window;

version(UWP){}
else version(Windows) version = WindowsNative;


enum HipWindowFlags
{
    resizable   = 1,
    fullscreen  = 1<<1,
    maximizable = 1<<2,
    minimizable = 1<<4,

    DEFAULT = resizable | maximizable | minimizable
}

/**
*   This is not a feature complete windowing abstraction. It only has the necessary resources
*   for making the engine work. Its feature is not to be an implementation as complete as SDL.
*   thus, reducing the external dependencies, binary size and compilation steps.
*/
class HipWindow : IHipWindow
{
    int width, height;
    HipWindowFlags flags;

    string[] errors;

    /** 
     * HWND on Windows.
     * MTKView on AppleOS
     */
    package void* WindowHandle;
    version(Windows) void* hwnd(){return WindowHandle;}
    version(AppleOS) void* MTKView(){return WindowHandle;}

    this(int width, int height, HipWindowFlags flags)
    {
        this.width = width;
        this.height = height;
        this.flags = flags;
    }
    void start()
    {
        version(X11) version(SharedX11)
            loadX11();
        getModule!().openWindow(width, height, WindowHandle);
    }

    bool startOpenGLContext(int majorVersion = 3, int minorVersion = 3)
    {
        //Windows must reinitialize the window if it uses modern gl, so, it must update the window here
        return getModule!().initializeOpenGL(majorVersion, minorVersion, WindowHandle);
    }
    bool destroyOpenGLContext(){return getModule!().destroy_GL_Context();}
    void pollWindowEvents(){getModule!().poll();}
    void rendererPresent(){getModule!().swapBuffer();}
    void setName(string name)
    {
        getModule!().setWindowName(name, WindowHandle, errors);
    }
    void setSize(uint width, uint height) @nogc
    {
        getModule!().setWindowSize(width, height, WindowHandle, errors);
    }
    int[2] getSize()
    {
        return getModule!().getWindowSize(WindowHandle, errors);
    }
    void setVSyncActive(bool active)
    {
        //Windows must reinitialize the window if it uses modern gl, so, it must update the window here
        getModule!().setVsyncActive(active, WindowHandle, errors);

    }
    void setFullscreen(bool fullscreen)
    {
        getModule!().setFullscreen(fullscreen, WindowHandle, errors);
    }
    
    void show()
    {
        getModule!().show(WindowHandle);
    }
    void hide(){}
    void exit()
    {
        version(SharedX11)
            unloadX11();
    } 
}

private template getModule()
{
    version(WindowsNative)
        import getModule = hip.windowing.platforms.windows;
    else version(X11)
        import getModule = hip.windowing.platforms.x11;
    else version(WebAssembly)
        import getModule = hip.windowing.platforms.browser;
    else version(AppleOS)
        import getModule = hip.windowing.platforms.appleos;
    else
        import getModule = hip.windowing.platforms.null_;
}