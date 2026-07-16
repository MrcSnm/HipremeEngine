module hip.windowing.platforms.nintendo_switch;
version(NintendoSwitch):
import egl;

extern(System) void* nwindowGetDefault() @nogc nothrow;
extern(System) int nwindowGetDimensions(void* windowHandle, out int width, out int height) @nogc nothrow;

@nogc:
int openWindow(int width, int height, out void* WindowHandle)
{
    WindowHandle = nwindowGetDefault();
    return 1;
}
void show(void* WindowHandle){}
void poll(){}
float getDevicePixelRatio(void*){return 1;}

int[2] getWindowSize(void* WindowHandle, ref string[] errors)
{
    import core.stdc.stdio;
    int[2] sz;
    int res = nwindowGetDimensions(WindowHandle, sz[0], sz[1]);
    if(res != 0)
    {
        //
        printf("NWindowGetDimension Error %u %d %d\n", res, sz[0], sz[1]);
    }
    return sz;
}

int[2] getMaxScreenSize()
{
    return [1280, 720];
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

__gshared EGLDisplay display;
__gshared EGLContext context;
__gshared EGLSurface surface;

bool initializeOpenGL(int majorVersion, int minorVersion, void* WindowHandle)
{
    import core.stdc.stdio;
    import eglext;

    display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (!display)
    {
        printf("Could not connect to display! error: %d", eglGetError());
        goto _fail0;
    }

    // Initialize the EGL display connection
    eglInitialize(display, null, null);

    // Select OpenGL (Core) as the desired graphics API
    if (eglBindAPI(EGL_OPENGL_API) == EGL_FALSE)
    {
        printf("Could not set API! error: %d", eglGetError());
        goto _fail1;
    }
    printf("Initializing EGL\n");

    // Get an appropriate EGL framebuffer configuration
    EGLConfig config;
    EGLint numConfigs;
    __gshared const EGLint[15] framebufferAttributeList =
    [
        EGL_RENDERABLE_TYPE, EGL_OPENGL_BIT,
        EGL_RED_SIZE,     8,
        EGL_GREEN_SIZE,   8,
        EGL_BLUE_SIZE,    8,
        EGL_ALPHA_SIZE,   8,
        EGL_DEPTH_SIZE,   24,
        EGL_STENCIL_SIZE, 8,
        EGL_NONE
    ];

    eglChooseConfig(display, framebufferAttributeList.ptr, &config, 1, &numConfigs);
    if (numConfigs == 0)
    {
        printf("No config found! error: %d", eglGetError());
        goto _fail1;
    }

    // Create an EGL window surface
    surface = eglCreateWindowSurface(display, config,  cast(EGLNativeWindowType)WindowHandle, null);
    if (!surface)
    {
        printf("Surface creation failed! error: %d\n", eglGetError());
        goto _fail1;
    }

    // Create an EGL rendering context
    static const EGLint[7] contextAttributeList =
    [
        EGL_CONTEXT_OPENGL_PROFILE_MASK_KHR, EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR,
        EGL_CONTEXT_MAJOR_VERSION_KHR, 4,
        EGL_CONTEXT_MINOR_VERSION_KHR, 3,
        EGL_NONE
    ];
    context = eglCreateContext(display, config, EGL_NO_CONTEXT, contextAttributeList.ptr);
    if (!context)
    {
        printf("Context creation failed! error: %d\n", eglGetError());
        goto _fail2;
    }

    // Connect the context to the surface
    eglMakeCurrent(display, surface, surface, context);
    return true;

_fail2:
    eglDestroySurface(display, surface);
    surface = null;
_fail1:
    eglTerminate(display);
    display = null;
_fail0:

    return true;
}
void swapBuffer()
{
    eglSwapBuffers(display, surface);
}
bool destroy_GL_Context()
{
    import core.stdc.stdio;
    eglDestroySurface(display, surface);
  	eglDestroyContext(display, context);
  	eglTerminate(display);
	printf("EGL terminated.\n");

    return true;
}