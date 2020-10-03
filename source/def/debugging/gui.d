module def.debugging.gui;
import bindbc.cimgui;
import bindbc.sdl : SDL_Window; 
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
        ErrorHandler.assertErrorMessage(ctx == null, "ImGUI Error", "Could not create context");
        igSetCurrentContext(ctx);
        i.io = igGetIO();
        i.io.DisplaySize.x = 1280;
        i.io.DisplaySize.y = 720;
        i.io.DeltaTime = 1f / 60f;
        i.window = window;

        ErrorHandler.assertErrorMessage(!ImGui_ImplOpenGL3_Init(""), 
        "ImGUI Error", "Error initializing OpenGL implementation");
        ErrorHandler.assertErrorMessage(!ImGui_ImplSDL2_Init(window),
        "ImGUI Error", "Error Initializing SDL implementation");
        return ErrorHandler.stopListeningForErrors();
    }

 
    public static void update()
    {
        ImGui_ImplOpenGL3_NewFrame();
        igNewFrame();
        ImGui_ImplSDL2_NewFrame(_inst.window);
    }

    public static void render()
    {
        igEndFrame();
        igRender();
        ImGui_ImplOpenGL3_RenderDrawData(igGetDrawData());
    }
    public static void onDestroy()
    {
        ImGui_ImplOpenGL3_Shutdown();
        ImGui_ImplSDL2_Shutdown();
        igDestroyContext(igGetCurrentContext());
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