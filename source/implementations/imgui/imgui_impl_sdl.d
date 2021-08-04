
//          Copyright Marcelo S. N. Mancini(Hipreme) 2020.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module implementations.imgui.imgui_impl_sdl;
// SDL

///If false, it will attempt to use the SDL cimgui implementation
enum CIMGUI_USER_DEFINED_IMPLEMENTATION = true;
import bindbc.sdl;

static if(CIMGUI_USER_DEFINED_IMPLEMENTATION)
{
    import bindbc.cimgui;
    import core.stdc.string : memset, strncpy, strncmp;
    version(Windows)
    {
        static if(CIMGUI_VIEWPORT_BRANCH)
        {
            pragma(lib, "user32");
            import core.sys.windows.windows : GetWindowLong, LONG, HWND, SetWindowLong,
                ShowWindow, SW_SHOWNA, GWL_EXSTYLE, WS_EX_APPWINDOW, WS_EX_TOOLWINDOW;
        }
    }

    // // dear imgui: Platform Binding for SDL2
    // // This needs to be used along with a Renderer (e.g. DirectX11, OpenGL3, Vulkan..)
    // // (Info: SDL2 is a cross-platform general purpose library for handling windows, inputs, graphics context creation, etc.)
    // // (Requires: SDL 2.0. Prefer SDL 2.0.4+ for full feature support.)

    // // Implemented features:
    // //  [X] Platform: Mouse cursor shape and visibility. Disable with 'io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange'.
    // //  [X] Platform: Clipboard support.
    // //  [X] Platform: Keyboard arrays indexed using SDL_SCANCODE_* codes, e.g. igIsKeyPressed(SDL_SCANCODE_SPACE).
    // //  [X] Platform: Gamepad support. Enabled with 'io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad'.
    // // Missing features:
    // //  [ ] Platform: SDL2 handling of IME under Windows appears to be broken and it explicitly disable the regular Windows IME. You can restore Windows IME by compiling SDL with SDL_DISABLE_WINDOWS_IME.

    // // You can copy and use unmodified imgui_impl_* files in your project. See main.cpp for an example of using this.
    // // If you are new to dear imgui, read examples/README.txt and read the documentation at the top of imgui.cpp.
    // // https://github.com/ocornut/imgui

    // // CHANGELOG
    // // (minor and older changes stripped away, please see git history for details)
    // //  2020-05-25: Misc: Report a zero display-size when window is minimized, to be consistent with other backends.
    // //  2020-02-20: Inputs: Fixed mapping for ImGuiKey_KeyPadEnter (using SDL_SCANCODE_KP_ENTER instead of SDL_SCANCODE_RETURN2).
    // //  2019-12-17: Inputs: On Wayland, use SDL_GetMouseState (because there is no global mouse state).
    // //  2019-12-05: Inputs: Added support for ImGuiMouseCursor_NotAllowed mouse cursor.
    // //  2019-07-21: Inputs: Added mapping for ImGuiKey_KeyPadEnter.
    // //  2019-04-23: Inputs: Added support for SDL_GameController (if ImGuiConfigFlags_NavEnableGamepad is set by user application).
    // //  2019-03-12: Misc: Preserve DisplayFramebufferScale when main window is minimized.
    // //  2018-12-21: Inputs: Workaround for Android/iOS which don't seem to handle focus related calls.
    // //  2018-11-30: Misc: Setting up io.BackendPlatformName so it can be displayed in the About Window.
    // //  2018-11-14: Changed the signature of ImGui_ImplSDL2_ProcessEvent() to take a 'const SDL_Event*'.
    // //  2018-08-01: Inputs: Workaround for Emscripten which doesn't seem to handle focus related calls.
    // //  2018-06-29: Inputs: Added support for the ImGuiMouseCursor_Hand cursor.
    // //  2018-06-08: Misc: Extracted imgui_impl_sdl.cpp/.h away from the old combined SDL2+OpenGL/Vulkan examples.
    // //  2018-06-08: Misc: ImGui_ImplSDL2_InitForOpenGL() now takes a SDL_GLContext parameter.
    // //  2018-05-09: Misc: Fixed clipboard paste memory leak (we didn't call SDL_FreeMemory on the data returned by SDL_GetClipboardText).
    // //  2018-03-20: Misc: Setup io.BackendFlags ImGuiBackendFlags_HasMouseCursors flag + honor ImGuiConfigFlags_NoMouseCursorChange flag.
    // //  2018-02-16: Inputs: Added support for mouse cursors, honoring igGetMouseCursor() value.
    // //  2018-02-06: Misc: Removed call to igShutdown() which is not available from 1.60 WIP, user needs to call CreateContext/DestroyContext themselves.
    // //  2018-02-06: Inputs: Added mapping for ImGuiKey_Space.
    // //  2018-02-05: Misc: Using SDL_GetPerformanceCounter() instead of SDL_GetTicks() to be able to handle very high framerate (1000+ FPS).
    // //  2018-02-05: Inputs: Keyboard mapping is using scancodes everywhere instead of a confusing mixture of keycodes and scancodes.
    // //  2018-01-20: Inputs: Added Horizontal Mouse Wheel support.
    // //  2018-01-19: Inputs: When available (SDL 2.0.4+) using SDL_CaptureMouse() to retrieve coordinates outside of client area when dragging. Otherwise (SDL 2.0.3 and before) testing for SDL_WINDOW_INPUT_FOCUS instead of SDL_WINDOW_MOUSE_FOCUS.
    // //  2018-01-18: Inputs: Added mapping for ImGuiKey_Insert.
    // //  2017-08-25: Inputs: MousePos set to -FLT_MAX,-FLT_MAX when mouse is unavailable/missing (instead of -1,-1).
    // //  2016-10-15: Misc: Added a void* user_data parameter to Clipboard function handlers.

    enum SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE =     sdlSupport >= SDLSupport.sdl204;
    enum SDL_HAS_WINDOW_ALPHA             =     sdlSupport >= SDLSupport.sdl205;
    enum SDL_HAS_ALWAYS_ON_TOP            =     sdlSupport >= SDLSupport.sdl205;
    enum SDL_HAS_USABLE_DISPLAY_BOUNDS    =     sdlSupport >= SDLSupport.sdl205;
    enum SDL_HAS_PER_MONITOR_DPI          =     sdlSupport >= SDLSupport.sdl204;
    enum SDL_HAS_VULKAN                   =     sdlSupport >= SDLSupport.sdl206;
    enum SDL_HAS_MOUSE_FOCUS_CLICKTHROUGH =     sdlSupport >= SDLSupport.sdl205;

    static if(!SDL_HAS_VULKAN)
    {
        static const Uint32 SDL_WINDOW_VULKAN = 0x10000000;
    }



    // // Data
    static SDL_Window*  g_Window = null;
    static Uint64       g_Time = 0;
    static bool[3]      g_MousePressed = [false, false, false];
    static SDL_Cursor*[ImGuiMouseCursor_COUNT]  g_MouseCursors;
    static char*        g_ClipboardTextData = null;
    static bool         g_MouseCanUseGlobalState = true;

    //Must be an enum right now because I don't wish to bother at vulkan, PR's are welcome to adapting it
    enum                g_UseVulkan = false;


    enum MAP_BUTTON_SDL(ImGuiIO* io,SDL_GameController* game_controller, ulong NAV_NO, SDL_GameControllerButton BUTTON_NO)
    {
        io.NavInputs[NAV_NO] = (SDL_GameControllerGetButton(game_controller, BUTTON_NO) != 0) ? 1.0f : 0.0f;
    }
    enum MAP_ANALOG_SDL(ImGuiIO* io, SDL_GameController* game_controller, ulong NAV_NO, SDL_GameControllerAxis AXIS_NO, int V0, int V1)
    {
        float vn = cast(float)(SDL_GameControllerGetAxis(game_controller, AXIS_NO) - V0) / cast(float)(V1 - V0);
        if (vn > 1.0f) 
            vn = 1.0f; 
        if (vn > 0.0f && io.NavInputs[NAV_NO] < vn) 
            io.NavInputs[NAV_NO] = vn;
    }


    /// SDL_gamecontroller.h suggests using this value.
    enum thumb_dead_zone = 8000;


    extern(C) static const (char)* ImGui_ImplSDL2_GetClipboardText(void*)
    {
        if (g_ClipboardTextData)
            SDL_free(g_ClipboardTextData);
        g_ClipboardTextData = SDL_GetClipboardText();
        return g_ClipboardTextData;
    }


    extern(C) static void ImGui_ImplSDL2_SetClipboardText(void*, const char* text)
    {
        SDL_SetClipboardText(text);
    }

    // // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
    // // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
    // // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
    // // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
    // // If you have multiple SDL events and some of them are not meant to be used by dear imgui, you may need to filter events based on their windowID field.
    bool ImGui_ImplSDL2_ProcessEvent(const SDL_Event* event)
    {
        ImGuiIO* io = igGetIO();

        switch (event.type)
        {
            case SDL_MOUSEWHEEL:
            {
                if (event.wheel.x > 0) io.MouseWheelH += 1;
                if (event.wheel.x < 0) io.MouseWheelH -= 1;
                if (event.wheel.y > 0) io.MouseWheel += 1;
                if (event.wheel.y < 0) io.MouseWheel -= 1;
                return true;
            }
            case SDL_MOUSEBUTTONDOWN:
            {
                if (event.button.button == SDL_BUTTON_LEFT) g_MousePressed[0] = true;
                if (event.button.button == SDL_BUTTON_RIGHT) g_MousePressed[1] = true;
                if (event.button.button == SDL_BUTTON_MIDDLE) g_MousePressed[2] = true;
                return true;
            }
            case SDL_TEXTINPUT:
            {
                ImGuiIO_AddInputCharactersUTF8(io, cast(const (char)*)event.text.text);
                return true;
            }
            case SDL_KEYDOWN:
            case SDL_KEYUP:
            {
                int key = event.key.keysym.scancode;
                IM_ASSERT(key >= 0 && key < IM_ARRAYSIZE(io.KeysDown));
                io.KeysDown[key] = (event.type == SDL_KEYDOWN);
                io.KeyShift = ((SDL_GetModState() & KMOD_SHIFT) != 0);
                io.KeyCtrl = ((SDL_GetModState() & KMOD_CTRL) != 0);
                io.KeyAlt = ((SDL_GetModState() & KMOD_ALT) != 0);
                version(Windows)
                {
                    io.KeySuper = false;
                }
                else
                {
                    io.KeySuper = ((SDL_GetModState() & KMOD_GUI) != 0);
                }
                return true;
            }
            static if(CIMGUI_VIEWPORT_BRANCH)
            {
                case SDL_WINDOWEVENT:
                    Uint8 window_event = event.window.event;
                    if (window_event == SDL_WINDOWEVENT_CLOSE || window_event == SDL_WINDOWEVENT_MOVED || window_event == SDL_WINDOWEVENT_RESIZED)
                        if (ImGuiViewport* viewport = igFindViewportByPlatformHandle(cast(void*)SDL_GetWindowFromID(event.window.windowID)))
                        {
                            if (window_event == SDL_WINDOWEVENT_CLOSE)
                                viewport.PlatformRequestClose = true;
                            if (window_event == SDL_WINDOWEVENT_MOVED)
                                viewport.PlatformRequestMove = true;
                            if (window_event == SDL_WINDOWEVENT_RESIZED)
                                viewport.PlatformRequestResize = true;
                            return true;
                        }
                    break;
            }
            default:break;
        }
        return false;
    }

    static bool ImGui_ImplSDL2_Init(SDL_Window* window, void* sdl_gl_context)
    {
        g_Window = window;

        // Setup back-end capabilities flags
        ImGuiIO* io = igGetIO();
        io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;       // We can honor GetMouseCursor() values (optional)

        //Viewport specific code
        static if(SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE)
        {
            io.BackendFlags |= ImGuiBackendFlags_PlatformHasViewports;
        }
        else //This code was deleted on viewport branch
        {
            io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;        // We can honor io.WantSetMousePos requests (optional, rarely used)
        }
        io.BackendPlatformName = "imgui_impl_sdl";

        // Keyboard mapping. ImGui will use those indices to peek into the io.KeysDown[] array.
        io.KeyMap[ImGuiKey_Tab] = SDL_SCANCODE_TAB;
        io.KeyMap[ImGuiKey_LeftArrow] = SDL_SCANCODE_LEFT;
        io.KeyMap[ImGuiKey_RightArrow] = SDL_SCANCODE_RIGHT;
        io.KeyMap[ImGuiKey_UpArrow] = SDL_SCANCODE_UP;
        io.KeyMap[ImGuiKey_DownArrow] = SDL_SCANCODE_DOWN;
        io.KeyMap[ImGuiKey_PageUp] = SDL_SCANCODE_PAGEUP;
        io.KeyMap[ImGuiKey_PageDown] = SDL_SCANCODE_PAGEDOWN;
        io.KeyMap[ImGuiKey_Home] = SDL_SCANCODE_HOME;
        io.KeyMap[ImGuiKey_End] = SDL_SCANCODE_END;
        io.KeyMap[ImGuiKey_Insert] = SDL_SCANCODE_INSERT;
        io.KeyMap[ImGuiKey_Delete] = SDL_SCANCODE_DELETE;
        io.KeyMap[ImGuiKey_Backspace] = SDL_SCANCODE_BACKSPACE;
        io.KeyMap[ImGuiKey_Space] = SDL_SCANCODE_SPACE;
        io.KeyMap[ImGuiKey_Enter] = SDL_SCANCODE_RETURN;
        io.KeyMap[ImGuiKey_Escape] = SDL_SCANCODE_ESCAPE;
        io.KeyMap[ImGuiKey_KeyPadEnter] = SDL_SCANCODE_KP_ENTER;
        io.KeyMap[ImGuiKey_A] = SDL_SCANCODE_A;
        io.KeyMap[ImGuiKey_C] = SDL_SCANCODE_C;
        io.KeyMap[ImGuiKey_V] = SDL_SCANCODE_V;
        io.KeyMap[ImGuiKey_X] = SDL_SCANCODE_X;
        io.KeyMap[ImGuiKey_Y] = SDL_SCANCODE_Y;
        io.KeyMap[ImGuiKey_Z] = SDL_SCANCODE_Z;

        io.SetClipboardTextFn = &ImGui_ImplSDL2_SetClipboardText;
        io.GetClipboardTextFn = &ImGui_ImplSDL2_GetClipboardText;
        io.ClipboardUserData = null;

        // Load mouse cursors
        g_MouseCursors[ImGuiMouseCursor_Arrow] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW);
        g_MouseCursors[ImGuiMouseCursor_TextInput] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_IBEAM);
        g_MouseCursors[ImGuiMouseCursor_ResizeAll] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL);
        g_MouseCursors[ImGuiMouseCursor_ResizeNS] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENS);
        g_MouseCursors[ImGuiMouseCursor_ResizeEW] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE);
        g_MouseCursors[ImGuiMouseCursor_ResizeNESW] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENESW);
        g_MouseCursors[ImGuiMouseCursor_ResizeNWSE] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENWSE);
        g_MouseCursors[ImGuiMouseCursor_Hand] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_HAND);
        g_MouseCursors[ImGuiMouseCursor_NotAllowed] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_NO);

        // Check and store if we are on Wayland
        g_MouseCanUseGlobalState = strncmp(SDL_GetCurrentVideoDriver(), "wayland", 7) != 0;

        static if(CIMGUI_VIEWPORT_BRANCH)
        {
            ImGuiViewport* main_viewport = igGetMainViewport();
            main_viewport.PlatformHandle = cast(void*)window;
        }

        version(Windows)
        {
            SDL_SysWMinfo wmInfo;
            SDL_VERSION(&wmInfo.version_);
            static if(CIMGUI_VIEWPORT_BRANCH)
            {
                if(SDL_GetWindowWMInfo(window, &wmInfo))
                {
                    main_viewport.PlatformHandleRaw = wmInfo.info.win.window;
                }
            }
            else
            {
                SDL_GetWindowWMInfo(window, &wmInfo);
                //io.ImeWindowHandle = wmInfo.info.win.window;
            }
        }

        static if(CIMGUI_VIEWPORT_BRANCH)
        {
            ImGui_ImplSDL2_UpdateMonitors();
            // We need SDL_CaptureMouse(), SDL_GetGlobalMouseState() from SDL 2.0.4+ to support multiple viewports.
            // We left the call to ImGui_ImplSDL2_InitPlatformInterface() outside of static if(ef to avoid unused-function warnings.)
            if ((io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) && (io.BackendFlags & ImGuiBackendFlags_PlatformHasViewports))
            {
                ImGui_ImplSDL2_InitPlatformInterface(window, sdl_gl_context);
            }
        }
        else
        {
            cast(void)window;
        }
        return true;
    }

    bool ImGui_ImplSDL2_InitForOpenGL(SDL_Window* window, void* sdl_gl_context)
    {
        cast(void)sdl_gl_context; // Viewport branch will need this.
        return ImGui_ImplSDL2_Init(window, sdl_gl_context);
    }

    bool ImGui_ImplSDL2_InitForVulkan(SDL_Window* window)
    {
        static if(!SDL_HAS_VULKAN)
        {
            IM_ASSERT(0, "Unsupported");
        }
        return ImGui_ImplSDL2_Init(window, null);
    }

    bool ImGui_ImplSDL2_InitForD3D(SDL_Window* window)
    {
        version(Windows){}
        else
        {
            IM_ASSERT(0, "Unsupported");
        }
        return ImGui_ImplSDL2_Init(window, null);
    }

    bool ImGui_ImplSDL2_InitForMetal(SDL_Window* window)
    {
        return ImGui_ImplSDL2_Init(window, null);
    }

    void ImGui_ImplSDL2_Shutdown()
    {
        static if(CIMGUI_VIEWPORT_BRANCH)
            ImGui_ImplSDL2_ShutdownPlatformInterface();
        g_Window = null;
        // Destroy last known clipboard data
        if (g_ClipboardTextData)
            SDL_free(g_ClipboardTextData);
        g_ClipboardTextData = null;

        // Destroy SDL mouse cursors
        for (ImGuiMouseCursor cursor_n = 0; cursor_n < ImGuiMouseCursor_COUNT; cursor_n++)
            SDL_FreeCursor(g_MouseCursors[cursor_n]);
        memset(cast(void*)g_MouseCursors, 0, g_MouseCursors.sizeof);
    }

    static void ImGui_ImplSDL2_UpdateMousePosAndButtons()
    {
        ImGuiIO* io = igGetIO();
        // Set OS mouse position if requested (rarely used, only when ImGuiConfigFlags_NavEnableSetMousePos is enabled by user)
        static if(!CIMGUI_VIEWPORT_BRANCH)
        {
            if (io.WantSetMousePos)
                SDL_WarpMouseInWindow(g_Window, cast(int)io.MousePos.x, cast(int)io.MousePos.y);
            else
                io.MousePos = ImVec2(-igGET_FLT_MAX(), -igGET_FLT_MAX());
        }
        else
        {
            io.MouseHoveredViewport = 0;
            if (io.WantSetMousePos)
            {
                static if(SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE)
                {
                    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
                        SDL_WarpMouseGlobal(cast(int)io.MousePos.x, cast(int)io.MousePos.y);
                    else
                        SDL_WarpMouseInWindow(g_Window, cast(int)io.MousePos.x, cast(int)io.MousePos.y);
                }
                else
                    SDL_WarpMouseInWindow(g_Window, cast(int)io.MousePos.x, cast(int)io.MousePos.y);
            }
            else
                io.MousePos = ImVec2(-igGET_FLT_MAX(), -igGET_FLT_MAX());
        }

        int mx, my;
        Uint32 mouse_buttons = SDL_GetMouseState(&mx, &my);
        io.MouseDown[0] = g_MousePressed[0] || (mouse_buttons & SDL_BUTTON!SDL_BUTTON_LEFT) != 0;  // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
        io.MouseDown[1] = g_MousePressed[1] || (mouse_buttons & SDL_BUTTON!SDL_BUTTON_RIGHT) != 0;
        io.MouseDown[2] = g_MousePressed[2] || (mouse_buttons & SDL_BUTTON!SDL_BUTTON_MIDDLE) != 0;
        g_MousePressed[0] = g_MousePressed[1] = g_MousePressed[2] = false;

        static if(SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE)
        {
            static if(!CIMGUI_VIEWPORT_BRANCH) //Mantaining compatibility with non docking branch
            {
                SDL_Window* focused_window = SDL_GetKeyboardFocus();
                if (g_Window == focused_window)
                {
                    if (g_MouseCanUseGlobalState)
                    {
                        // SDL_GetMouseState() gives mouse position seemingly based on the last window entered/focused(?)
                        // The creation of a new windows at runtime and SDL_CaptureMouse both seems to severely mess up with that, so we retrieve that position globally.
                        // Won't use this workaround when on Wayland, as there is no global mouse position.
                        int wx, wy;
                        SDL_GetWindowPosition(focused_window, &wx, &wy);
                        SDL_GetGlobalMouseState(&mx, &my);
                        mx -= wx;
                        my -= wy;
                    }
                    io.MousePos = ImVec2(cast(float)mx, cast(float)my);
                }
            }
            else
            {
                if (g_MouseCanUseGlobalState)
                {
                    // SDL 2.0.4 and later has SDL_GetGlobalMouseState() and SDL_CaptureMouse()
                    int mouse_x_global, mouse_y_global;
                    SDL_GetGlobalMouseState(&mouse_x_global, &mouse_y_global);

                    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
                    {
                        // Multi-viewport mode: mouse position in OS absolute coordinates (io.MousePos is (0,0) when the mouse is on the upper-left of the primary monitor)
                        if (SDL_Window* focused_window = SDL_GetKeyboardFocus())
                            if (igFindViewportByPlatformHandle(cast(void*)focused_window) != null)
                                io.MousePos = ImVec2(cast(float)mouse_x_global, cast(float)mouse_y_global);
                    }
                    else
                    {
                        // Single-viewport mode: mouse position in client window coordinatesio.MousePos is (0,0) when the mouse is on the upper-left corner of the app window)
                        if (SDL_GetWindowFlags(g_Window) & SDL_WINDOW_INPUT_FOCUS)
                        {
                            int window_x, window_y;
                            SDL_GetWindowPosition(g_Window, &window_x, &window_y);
                            io.MousePos = ImVec2(cast(float)(mouse_x_global - window_x), cast(float)(mouse_y_global - window_y));
                        }
                    }
                }
                else
                {
                    if (SDL_GetWindowFlags(g_Window) & SDL_WINDOW_INPUT_FOCUS)
                        io.MousePos = ImVec2(cast(float)mx, cast(float)my);
                }
            }
            // SDL_CaptureMouse() let the OS know e.g. that our imgui drag outside the SDL window boundaries shouldn't e.g. trigger the OS window resize cursor.
            // The function is only supported from SDL 2.0.4 (released Jan 2016)
            bool any_mouse_button_down = igIsAnyMouseDown();
            SDL_CaptureMouse(any_mouse_button_down ? SDL_TRUE : SDL_FALSE);
        }
        else
        {
            if (SDL_GetWindowFlags(g_Window) & SDL_WINDOW_INPUT_FOCUS)
                io.MousePos = ImVec2(cast(float)mx, cast(float)my);
        }
    }

    static void ImGui_ImplSDL2_UpdateMouseCursor()
    {
        ImGuiIO* io = igGetIO();
        if (io.ConfigFlags & ImGuiConfigFlags_NoMouseCursorChange)
            return;

        ImGuiMouseCursor imgui_cursor = igGetMouseCursor();
        if (io.MouseDrawCursor || imgui_cursor == ImGuiMouseCursor_None)
        {
            // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
            SDL_ShowCursor(SDL_FALSE);
        }
        else
        {
            // Show OS mouse cursor
            SDL_SetCursor(g_MouseCursors[imgui_cursor] ? g_MouseCursors[imgui_cursor] : g_MouseCursors[ImGuiMouseCursor_Arrow]);
            SDL_ShowCursor(SDL_TRUE);
        }
    }

    static void ImGui_ImplSDL2_UpdateGamepads()
    {
        ImGuiIO* io = igGetIO();
        memset(cast(void*)io.NavInputs, 0, io.NavInputs.sizeof);
        if ((io.ConfigFlags & ImGuiConfigFlags_NavEnableGamepad) == 0) 
            return;

        // Get gamepad
        SDL_GameController* game_controller = SDL_GameControllerOpen(0);
        if (!game_controller)
        {
            io.BackendFlags &= ~ImGuiBackendFlags_HasGamepad;
            return;
        }

        // Update gamepad inputs
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_Activate,      SDL_CONTROLLER_BUTTON_A);               // Cross / A
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_Cancel,        SDL_CONTROLLER_BUTTON_B);               // Circle / B
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_Menu,          SDL_CONTROLLER_BUTTON_X);               // Square / X
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_Input,         SDL_CONTROLLER_BUTTON_Y);               // Triangle / Y
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_DpadLeft,      SDL_CONTROLLER_BUTTON_DPAD_LEFT);       // D-Pad Left
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_DpadRight,     SDL_CONTROLLER_BUTTON_DPAD_RIGHT);      // D-Pad Right
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_DpadUp,        SDL_CONTROLLER_BUTTON_DPAD_UP);         // D-Pad Up
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_DpadDown,      SDL_CONTROLLER_BUTTON_DPAD_DOWN);       // D-Pad Down
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_FocusPrev,     SDL_CONTROLLER_BUTTON_LEFTSHOULDER);    // L1 / LB
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_FocusNext,     SDL_CONTROLLER_BUTTON_RIGHTSHOULDER);   // R1 / RB
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_TweakSlow,     SDL_CONTROLLER_BUTTON_LEFTSHOULDER);    // L1 / LB
        MAP_BUTTON_SDL(io,game_controller,ImGuiNavInput_TweakFast,     SDL_CONTROLLER_BUTTON_RIGHTSHOULDER);   // R1 / RB
        MAP_ANALOG_SDL(io,game_controller,ImGuiNavInput_LStickLeft,    SDL_CONTROLLER_AXIS_LEFTX, -thumb_dead_zone, -32_768);
        MAP_ANALOG_SDL(io,game_controller,ImGuiNavInput_LStickRight,   SDL_CONTROLLER_AXIS_LEFTX, +thumb_dead_zone, +32_767);
        MAP_ANALOG_SDL(io,game_controller,ImGuiNavInput_LStickUp,      SDL_CONTROLLER_AXIS_LEFTY, -thumb_dead_zone, -32_767);
        MAP_ANALOG_SDL(io,game_controller,ImGuiNavInput_LStickDown,    SDL_CONTROLLER_AXIS_LEFTY, +thumb_dead_zone, +32_767);

        io.BackendFlags |= ImGuiBackendFlags_HasGamepad;
    }

    void ImGui_ImplSDL2_NewFrame(SDL_Window* window)
    {
        ImGuiIO* io = igGetIO();
        IM_ASSERT(ImFontAtlas_IsBuilt(io.Fonts), "Font atlas not built! It is generally built by the renderer back-end. Missing call to renderer _NewFrame() function? e.g. ImGui_ImplOpenGL3_NewFrame().");

        // Setup display size (every frame to accommodate for window resizing)
        int w, h;
        int display_w, display_h;
        SDL_GetWindowSize(window, &w, &h);
        if (SDL_GetWindowFlags(window) & SDL_WINDOW_MINIMIZED)
            w = h = 0;
        SDL_GL_GetDrawableSize(window, &display_w, &display_h);
        io.DisplaySize = ImVec2(cast(float)w, cast(float)h);
        if (w > 0 && h > 0)
            io.DisplayFramebufferScale = ImVec2(cast(float)display_w / w, cast(float)display_h / h);

        // Setup time step (we don't use SDL_GetTicks() because it is using millisecond resolution)
        static if(staticBinding) //Won't be supporting it any early
        {
            static Uint64 frequency = SDL_GetPerformanceFrequency();
        }
        else
        {
            Uint64 frequency = SDL_GetPerformanceFrequency();
        }
        Uint64 current_time = SDL_GetPerformanceCounter();
        io.DeltaTime = g_Time > 0 ? cast(float)(cast(double)(current_time - g_Time) / frequency) : cast(float)(1.0f / 60.0f);
        g_Time = current_time;

        ImGui_ImplSDL2_UpdateMousePosAndButtons();
        ImGui_ImplSDL2_UpdateMouseCursor();

        // Update game controllers (if enabled and available)
        ImGui_ImplSDL2_UpdateGamepads();
    }

    //Starting viewport branch support
    static if(CIMGUI_VIEWPORT_BRANCH)
    {
        static void ImGui_ImplSDL2_UpdateMonitors()
        {
            ImGuiPlatformIO* platform_io = igGetPlatformIO();
            ImVector_resize!ImVector_ImGuiPlatformMonitor(platform_io.Monitors, 0); //ImVector function, should be probably implemented
            int display_count = SDL_GetNumVideoDisplays();
            for (int n = 0; n < display_count; n++)
            {
                // Warning: the validity of monitor DPI information on Windows depends on the application DPI awareness settings, which generally needs to be set in the manifest or at runtime.
                ImGuiPlatformMonitor monitor;
                SDL_Rect r;
                SDL_GetDisplayBounds(n, &r);
                monitor.MainPos = monitor.WorkPos = ImVec2(cast(float)r.x, cast(float)r.y);
                monitor.MainSize = monitor.WorkSize = ImVec2(cast(float)r.w, cast(float)r.h);
                static if(SDL_HAS_USABLE_DISPLAY_BOUNDS)
                {
                    SDL_GetDisplayUsableBounds(n, &r);
                    monitor.WorkPos = ImVec2(cast(float)r.x, cast(float)r.y);
                    monitor.WorkSize = ImVec2(cast(float)r.w, cast(float)r.h);
                }
                static if(SDL_HAS_PER_MONITOR_DPI)
                {
                    float dpi = 0.0f;
                    if (!SDL_GetDisplayDPI(n, &dpi, null, null))
                        monitor.DpiScale = dpi / 96.0f;
                }
                ImVector_push_back!ImVector_ImGuiPlatformMonitor(platform_io.Monitors, monitor);
            }
        }

        extern(C) struct ImGuiViewportDataSDL2
        {
            SDL_Window*     Window;
            Uint32          WindowID;
            bool            WindowOwned;
            SDL_GLContext   GLContext;

            // ~this() 
            // {
            //    IM_ASSERT(Window == null && GLContext == null, "Null Reference"); 
            // }
        }

        extern(C) static void ImGui_ImplSDL2_CreateWindow(ImGuiViewport* viewport)
        {
            //ImGuiViewportDataSDL2* data = IM_NEW!ImGuiViewportDataSDL2;

            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)igMemAlloc(ImGuiViewportDataSDL2.sizeof);
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;


            ImGuiViewport* main_viewport = igGetMainViewport();
            ImGuiViewportDataSDL2* main_viewport_data = cast(ImGuiViewportDataSDL2*)main_viewport.PlatformUserData;

            // Share GL resources with main context
            bool use_opengl = (main_viewport_data.GLContext != null);
            SDL_GLContext backup_context = null;
            if (use_opengl)
            {
                backup_context = SDL_GL_GetCurrentContext();
                SDL_GL_SetAttribute(SDL_GL_SHARE_WITH_CURRENT_CONTEXT, 1);
                SDL_GL_MakeCurrent(main_viewport_data.Window, main_viewport_data.GLContext);
            }

            Uint32 sdl_flags = 0;
            sdl_flags |= use_opengl ? SDL_WINDOW_OPENGL : (g_UseVulkan ? SDL_WINDOW_VULKAN : 0);
            sdl_flags |= SDL_GetWindowFlags(g_Window) & SDL_WINDOW_ALLOW_HIGHDPI;
            sdl_flags |= SDL_WINDOW_HIDDEN;
            sdl_flags |= (viewport.Flags & ImGuiViewportFlags_NoDecoration) ? SDL_WINDOW_BORDERLESS : 0;
            sdl_flags |= (viewport.Flags & ImGuiViewportFlags_NoDecoration) ? 0 : SDL_WINDOW_RESIZABLE;
            version(Windows)
            {
                // See SDL hack in ImGui_ImplSDL2_ShowWindow().
                sdl_flags |= (viewport.Flags & ImGuiViewportFlags_NoTaskBarIcon) ? SDL_WINDOW_SKIP_TASKBAR : 0;
            }
            static if(SDL_HAS_ALWAYS_ON_TOP)
            {
                sdl_flags |= (viewport.Flags & ImGuiViewportFlags_TopMost) ? SDL_WINDOW_ALWAYS_ON_TOP : 0;
            }
            //Should declare SDL_WindowFlags as an uint
            data.Window = SDL_CreateWindow("No Title Yet".ptr, cast(int)viewport.Pos.x, cast(int)viewport.Pos.y, cast(int)viewport.Size.x, cast(int)viewport.Size.y, cast(SDL_WindowFlags)sdl_flags);
            data.WindowOwned = true;
            if (use_opengl)
            {
                data.GLContext = SDL_GL_CreateContext(data.Window);
                SDL_GL_SetSwapInterval(0);
            }
            if (use_opengl && backup_context)
                SDL_GL_MakeCurrent(data.Window, backup_context);

            viewport.PlatformHandle = cast(void*)data.Window;
            version(Windows)
            {
                SDL_SysWMinfo info;
                SDL_VERSION(&info.version_);
                if (SDL_GetWindowWMInfo(data.Window, &info))
                    viewport.PlatformHandleRaw = info.info.win.window;
            }
            viewport.PlatformUserData = data;
        }

        extern(C) static void ImGui_ImplSDL2_DestroyWindow(ImGuiViewport* viewport)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            if (ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData)
            {
                if (data.GLContext && data.WindowOwned)
                    SDL_GL_DeleteContext(data.GLContext);
                if (data.Window && data.WindowOwned)
                    SDL_DestroyWindow(data.Window);
                data.GLContext = null;
                data.Window = null;
                IM_DELETE(data);
            }
            viewport.PlatformUserData = viewport.PlatformHandle = null;
        }

        extern(C) static void ImGui_ImplSDL2_ShowWindow(ImGuiViewport* viewport)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            version(Windows)
            {
                HWND hwnd = cast(HWND)viewport.PlatformHandleRaw;

                // SDL hack: Hide icon from task bar
                // Note: SDL 2.0.6+ has a SDL_WINDOW_SKIP_TASKBAR flag which is supported under Windows but the way it create the window breaks our seamless transition.
                if (viewport.Flags & ImGuiViewportFlags_NoTaskBarIcon)
                {
                    LONG ex_style = GetWindowLong(hwnd, GWL_EXSTYLE);
                    ex_style &= ~WS_EX_APPWINDOW;
                    ex_style |= WS_EX_TOOLWINDOW;
                    SetWindowLong(hwnd, GWL_EXSTYLE, ex_style);
                }

                // SDL hack: SDL always activate/focus windows :/
                if (viewport.Flags & ImGuiViewportFlags_NoFocusOnAppearing)
                {
                    ShowWindow(hwnd, SW_SHOWNA);
                    return;
                }
            }
            
            SDL_ShowWindow(data.Window);
        }

        extern(C) static void ImGui_ImplSDL2_GetWindowPos(ImGuiViewport* viewport, ImVec2* _out_vec)
        {
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            int x = 0, y = 0;
            SDL_GetWindowPosition(data.Window, &x, &y);
            _out_vec.x = cast(float)x;
            _out_vec.y = cast(float)y;
        }

        extern(C) static void ImGui_ImplSDL2_SetWindowPos(ImGuiViewport* viewport, ImVec2 pos)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            SDL_SetWindowPosition(data.Window, cast(int)pos.x, cast(int)pos.y);
        }

        extern(C) static void ImGui_ImplSDL2_GetWindowSize(ImGuiViewport* viewport, ImVec2* _out_vec)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            int w = 0, h = 0;
            SDL_GetWindowSize(data.Window, &w, &h);
            _out_vec.x = cast(float)w;
            _out_vec.y = cast(float)h;
        }

        extern(C) static void ImGui_ImplSDL2_SetWindowSize(ImGuiViewport* viewport, ImVec2 size)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            SDL_SetWindowSize(data.Window, cast(int)size.x, cast(int)size.y);
        }

        extern(C) static void ImGui_ImplSDL2_SetWindowTitle(ImGuiViewport* viewport, const (char)* title)
        {
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            SDL_SetWindowTitle(data.Window, title);
        }

        static if(SDL_HAS_WINDOW_ALPHA)
        {
            extern(C) static void ImGui_ImplSDL2_SetWindowAlpha(ImGuiViewport* viewport, float alpha)
            {
                //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
                ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
                SDL_SetWindowOpacity(data.Window, alpha);
            }
        }

        extern(C) static void ImGui_ImplSDL2_SetWindowFocus(ImGuiViewport* viewport)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            SDL_RaiseWindow(data.Window);
        }

        extern(C) static bool ImGui_ImplSDL2_GetWindowFocus(ImGuiViewport* viewport)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            return (SDL_GetWindowFlags(data.Window) & SDL_WINDOW_INPUT_FOCUS) != 0;
        }

        extern(C) static bool ImGui_ImplSDL2_GetWindowMinimized(ImGuiViewport* viewport)
        {
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            return (SDL_GetWindowFlags(data.Window) & SDL_WINDOW_MINIMIZED) != 0;
        }

        extern(C) static void ImGui_ImplSDL2_RenderWindow(ImGuiViewport* viewport, void*)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            if (data.GLContext)
              SDL_GL_MakeCurrent(data.Window, data.GLContext);
        }

        extern(C) static void ImGui_ImplSDL2_SwapBuffers(ImGuiViewport* viewport, void*)
        {
            //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
            ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
            if (data.GLContext)
            {
                SDL_GL_MakeCurrent(data.Window, data.GLContext);
                SDL_GL_SwapWindow(data.Window);
            }
        }

        static if(SDL_HAS_VULKAN && g_UseVulkan)
        {
            import bindbc.vulkan; //Don't know if it is already there
            extern(C) static int ImGui_ImplSDL2_CreateVkSurface(ImGuiViewport* viewport, ImU64 vk_instance, const void* vk_allocator, ImU64* out_vk_surface)
            {
                //ImGuiViewport* viewport = &viewportp._ImGuiViewport;
                ImGuiViewportDataSDL2* data = cast(ImGuiViewportDataSDL2*)viewport.PlatformUserData;
                cast(void)vk_allocator;
                SDL_bool ret = SDL_Vulkan_CreateSurface(data.Window, cast(VkInstance)vk_instance, cast(VkSurfaceKHR*)out_vk_surface);
                return ret ? 0 : 1; // ret ? VK_SUCCESS : VK_NOT_READY
            }
        }
        extern(C) static void ImGui_ImplSDL2_InitPlatformInterface(SDL_Window* window, void* sdl_gl_context)
        {
            // Register platform interface (will be coupled with a renderer interface)
            
            ImGuiPlatformIO* platform_io = igGetPlatformIO();

            platform_io.Platform_CreateWindow = &ImGui_ImplSDL2_CreateWindow;
            platform_io.Platform_DestroyWindow = &ImGui_ImplSDL2_DestroyWindow;
            platform_io.Platform_ShowWindow = &ImGui_ImplSDL2_ShowWindow;
            platform_io.Platform_SetWindowPos = &ImGui_ImplSDL2_SetWindowPos;

            ImGuiPlatformIO_Set_Platform_GetWindowPos(platform_io, &ImGui_ImplSDL2_GetWindowPos);
            // platform_io.Platform_GetWindowPos = &ImGui_ImplSDL2_GetWindowPos;
            platform_io.Platform_SetWindowSize = &ImGui_ImplSDL2_SetWindowSize;
            // platform_io.Platform_GetWindowSize = &ImGui_ImplSDL2_GetWindowSize;
            ImGuiPlatformIO_Set_Platform_GetWindowSize(platform_io, &ImGui_ImplSDL2_GetWindowSize);
            platform_io.Platform_SetWindowFocus = &ImGui_ImplSDL2_SetWindowFocus;
            platform_io.Platform_GetWindowFocus = &ImGui_ImplSDL2_GetWindowFocus;
            platform_io.Platform_GetWindowMinimized = &ImGui_ImplSDL2_GetWindowMinimized;
            platform_io.Platform_SetWindowTitle = &ImGui_ImplSDL2_SetWindowTitle;
            platform_io.Platform_RenderWindow = &ImGui_ImplSDL2_RenderWindow;
            platform_io.Platform_SwapBuffers = &ImGui_ImplSDL2_SwapBuffers;
            static if(SDL_HAS_WINDOW_ALPHA)
            {
                platform_io.Platform_SetWindowAlpha = &ImGui_ImplSDL2_SetWindowAlpha;
            }
            static if(SDL_HAS_VULKAN && g_UseVulkan)
            {
                platform_io.Platform_CreateVkSurface = &ImGui_ImplSDL2_CreateVkSurface;
            }

            // SDL2 by default doesn't pass mouse clicks to the application when the click focused a window. This is getting in the way of our interactions and we disable that behavior.
            static if(SDL_HAS_MOUSE_FOCUS_CLICKTHROUGH)
            {
                SDL_SetHint(SDL_HINT_MOUSE_FOCUS_CLICKTHROUGH, "1");
            }

            // Register main window handle (which is owned by the main application, not by us)
            // This is mostly for simplicity and consistency, so that our code (e.g. mouse handling etc.) can use same logic for main and secondary viewports.
            ImGuiViewport* main_viewport = igGetMainViewport();
            ImGuiViewportDataSDL2* data = IM_NEW!ImGuiViewportDataSDL2;
            data.Window = window;
            data.WindowID = SDL_GetWindowID(window);
            data.WindowOwned = false;
            data.GLContext = sdl_gl_context;
            main_viewport.PlatformUserData = data;
            main_viewport.PlatformHandle = data.Window;
            
        }

        static void ImGui_ImplSDL2_ShutdownPlatformInterface()
        {
        }

    }
}
else //Uses DLL
{
    import bindbc.loader : SharedLib, bindSymbol;
    extern(C) @nogc nothrow
    {
        alias pImGui_ImplSDL2_InitForOpenGL = bool function(SDL_Window* window,void* sdl_gl_context);
        alias pImGui_ImplSDL2_InitForVulkan = bool function(SDL_Window* window);
        alias pImGui_ImplSDL2_InitForD3D = bool function(SDL_Window* window);
        alias pImGui_ImplSDL2_InitForMetal = bool function(SDL_Window* window);
        alias pImGui_ImplSDL2_Shutdown = void function();
        alias pImGui_ImplSDL2_NewFrame = void function(SDL_Window* window);
        alias pImGui_ImplSDL2_ProcessEvent = bool function(const SDL_Event* event);
    }

    __gshared
    {
        pImGui_ImplSDL2_InitForOpenGL ImGui_ImplSDL2_InitForOpenGL;
        pImGui_ImplSDL2_InitForVulkan ImGui_ImplSDL2_InitForVulkan;
        pImGui_ImplSDL2_InitForD3D ImGui_ImplSDL2_InitForD3D;
        pImGui_ImplSDL2_InitForMetal ImGui_ImplSDL2_InitForMetal;
        pImGui_ImplSDL2_Shutdown ImGui_ImplSDL2_Shutdown;
        pImGui_ImplSDL2_NewFrame ImGui_ImplSDL2_NewFrame;
        pImGui_ImplSDL2_ProcessEvent ImGui_ImplSDL2_ProcessEvent;
    }
    void bindSDLImgui(SharedLib lib)
    {
        lib.bindSymbol(cast(void**)&ImGui_ImplSDL2_InitForOpenGL, "ImGui_ImplSDL2_InitForOpenGL");
        lib.bindSymbol(cast(void**)&ImGui_ImplSDL2_InitForVulkan, "ImGui_ImplSDL2_InitForVulkan");
        lib.bindSymbol(cast(void**)&ImGui_ImplSDL2_InitForD3D, "ImGui_ImplSDL2_InitForD3D");
        lib.bindSymbol(cast(void**)&ImGui_ImplSDL2_InitForMetal, "ImGui_ImplSDL2_InitForMetal");
        lib.bindSymbol(cast(void**)&ImGui_ImplSDL2_Shutdown, "ImGui_ImplSDL2_Shutdown");
        lib.bindSymbol(cast(void**)&ImGui_ImplSDL2_NewFrame, "ImGui_ImplSDL2_NewFrame");
        lib.bindSymbol(cast(void**)&ImGui_ImplSDL2_ProcessEvent, "ImGui_ImplSDL2_ProcessEvent");
    }

}