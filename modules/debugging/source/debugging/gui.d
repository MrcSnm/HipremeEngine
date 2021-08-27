/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module debugging.gui;

public struct DebugName{string name;}
public struct InterfaceImplementation{void function(ref void* u_data) interfaceFunc;}

version(CIMGUI):
import bindbc.cimgui;
import bindbc.sdl;
import error.handler;
import implementations.imgui.imgui_impl_opengl3;
import implementations.imgui.imgui_impl_sdl;


/**
* This class wraps ImGUI initialization only (currently) for easier mantaining
*/
public class DebugInterface
{
    private this(){}
    public static bool start(SDL_Window* window)
    {
        DebugInterface i = new DebugInterface();
        _inst = i;
        auto ctx = igCreateContext(null);
        ErrorHandler.startListeningForErrors("ImGUI start");
        ErrorHandler.assertErrorMessage(ctx != null, "ImGUI Error", "Could not create context");
        igSetCurrentContext(ctx);
        i.io = igGetIO();
        i.io.DisplaySize.x = 1280;
        i.io.DisplaySize.y = 720;
        i.io.DeltaTime = 1f / 60f;
        static if(CIMGUI_VIEWPORT_BRANCH)
        {
            i.io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
            //i.io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;           // Enable Docking
            i.io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;         // Enable Multi-Viewport / Platform Windows
        }
        
        i.window = window;
        import global.assets;
        
        ErrorHandler.assertErrorMessage(ImGui_ImplSDL2_InitForOpenGL(window, SDL_GL_GetCurrentContext()),
        "ImGUI Error", "Error Initializing SDL implementation");
        ErrorHandler.assertErrorMessage(ImGui_ImplOpenGL3_Init(""), 
        "ImGUI Error", "Error initializing OpenGL implementation");
        return ErrorHandler.stopListeningForErrors();
    }

    public static ImFontConfig getDefaultFontConfig(char[40] fontName)
    {
        ImFontConfig cfg;
        cfg.PixelSnapH = true;
        cfg.SizePixels = 13;
        cfg.FontDataOwnedByAtlas = true;
        cfg.GlyphOffset.x = 0;
        cfg.GlyphOffset.y = 0;
        cfg.GlyphExtraSpacing.x = 0;
        cfg.GlyphExtraSpacing.y = 0;
        cfg.GlyphMaxAdvanceX = igGET_FLT_MAX();
        cfg.GlyphMinAdvanceX = 0;
        cfg.OversampleH = 1;
        cfg.OversampleV = 1;
        cfg.RasterizerMultiply = 1;
        cfg.RasterizerFlags = 0;
        cfg.Name = fontName;
        return cfg;
    }

    public static ImFontConfig mergeFont(string fontName, float fontSize, ImWchar* range, char[40] resultName)
    {
        ImFontConfig cfg = getDefaultFontConfig(resultName);
        cfg.MergeMode = true;
        ImFontAtlas_AddFontFromFileTTF(_inst.io.Fonts, fontName.ptr, fontSize, &cfg, range);
        ImFontAtlas_Build(_inst.io.Fonts);
        return cfg;
    }
    public static ImFontConfig* mergeFont(string fontName, float fontSize, ImWchar* range, ImFontConfig* config)
    {
        config.MergeMode = true;
        ImFontAtlas_AddFontFromFileTTF(_inst.io.Fonts, fontName.ptr, fontSize, config, range);
        ImFontAtlas_Build(_inst.io.Fonts);
        return config;
    }

 
    public static void begin()
    {
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplSDL2_NewFrame(_inst.window);
        igNewFrame();
    }
    public static void update(SDL_Event* e)
    {
        ImGui_ImplSDL2_ProcessEvent(e);
    }

    public static void end()
    {
        static if(!CIMGUI_VIEWPORT_BRANCH)
            igEndFrame();
        igRender();
        ImGui_ImplOpenGL3_RenderDrawData(igGetDrawData());

        static if(CIMGUI_VIEWPORT_BRANCH)
        {
            if (_inst.io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
            {
                SDL_Window* backup_current_window = SDL_GL_GetCurrentWindow();
                SDL_GLContext backup_current_context = SDL_GL_GetCurrentContext();
                igUpdatePlatformWindows();
                igRenderPlatformWindowsDefault(null,null);
                SDL_GL_MakeCurrent(backup_current_window, backup_current_context);
            }
            
        }
    }
    public static void onDestroy()
    {
        if(_inst !is null)
        {
            ImGui_ImplOpenGL3_Shutdown();
            ImGui_ImplSDL2_Shutdown();
            igDestroyContext(igGetCurrentContext());
        }
    }
    public static enum MAX_COMBOBOX_HEIGHT = 8;
    private static DebugInterface _inst;
    public SDL_Window* window;
    public ImGuiIO* io;
}

/**
* DebugInterface alias
*/
export alias DI = DebugInterface;