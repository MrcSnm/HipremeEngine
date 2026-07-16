module hip.windowing.platforms.nintendo_switch;


version(NintendoSwitch):
import hip.windowing.platforms.nxlib.hid;
import hip.windowing.platforms.nxlib.pad;
import egl;


enum HipGamepadTypes
{
	HipGamepadTypes_xbox,
	HipGamepadTypes_psvita,
    HipGamepadTypes_nintendo_switch
}

/// Initialize hiddbg.
extern(System) @nogc nothrow
{
    Result hiddbgInitialize();
    void hiddbgExit();
    void HipInputOnGamepadConnected(ubyte id, ubyte type);
    void HipInputOnTouchPressed(uint id, float x, float y);
    void HipInputOnTouchMoved(uint id, float x, float y);
    void HipInputOnTouchReleased(uint id, float x, float y);

    void* nwindowGetDefault();
    int nwindowGetDimensions(void* windowHandle, out int width, out int height);
}


@nogc:
__gshared PadState nxpad;
int openWindow(int width, int height, out void* WindowHandle)
{
    WindowHandle = nwindowGetDefault();
    padConfigureInput(8, HidNpadStyleSet.NpadStandard);
    padInitializeAny(&nxpad);
    HipInputOnGamepadConnected(0, HipGamepadTypes.HipGamepadTypes_nintendo_switch);
    hiddbgInitialize();
    hidInitializeTouchScreen();

    return 1;
}
void show(void* WindowHandle){}


/// @brief Gets touch ID used by hipreme engine
/// @param psvId 
/// @return 
private int getTouchId(uint fingerId)
{
    for(int i = 0; i < 6; i++) if(touches[i] == fingerId) return i;
    return -1;
}
private __gshared uint[6] touches = uint.max;


private __gshared HidTouchScreenState oldTouch;

private int idInTouchReport(const ref HidTouchState touch, const ref HidTouchScreenState newState)
{
    for(int i = 0; i < newState.count; i++)
    {
        if(newState.touches[i].finger_id == touch.finger_id)
            return i;
    }
    return -1;
}

void poll()
{
    HidTouchScreenState state;
    enum float touchPixelRatio = 1.0f;
    if (hidGetTouchScreenStates(&state, 1)) 
    {
        for(int i = 0; i < state.count; i++)
        {
            if(getTouchId(state.touches[i].finger_id) == -1)
                touches[i] = state.touches[i].finger_id;
        }
        //Check release
        for(int i = 0; i < oldTouch.count; i++)
        {
            if(idInTouchReport(oldTouch.touches[i], state) != -1)
                continue;
            
            int id = getTouchId(oldTouch.touches[i].finger_id);
            if(id != -1)
            {
                HipInputOnTouchReleased(id, cast(float)oldTouch.touches[i].x*touchPixelRatio, cast(float)oldTouch.touches[i].y*touchPixelRatio);
                touches[i] = uint.max;
            }
        }

        //Press check
        for(int i = 0; i < state.count;i++)
        {
            int id = getTouchId(state.touches[i].finger_id);
            int oldId = idInTouchReport(state.touches[i], oldTouch);
            if(oldId != -1)  //in old
            {
                if(state.touches[i].x != oldTouch.touches[i].x || state.touches[i].x != oldTouch.touches[i].y)
                    HipInputOnTouchMoved(id, cast(float)state.touches[i].x*touchPixelRatio, cast(float)state.touches[i].y*touchPixelRatio);
                continue;
            }

            if(id != -1)
                HipInputOnTouchPressed(id, cast(float)state.touches[i].x*touchPixelRatio, cast(float)state.touches[i].y*touchPixelRatio);
        }

    }
    oldTouch = state;

}
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