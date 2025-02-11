module hip.windowing.platforms.x11;

version(X11):

import core.stdc.stdio;

import hip.windowing.platforms.x11lib.glx;
import hip.windowing.platforms.x11lib.x11;
import hip.windowing.events;
import hip.windowing.input;

public import hip.windowing.platforms.x11lib.x11;

package struct X11WindowData
{
    Display* display;
    Window window;
    Screen* screen;
    XVisualInfo* visual;
    int screenId;
    int width, height;
    Colormap colormap;
    GLXContext glContext;
    Atom atomWmDeleteWindow;

}
package X11WindowData x11win;

package __gshared bool ctxErrorOccurred = false;

package extern(C) nothrow @system @nogc
int ctxErrorHandler( Display *dpy, XErrorEvent *ev )
{
    ctxErrorOccurred = true;
    return 0;
}

@nogc:

nothrow @nogc bool initializeOpenGL(int majorVersion, int minorVersion, void* WindowHandle)
{
    GLint[23] glxAttribs = [
        GLX_X_RENDERABLE    , True,
		GLX_DRAWABLE_TYPE   , GLX_WINDOW_BIT,
		GLX_RENDER_TYPE     , GLX_RGBA_BIT,
		GLX_X_VISUAL_TYPE   , GLX_TRUE_COLOR,
		GLX_RED_SIZE        , 8,
		GLX_GREEN_SIZE      , 8,
		GLX_BLUE_SIZE       , 8,
		GLX_ALPHA_SIZE      , 8,
		GLX_DEPTH_SIZE      , 24,
		GLX_STENCIL_SIZE    , 8,
		GLX_DOUBLEBUFFER    , True,
		None
    ];
    
    int fbcount;
    GLXFBConfig* fbc = glXChooseFBConfig(x11win.display, x11win.screenId, glxAttribs.ptr, &fbcount);
    if (fbc is null || fbcount == 0) 
    {
        printf("Failed to retrieve framebuffer.\n");
        XCloseDisplay(x11win.display);
        return 1;
    }

    // Pick the FB config/visual with the most samples per pixel
	int best_fbc = -1, worst_fbc = -1, best_num_samp = -1, worst_num_samp = 999;
	for (int i = 0; i < fbcount; ++i) {
		XVisualInfo *vi = glXGetVisualFromFBConfig( x11win.display, fbc[i] );
		if ( vi != null) {
			int samp_buf, samples;
			glXGetFBConfigAttrib( x11win.display, fbc[i], GLX_SAMPLE_BUFFERS, &samp_buf );
			glXGetFBConfigAttrib( x11win.display, fbc[i], GLX_SAMPLES       , &samples  );

			if ( best_fbc < 0 || (samp_buf && samples > best_num_samp) ) {
				best_fbc = i;
				best_num_samp = samples;
			}
			if ( worst_fbc < 0 || !samp_buf || samples < worst_num_samp )
				worst_fbc = i;
			worst_num_samp = samples;
		}
		XFree( vi );
	}


    //Some would try to get the best framebuffer, but, is that really necessary? Get the first
    GLXFBConfig bestFbc = fbc[best_fbc];
    XFree(fbc);
    x11win.visual = glXGetVisualFromFBConfig(x11win.display, bestFbc);
    if(x11win.visual == null)
    {
        printf("Could not create correct visual window \n");
        XCloseDisplay(x11win.display);
        return false;
    }

    //Open the window
    XSetWindowAttributes windowAttribs;
    windowAttribs.border_pixel = BlackPixel(x11win.display, x11win.screenId);
    windowAttribs.background_pixel = WhitePixel(x11win.display, x11win.screenId);
    windowAttribs.override_redirect = True;
    windowAttribs.colormap = XCreateColormap(
        x11win.display, RootWindow(x11win.display, x11win.screenId), x11win.visual.visual, AllocNone
    );

    windowAttribs.event_mask = PointerMotionMask |
                             ButtonPressMask |
                             ButtonReleaseMask |
	    		     KeyPressMask |
	    		     KeyReleaseMask |
                             EnterWindowMask |
                             LeaveWindowMask |
                             ExposureMask;



    x11win.window = XCreateWindow(
        x11win.display, 
        RootWindow(x11win.display, x11win.screenId), 
        0, 0, x11win.width, x11win.height,
        0, x11win.visual.depth, InputOutput, x11win.visual.visual,
        CWBackPixel | CWColormap | CWBorderPixel | CWEventMask, 
        &windowAttribs
    );
    if(!x11win.window)
    {
        printf("Could not create XWindow\n");
        return false;
    }

    Atom atomWmDeleteWindow = XInternAtom(x11win.display, "WM_DELETE_WINDOW", False);
    if(atomWmDeleteWindow == BadAlloc)
    {
        printf("X Server failed to allocate WM_DELETE_WINDOW\n");
        return false;
    }
    else if(atomWmDeleteWindow == BadValue)
    {
        printf("WM_DELETE_WINDOW is not a valid argument\n");
        return false;
    }
    x11win.atomWmDeleteWindow = atomWmDeleteWindow;
    Status st = XSetWMProtocols(x11win.display, x11win.window, &atomWmDeleteWindow, 1);
    if(st == BadAlloc)
    {
        printf("XServer failed to allocate resources for SetWMProtocols\n");
        return false;
    }
    else if(st == BadWindow)
    {
        printf("The window argument does not name a defined window\n");
        return false;
    }

    const(char)* glExts = glXQueryExtensionsString(x11win.display, DefaultScreen(x11win.display));

    glXCreateContextAttribsARBProc glXCreateContextAttribsARB;
    glXCreateContextAttribsARB = cast(glXCreateContextAttribsARBProc)glXGetProcAddressARB(cast(const(GLubyte)*)"glXCreateContextAttribsARB");

    GLXContext glContext;


    if(!isExtensionSupported(glExts, "GLX_ARB_create_context") || glXCreateContextAttribsARB is null)
    {
        printf("glXCreateContextAttribsARB() not found, using old style GLX context");
        x11win.glContext = glContext = glXCreateNewContext(x11win.display, bestFbc, GLX_RGBA_TYPE, null, True);
    }
    else
    {
        int[7] context_attribs =
        [
            GLX_CONTEXT_MAJOR_VERSION_ARB, 3,
            GLX_CONTEXT_MINOR_VERSION_ARB, 3, //3.3 is the minimum here
            GLX_CONTEXT_FLAGS_ARB        , GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
            None
        ];

        x11win.glContext = glContext = glXCreateContextAttribsARB(x11win.display, bestFbc, null,
                                      True, context_attribs.ptr );
    }
    if(x11win.glContext == null)
    {
        printf("Could not create GLX Context\n");
        return false;
    }
    XSync(x11win.display, False);

    if (!glXIsDirect (x11win.display, x11win.glContext)) 
		printf("Indirect GLX rendering context obtained\n");
    if(glXMakeCurrent(x11win.display, x11win.window, x11win.glContext) == 0)
    {
        printf("Could not make GLX Context as current\n");
        return false;
    }
    //Show Window
    XClearWindow(x11win.display, x11win.window);
    XMapRaised(x11win.display, x11win.window);
    XStoreName(x11win.display, x11win.window, "HipremeEngine");

    string[] errors;
    setVsyncActive(false, null, errors);


    return true;
}

void show(void* WindowHandle){}
void swapBuffer()
{
    glXSwapBuffers(x11win.display, x11win.window);
}

void setVsyncActive(bool active, void* WindowHandle, ref string[] errors) @nogc nothrow @system
{
    static bool loadedSymbols = false;
    if(!loadedSymbols)
    {
        glXSwapIntervalEXT = cast(glXSwapIntervalEXTProc)glXGetProcAddressARB(cast(GLubyte*)"glXSwapIntervalEXT");
        glXSwapIntervalMESA = cast(glXSwapIntervalMESAProc)glXGetProcAddressARB(cast(GLubyte*)"glXSwapIntervalMESA");
        glXSwapIntervalSGI = cast(glXSwapIntervalSGIProc)glXGetProcAddressARB(cast(GLubyte*)"glXSwapIntervalSGI");
        loadedSymbols = true;
    }
    glXSwapIntervalEXT(x11win.display, x11win.window, cast(int)active);
    glXSwapIntervalMESA(cast(int)active);
    glXSwapIntervalSGI(cast(int)active);
}

void setWindowName(string name, void* WindowHandle, ref string[] errors)
{
    XStoreName(x11win.display, x11win.window, name.ptr);
}


pragma(inline) wchar convertKeycodeToScancode(XKeyEvent* ev)
{
    char[2] buffer = '\0';
    KeySym ks;
    int allocated = XLookupString(ev, buffer.ptr, buffer.length, &ks, null);
    if(allocated > 1)
        printf("%*s", cast(int)buffer.length, buffer.ptr);
    return *cast(wchar*)(cast(void*)buffer.ptr);
}

void poll()
{
    XEvent ev;
    while (XPending(x11win.display) > 0) 
    {
        XNextEvent(x11win.display, &ev);
        switch(ev.type)
        {
            case Expose:
            {
                XWindowAttributes attribs;
                XGetWindowAttributes(x11win.display, x11win.window, &attribs);
                printf("Expose event\n");
                break;
            }
            case ClientMessage:
                if(ev.xclient.data.l[0] == x11win.atomWmDeleteWindow && onWindowClosed != null)
                    onWindowClosed();
                break;
            case DestroyNotify:
            {
                if(onWindowClosed != null)
                    onWindowClosed();
                break;
            }
            case ButtonPress:
            {
                int x = ev.xbutton.x;
                int y = ev.xbutton.y;
                switch(ev.xbutton.button)
                {
                    case 1: //Left
                        if(onMouseDown != null)
                            onMouseDown(HipWindowingMouseButton.left, x, y);
                        break;
                    case 2: //Middle
                        if(onMouseDown != null)
                            onMouseDown(HipWindowingMouseButton.middle, x, y);
                        break;
                    case 3: //Right
                        if(onMouseDown != null)
                            onMouseDown(HipWindowingMouseButton.right, x, y);
                        break;
                    case 4: //Scroll up
                        if(onMouseWheel != null)
                            onMouseWheel(0, -1);
                        break;
                    case 5: //Scroll down
                        if(onMouseWheel != null)
                            onMouseWheel(0, 1);
                        break;
                    default: break;
                }
            } break;
            case ButtonRelease:
            {
                int x = ev.xbutton.x;
                int y = ev.xbutton.y;
                switch(ev.xbutton.button)
                {
                    case 1: //Left
                        if(onMouseUp != null)
                            onMouseUp(HipWindowingMouseButton.left, x, y);
                        break;
                    case 2: //Middle
                        if(onMouseUp != null)
                            onMouseUp(HipWindowingMouseButton.middle, x, y);
                        break;
                    case 3: //Right
                        if(onMouseUp != null)
                            onMouseUp(HipWindowingMouseButton.right, x, y);
                        break;
                    default: break;
                }
            } break;
            case MotionNotify:
                if(onMouseMove != null)
                    onMouseMove(ev.xmotion.x, ev.xmotion.y);
                break;
            case KeyPress:
                if(onKeyDown != null)
                    onKeyDown(cast(uint)XKeycodeToKeysym(x11win.display, ev.xkey.keycode, ev.xkey.state & ShiftMask ? 1 : 0));
                    // onKeyDown(convertKeycodeToScancode(&ev.xkey));
                break;
            case KeyRelease:
                if(onKeyUp != null)
                    onKeyUp(cast(uint)XKeycodeToKeysym(x11win.display, ev.xkey.keycode, ev.xkey.state & ShiftMask ? 1 : 0));
                    // onKeyUp(convertKeycodeToScancode(&ev.xkey));
                break;
            default:break;
        }
    }
}

///Returns [width, height]
int[2] getWindowSize(void* WindowHandle, ref string[] errors)
{
    XWindowAttributes att;
    XGetWindowAttributes(x11win.display, x11win.window, &att);
    return [att.width, att.height];
}

void setWindowSize(int width, int height, void* WindowHandle, ref string[] errors)
{
    uint change_values = CWWidth | CWHeight;
    XWindowChanges values;
    values.width = width;
    values.height = height;
    XConfigureWindow(x11win.display, x11win.window, change_values, &values);
}
import hip.windowing.platforms.null_;
alias setFullscreen = hip.windowing.platforms.null_.setFullscreen;

bool destroy_GL_Context()
{
    XDestroyWindow(x11win.display, x11win.window);
    XCloseDisplay(x11win.display);
    XFree(x11win.visual);
    XFreeColormap(x11win.display, x11win.colormap);
    glXDestroyContext(x11win.display, x11win.glContext);
    return true;
}

int openWindow(int width, int height, out void* WindowHandle)
{
    x11win.width = width;
    x11win.height = height;
    //Open the display
    x11win.display = XOpenDisplay(null);
    if(x11win.display == null)
    {
        printf("Could not open display.\n");
        return 1;
    }
    int glx_major, glx_minor;
    if ( !glXQueryVersion(x11win.display, &glx_major, &glx_minor ) || 
       ( ( glx_major == 1 ) && ( glx_minor < 3 ) ) || ( glx_major < 1 ) )
    {
        printf("Invalid GLX version\n");
        return 1;
    }
    x11win.screenId = DefaultScreen(x11win.display);
    
    return 0;
}
