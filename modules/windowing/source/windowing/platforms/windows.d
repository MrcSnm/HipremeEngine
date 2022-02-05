module windowing.platforms.windows;
import windowing.input;
import windowing.events;

version(Windows)
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
    pragma(lib, "user32");
    pragma(lib, "kernel32");
    pragma(lib, "user32");


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
                    onKeyDown(cast(wchar)wParam);
                break;
            case WM_SYSKEYUP:
            case WM_KEYUP:
                if(onKeyUp != null)
                    onKeyUp(cast(wchar)wParam);
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
            case WM_LBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(HipMouseButton.left, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_MBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(HipMouseButton.middle, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_RBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(HipMouseButton.right, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_XBUTTONDOWN:
                if(onMouseDown != null)
                    onMouseDown(
                        GET_XBUTTON_WPARAM(wParam) == XBUTTON1 ? HipMouseButton.button1 : HipMouseButton.button2,
                        GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam)
                    );
                break;
            case WM_LBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(HipMouseButton.left, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_MBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(HipMouseButton.middle, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_RBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(HipMouseButton.right, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
                break;
            case WM_XBUTTONUP:
                if(onMouseUp != null)
                    onMouseUp(
                        GET_XBUTTON_WPARAM(wParam) == XBUTTON1 ? HipMouseButton.button1 : HipMouseButton.button2,
                        GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam)
                    );
                break;
            case WM_MOUSEWHEEL:
                break;
            case WM_MOUSEMOVE:
                break;
            default:
                return DefWindowProc(hwnd, msg, wParam, lParam);
        }
        return 0;
    }

    extern(Windows) nothrow @nogc HGLRC wglCreateContextAttribs(HDC, DWORD, HWND);
    extern(Windows) nothrow @nogc BOOL wglChoosePixelFormatARB(
        HDC hdc, const(int)* piAttribFList, const float* pfAttribIList, uint nMaxFormats,
        int* piFormats, uint* nNumFormats
    );
    extern(Windows) nothrow @nogc void* wglGetProcAddress(const(char)* funcName);

    extern(Windows) nothrow @nogc bool initializeOpenGL()
    {
        PIXELFORMATDESCRIPTOR pfd =
        {
            PIXELFORMATDESCRIPTOR.sizeof,
            1,
            PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,    // Flags
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
        SetPixelFormat(hdc, formatIndex, &pfd);
        glContext = wglCreateContext(hdc);
        wglMakeCurrent(hdc, glContext);
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

    extern(Windows) LRESULT openWindow(out HWND hwnd, int width, int height)
    {
        HINSTANCE hInstance = GetModuleHandle(null);
        int nCmdShow = SW_NORMAL;
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
            return 0;
        }
        
        hwnd = CreateWindowEx(
            0,
            winClassName,
            winClassName, //Title
            WS_OVERLAPPEDWINDOW | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE,
            CW_USEDEFAULT, CW_USEDEFAULT,
            width, height, HWND_DESKTOP, null, hInstance, null);
        if(hwnd == null)
        {
            MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
            return 0;
        }
        
        hdc = GetDC(hwnd);
        if(!initializeOpenGL())
            return 0;

        ShowWindow(hwnd, nCmdShow);
        if(!UpdateWindow(hwnd))
        {
            MessageBox(NULL, "Could not update the window!", "Error!", MB_ICONEXCLAMATION | MB_OK);
            return 0;
        }
        
        return 1;
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
