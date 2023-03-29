module hip.windowing.platforms.windows;
import hip.windowing.input;
import hip.windowing.events;


version(UWP){}
else version(Windows)
    version = WindowsNative;

version(WindowsNative)
{
    import core.sys.windows.winuser;
    import core.sys.windows.wingdi;
    import core.sys.windows.winbase : GetModuleHandle,
                                    GetLastError,
                                    FormatMessage,
                                    FORMAT_MESSAGE_ALLOCATE_BUFFER,
                                    FORMAT_MESSAGE_FROM_SYSTEM,
                                    LocalFree;
    import core.sys.windows.windef;

    alias HWND = void*;
    alias HINSTANCE = void*;
    package const(wchar)* winClassName = "HipremeEngine";
    package __gshared HDC hdc;
    package HGLRC glContext;

    pragma(lib, "opengl32");
    pragma(lib, "gdi32");
    pragma(lib, "user32"); //Can't import that to UWP
    pragma(lib, "kernel32");//Can't import that to UWP
    nothrow ushort LOWORD(ulong l) {return cast(ushort) l;}
    nothrow ushort HIWORD(ulong l) {return cast(ushort) (l >>> 16);}
    nothrow @system int GET_X_LPARAM(LPARAM lp){return cast(int)cast(short)LOWORD(lp);}
    nothrow @system int GET_Y_LPARAM(LPARAM lp){return cast(int)cast(short)HIWORD(lp);}
    nothrow @system uint GET_XBUTTON_WPARAM(WPARAM wp){ return cast(uint)HIWORD(wp);}


    package extern(Windows) LRESULT WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) nothrow @system
    {
        switch(msg)
        {
            case WM_CLOSE:
                if(onWindowClosed != null)
                    onWindowClosed();
                DestroyWindow(hwnd);
                break;
            case WM_DESTROY:
                PostQuitMessage(0);
                ReleaseDC(hwnd, hdc);
                break;
            case WM_CHAR:
            case WM_SYSCHAR:
                if(onTextInput != null)
                    onTextInput(cast(wchar)wParam);
                break;
            case WM_SYSKEYDOWN:
            case WM_KEYDOWN:
                if(onKeyDown != null)
                    onKeyDown(cast(uint)wParam);
                break;
            case WM_SYSKEYUP:
            case WM_KEYUP:
                if(onKeyUp != null)
                    onKeyUp(cast(uint)wParam);
                break;
            case WM_SIZE: //Resize
            {
                UINT width = LOWORD(lParam);
                UINT height = HIWORD(lParam);
                if(onWindowResize != null)
                    onWindowResize(width, height);
                break;
            }
            case WM_MOVE:
            {
                break;
            }
            case WM_MOUSEMOVE:
            {
                if(onMouseMove != null)
                    onMouseMove(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            }
            case WM_LBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(HipWindowingMouseButton.left, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_MBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(HipWindowingMouseButton.middle, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_RBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(HipWindowingMouseButton.right, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_XBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(
                        GET_XBUTTON_WPARAM(wParam) == XBUTTON1 ? HipWindowingMouseButton.button1 : HipWindowingMouseButton.button2,
                        GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam)
                    );
                break;
            case WM_LBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(HipWindowingMouseButton.left, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_MBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(HipWindowingMouseButton.middle, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_RBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(HipWindowingMouseButton.right, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_XBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(
                        GET_XBUTTON_WPARAM(wParam) == XBUTTON1 ? HipWindowingMouseButton.button1 : HipWindowingMouseButton.button2,
                        GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam)
                    );
                break;
            case WM_MOUSEWHEEL:
                if(onMouseWheel != null)
                    onMouseWheel(
                        HIWORD(wParam), 0
                    );
                break;
            default:
                return DefWindowProc(hwnd, msg, wParam, lParam);
        }
        return 0;
    }

    extern(Windows) nothrow @nogc HGLRC wglCreateContextAttribs(HDC, DWORD, HWND);
    alias wglChoosePixelFormatARBProc = extern(Windows) nothrow @nogc BOOL function(
        HDC hdc, const(int)* piAttribFList, const float* pfAttribIList, uint nMaxFormats,
        int* piFormats, uint* nNumFormats);

    alias wglCreateContextAttribsARBProc = extern(Windows) nothrow @nogc HGLRC function(
        HDC hdc, HGLRC hShareContext,const int* attribList
    );

    alias wglSwapIntervalEXTProc =  extern(Windows) nothrow @nogc int function(int interval);


    wglSwapIntervalEXTProc wglSwapIntervalEXT;
    wglChoosePixelFormatARBProc wglChoosePixelFormatARB;
    wglCreateContextAttribsARBProc wglCreateContextAttribsARB;
    extern(Windows) nothrow @nogc void* wglGetProcAddress(const(char)* funcName);


    extern(Windows) nothrow @nogc bool initializeOpenGL(ref HWND hwnd, int majorVersion, int minorVersion)
    {
        PIXELFORMATDESCRIPTOR pfd =
        {
            PIXELFORMATDESCRIPTOR.sizeof,
            1,
            PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER ,    // Flags
            PFD_TYPE_RGBA,        // The kind of framebuffer. RGBA or palette.
            32,                   // Colordepth of the framebuffer.
            0, 0, 0, 0, 0, 0,
            0,
            0,
            0,
            0, 0, 0, 0,
            24,                   // Number of bits for the depthbuffer
            8,                    // Number of bits for the stencilbuffer
            0,                    // Number of Aux buffers in the framebuffer.
            PFD_MAIN_PLANE,
            0,
            0, 0, 0
        };
        int formatIndex = ChoosePixelFormat(hdc, &pfd);
        if(formatIndex == 0)
        {
            MessageBox(NULL, "Could not choose pixel format!", "Error!", MB_ICONERROR | MB_OK);
            return false;
        }
        if(!SetPixelFormat(hdc, formatIndex, &pfd))
        {
            MessageBox(NULL, "Could not set pixel format!", "Error!", MB_ICONERROR | MB_OK);
            return false;
        }
        glContext = wglCreateContext(hdc);
        if(glContext is null)
        {
            MessageBox(NULL, "Could not create OpenGL Context", "Error!", MB_ICONERROR | MB_OK);
            return false;
        }
        if(!wglMakeCurrent(hdc, glContext))
        {
            MessageBox(NULL, "Coult not set OpenGL Context", "Error!", MB_ICONERROR | MB_OK);
            return false;
        }
        if(majorVersion < 3 && minorVersion < 3) //This is not actually tested
        {
            if(!GetPixelFormat(hdc))
            {
                MessageBox(NULL, "Could not get window pixel format!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                return false;
            }
            if(!DescribePixelFormat(hdc, formatIndex, pfd.sizeof, &pfd))
            {
                MessageBox(NULL, "Could not get describe pixel format!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                return false;
            }
            if((pfd.dwFlags & PFD_SUPPORT_OPENGL) != PFD_SUPPORT_OPENGL)
            {
                MessageBox(NULL, "PixelFormatDescriptor does not support opengl!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                return false;
            }
            return true;
        }
        else
            return initializeModernOpenGL(hwnd, majorVersion, minorVersion);
    }

    package bool initializeModernOpenGL(ref HWND hwnd, int majorVersion, int minorVersion) nothrow @nogc
    {
        //Load Function Pointers
        wglChoosePixelFormatARB = cast(wglChoosePixelFormatARBProc)wglGetProcAddress("wglChoosePixelFormatARB");
        if(wglChoosePixelFormatARB is null)
        {
            MessageBox(NULL, "Could not load wglChoosePixelFormatARB", "Error", MB_ICONERROR | MB_OK);
            return false;
        }
        wglCreateContextAttribsARB = cast(wglCreateContextAttribsARBProc)wglGetProcAddress("wglCreateContextAttribsARB");
        if(wglCreateContextAttribsARB is null)
        {
            MessageBox(NULL, "Could not load wglCreateContextAttribsARB", "Error", MB_ICONERROR | MB_OK);
            return false;
        }
        wglSwapIntervalEXT = cast(wglSwapIntervalEXTProc)wglGetProcAddress("wglSwapIntervalEXT");
        if(wglSwapIntervalEXT is null)
        {
            MessageBox(NULL, "Could not load wglSwapIntervalEXT", "Error", MB_ICONERROR | MB_OK);
            return false;
        }
        //Now, for the modern OpenGL
        const int[19] attribList =
        [
            WGL_DRAW_TO_WINDOW_ARB, true,
            WGL_SUPPORT_OPENGL_ARB, true,
            WGL_DOUBLE_BUFFER_ARB, true,
            WGL_PIXEL_TYPE_ARB, WGL_TYPE_RGBA_ARB,
            WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB,
            WGL_COLOR_BITS_ARB, 32,
            WGL_DEPTH_BITS_ARB, 24,
            WGL_STENCIL_BITS_ARB, 8,
            WGL_ALPHA_BITS_ARB, 8,
            0, // End
        ];

        int pixelFormat;
        uint numFormats;

        if(!wglChoosePixelFormatARB(hdc, attribList.ptr, null, 1, &pixelFormat, &numFormats) || numFormats == 0)
        {
            MessageBox(NULL, "Could notchoose pixel format", "Error", MB_ICONERROR | MB_OK);
            return false;
        }

        auto oldHwnd = hwnd;
        HDC oldHDC = hdc;
        HGLRC oldGLContext = glContext;

        RECT rBorders;
        GetWindowRect(hwnd, &rBorders);
        RECT rNoBorders;
        GetClientRect(hwnd, &rNoBorders);
        RECT r;
        r.left = rBorders.left*2 - rNoBorders.left;
        r.right = rBorders.right*2 - rNoBorders.right;
        r.top = rBorders.top*2 - rNoBorders.top;
        r.bottom = rBorders.bottom*2 - rNoBorders.bottom;
        //Create 
        hwnd = createWindow(r.right - r.left, r.bottom - r.top);

        hdc = GetDC(hwnd);

        PIXELFORMATDESCRIPTOR newPFD;
        DescribePixelFormat(hdc, pixelFormat, newPFD.sizeof, &newPFD);
        SetPixelFormat(hdc, pixelFormat, &newPFD);

        int[7] contextAttribs = 
        [
            WGL_CONTEXT_MAJOR_VERSION_ARB, majorVersion,
            WGL_CONTEXT_MINOR_VERSION_ARB, minorVersion,
            WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
            0
        ];
        glContext = wglCreateContextAttribsARB(hdc, null, contextAttribs.ptr);
        if(glContext is null)
        {
            MessageBox(null, "Could not create Modern OpenGL Context", "Error!", MB_ICONERROR | MB_OK);
            return false;
        }
        wglMakeCurrent(null, null);
        wglDeleteContext(oldGLContext);
        ReleaseDC(oldHwnd, oldHDC);
        DestroyWindow(oldHwnd);
        if(!wglMakeCurrent(hdc, glContext))
        {
            MessageBox(null, "Could not set Modern OpenGL Context", "Error!", MB_ICONERROR | MB_OK);
            return false;
        }
        return true;

    }

    bool registerClass()
    {
        HINSTANCE hInstance = GetModuleHandle(null);
        WNDCLASS wc;
        //Register window class

        wc.style = CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
        wc.lpfnWndProc = &WndProc;
        wc.cbClsExtra = 0;
        wc.cbWndExtra = 0;
        wc.hInstance = hInstance; //Application handle
        wc.hIcon = LoadIcon(null, IDI_APPLICATION); //Big icon
        wc.hCursor = LoadCursor(null, IDC_ARROW); //Cursor
        wc.hbrBackground = cast(HBRUSH)(COLOR_WINDOW); //Background brush
        wc.lpszMenuName = null; //Name of menu resource
        wc.lpszClassName = winClassName; //Name to identify this class of windows

        if(!RegisterClass(cast(const(WNDCLASSW)*)&wc))
        {
            uint err = GetLastError();
            wchar* buffer;
            uint size = FormatMessage(
                FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, 
                cast(void*)null,err, 0, cast(LPWSTR)&buffer, 0, null);
            wstring str = cast(wstring)buffer[0..size];
            MessageBox(NULL, ("Window Registration Failed with message: "~str).ptr, "Error!", MB_ICONEXCLAMATION | MB_OK);
            LocalFree(buffer);
            return false;
        }
        return true;
    }
    package HWND createWindow(int width, int height) @nogc nothrow
    {
        return CreateWindowEx(
            0,
            winClassName,
            winClassName, //Title
            WS_OVERLAPPEDWINDOW | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE,
            CW_USEDEFAULT, CW_USEDEFAULT,
            width, height, HWND_DESKTOP, null, GetModuleHandle(null), null
        );
    }

    extern(Windows) LRESULT openWindow(out HWND hwnd, ref int width, ref int height)
    {
        static bool registeredClass = false;
        if(!registeredClass)
        {
            if(!registerClass())
                return 0;
        }
        hwnd = createWindow(width, height);
        if(hwnd == null)
        {
            MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
            return 0;
        }
        hdc = GetDC(hwnd);
        
        return 1;
    }

    void show(HWND hwnd)
    {
        ShowWindow(hwnd, SW_NORMAL);
        UpdateWindow(hwnd);
    }

    void poll()
    {
        MSG msg;
        while(PeekMessage(&msg, cast(void*)null, 0,0, PM_REMOVE)) //GetMessage may be a lot better 
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    void swapBuffer()
    {
        SwapBuffers(hdc);
    }

    int[2] getWindowSize(HWND hwnd)
    {
        RECT rect;
        GetClientRect(hwnd, &rect);
        return [rect.right - rect.left, rect.bottom - rect.top];
    }
    void setWindowName(HWND hwnd, string name)
    {
        SetWindowTextA(hwnd, name.ptr);
    }
    int[2] getWindowBorder(HWND hwnd)
    {
        RECT rBorders;
        GetWindowRect(hwnd, &rBorders);
        RECT rNoBorders;
        GetClientRect(hwnd, &rNoBorders);
        RECT r;
        r.left = rBorders.left - rNoBorders.left;
        r.right = rBorders.right - rNoBorders.right;
        r.top = rBorders.top - rNoBorders.top;
        r.bottom = rBorders.bottom - rNoBorders.bottom;

        return[r.right - r.left, r.bottom - r.top];
    }

    void setWindowSize(HWND hwnd, int width, int height)
    {
        int[2] borders = getWindowBorder(hwnd);
        SetWindowPos(hwnd, null, 0, 0, width + borders[0], height+borders[1], SWP_NOMOVE);
    }

    void setVsyncActive(bool active) @nogc nothrow @system
    {
        if(wglSwapIntervalEXT !is null)
        {
            wglSwapIntervalEXT(cast(int)active);
        }
    }

    extern(Windows) bool destroy_GL_Context()
    {
        if(!wglMakeCurrent(hdc, null))
        {
            MessageBox(NULL, "Could not detach OpenGL Context!", "Error!", MB_ICONEXCLAMATION | MB_OK);
            return false;
        }
        if(!wglDeleteContext(glContext))
        {
            MessageBox(NULL, "Could not delete OpenGL Context!", "Error!", MB_ICONEXCLAMATION | MB_OK);
            return false;
        }
        glContext = null;
        return true;
    }
}



enum WGL_ARB_pixel_format= 1;
enum WGL_NUMBER_PIXEL_FORMATS_ARB     = 0x2000;
enum WGL_DRAW_TO_WINDOW_ARB           = 0x2001;
enum WGL_DRAW_TO_BITMAP_ARB           = 0x2002;
enum WGL_ACCELERATION_ARB             = 0x2003;
enum WGL_NEED_PALETTE_ARB             = 0x2004;
enum WGL_NEED_SYSTEM_PALETTE_ARB      = 0x2005;
enum WGL_SWAP_LAYER_BUFFERS_ARB       = 0x2006;
enum WGL_SWAP_METHOD_ARB              = 0x2007;
enum WGL_NUMBER_OVERLAYS_ARB          = 0x2008;
enum WGL_NUMBER_UNDERLAYS_ARB         = 0x2009;
enum WGL_TRANSPARENT_ARB              = 0x200A;
enum WGL_TRANSPARENT_RED_VALUE_ARB    = 0x2037;
enum WGL_TRANSPARENT_GREEN_VALUE_ARB  = 0x2038;
enum WGL_TRANSPARENT_BLUE_VALUE_ARB   = 0x2039;
enum WGL_TRANSPARENT_ALPHA_VALUE_ARB  = 0x203A;
enum WGL_TRANSPARENT_INDEX_VALUE_ARB  = 0x203B;
enum WGL_SHARE_DEPTH_ARB              = 0x200C;
enum WGL_SHARE_STENCIL_ARB            = 0x200D;
enum WGL_SHARE_ACCUM_ARB              = 0x200E;
enum WGL_SUPPORT_GDI_ARB              = 0x200F;
enum WGL_SUPPORT_OPENGL_ARB           = 0x2010;
enum WGL_DOUBLE_BUFFER_ARB            = 0x2011;
enum WGL_STEREO_ARB                   = 0x2012;
enum WGL_PIXEL_TYPE_ARB               = 0x2013;
enum WGL_COLOR_BITS_ARB               = 0x2014;
enum WGL_RED_BITS_ARB                 = 0x2015;
enum WGL_RED_SHIFT_ARB                = 0x2016;
enum WGL_GREEN_BITS_ARB               = 0x2017;
enum WGL_GREEN_SHIFT_ARB              = 0x2018;
enum WGL_BLUE_BITS_ARB                = 0x2019;
enum WGL_BLUE_SHIFT_ARB               = 0x201A;
enum WGL_ALPHA_BITS_ARB               = 0x201B;
enum WGL_ALPHA_SHIFT_ARB              = 0x201C;
enum WGL_ACCUM_BITS_ARB               = 0x201D;
enum WGL_ACCUM_RED_BITS_ARB           = 0x201E;
enum WGL_ACCUM_GREEN_BITS_ARB         = 0x201F;
enum WGL_ACCUM_BLUE_BITS_ARB          = 0x2020;
enum WGL_ACCUM_ALPHA_BITS_ARB         = 0x2021;
enum WGL_DEPTH_BITS_ARB               = 0x2022;
enum WGL_STENCIL_BITS_ARB             = 0x2023;
enum WGL_AUX_BUFFERS_ARB              = 0x2024;
enum WGL_NO_ACCELERATION_ARB          = 0x2025;
enum WGL_GENERIC_ACCELERATION_ARB     = 0x2026;
enum WGL_FULL_ACCELERATION_ARB        = 0x2027;
enum WGL_SWAP_EXCHANGE_ARB            = 0x2028;
enum WGL_SWAP_COPY_ARB                = 0x2029;
enum WGL_SWAP_UNDEFINED_ARB           = 0x202A;
enum WGL_TYPE_RGBA_ARB                = 0x202B;
enum WGL_TYPE_COLORINDEX_ARB          = 0x202C;


enum WGL_CONTEXT_MAJOR_VERSION_ARB           = 0x2091;
enum WGL_CONTEXT_MINOR_VERSION_ARB           = 0x2092;
enum WGL_CONTEXT_LAYER_PLANE_ARB             = 0x2093;
enum WGL_CONTEXT_FLAGS_ARB                   = 0x2094;
enum WGL_CONTEXT_PROFILE_MASK_ARB            = 0x9126;


enum WGL_CONTEXT_DEBUG_BIT_ARB               = 0x0001;
enum WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB  = 0x0002;

enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB         = 0x00000001;
enum WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB  = 0x00000002;


enum ERROR_INVALID_VERSION_ARB               = 0x2095;
enum ERROR_INVALID_PROFILE_ARB               = 0x2096;
