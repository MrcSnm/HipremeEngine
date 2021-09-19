// D import file generated from 'source\imgui\imgui_impl_sdl.d'
module imgui.imgui_impl_sdl;
version (CIMGUI)
{
	enum CIMGUI_USER_DEFINED_IMPLEMENTATION = true;
	import bindbc.sdl;
	static if (CIMGUI_USER_DEFINED_IMPLEMENTATION)
	{
		import bindbc.cimgui;
		import core.stdc.string : memset, strncpy, strncmp;
		version (Windows)
		{
			static if (CIMGUI_VIEWPORT_BRANCH)
			{
				pragma (lib, "user32");
				import core.sys.windows.windows : GetWindowLong, LONG, HWND, SetWindowLong, ShowWindow, SW_SHOWNA, GWL_EXSTYLE, WS_EX_APPWINDOW, WS_EX_TOOLWINDOW;
			}
		}
		enum SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE = sdlSupport >= SDLSupport.sdl204;
		enum SDL_HAS_WINDOW_ALPHA = sdlSupport >= SDLSupport.sdl205;
		enum SDL_HAS_ALWAYS_ON_TOP = sdlSupport >= SDLSupport.sdl205;
		enum SDL_HAS_USABLE_DISPLAY_BOUNDS = sdlSupport >= SDLSupport.sdl205;
		enum SDL_HAS_PER_MONITOR_DPI = sdlSupport >= SDLSupport.sdl204;
		enum SDL_HAS_VULKAN = sdlSupport >= SDLSupport.sdl206;
		enum SDL_HAS_MOUSE_FOCUS_CLICKTHROUGH = sdlSupport >= SDLSupport.sdl205;
		static if (!SDL_HAS_VULKAN)
		{
			static const Uint32 SDL_WINDOW_VULKAN = 268435456;
		}
		static SDL_Window* g_Window = null;
		static Uint64 g_Time = 0;
		static bool[3] g_MousePressed = [false, false, false];
		static SDL_Cursor*[ImGuiMouseCursor_COUNT] g_MouseCursors;
		static char* g_ClipboardTextData = null;
		static bool g_MouseCanUseGlobalState = true;
		enum g_UseVulkan = false;
		enum MAP_BUTTON_SDL(ImGuiIO* io, SDL_GameController* game_controller, ulong NAV_NO, SDL_GameControllerButton BUTTON_NO)
		{
			io.NavInputs[NAV_NO] = SDL_GameControllerGetButton(game_controller, BUTTON_NO) != 0 ? 1.0F : 0.0F;
		}
		enum MAP_ANALOG_SDL(ImGuiIO* io, SDL_GameController* game_controller, ulong NAV_NO, SDL_GameControllerAxis AXIS_NO, int V0, int V1)
		{
			float vn = cast(float)(SDL_GameControllerGetAxis(game_controller, AXIS_NO) - V0) / cast(float)(V1 - V0);
			if (vn > 1.0F)
				vn = 1.0F;
			if (vn > 0.0F && (io.NavInputs[NAV_NO] < vn))
				io.NavInputs[NAV_NO] = vn;
		}
		enum thumb_dead_zone = 8000;
		extern (C) static const(char)* ImGui_ImplSDL2_GetClipboardText(void*);
		extern (C) static void ImGui_ImplSDL2_SetClipboardText(void*, const char* text);
		bool ImGui_ImplSDL2_ProcessEvent(const SDL_Event* event);
		static bool ImGui_ImplSDL2_Init(SDL_Window* window, void* sdl_gl_context);
		bool ImGui_ImplSDL2_InitForOpenGL(SDL_Window* window, void* sdl_gl_context);
		bool ImGui_ImplSDL2_InitForVulkan(SDL_Window* window);
		bool ImGui_ImplSDL2_InitForD3D(SDL_Window* window);
		bool ImGui_ImplSDL2_InitForMetal(SDL_Window* window);
		void ImGui_ImplSDL2_Shutdown();
		static void ImGui_ImplSDL2_UpdateMousePosAndButtons();
		static void ImGui_ImplSDL2_UpdateMouseCursor();
		static void ImGui_ImplSDL2_UpdateGamepads();
		void ImGui_ImplSDL2_NewFrame(SDL_Window* window);
		static if (CIMGUI_VIEWPORT_BRANCH)
		{
			static void ImGui_ImplSDL2_UpdateMonitors();
			extern (C) struct ImGuiViewportDataSDL2
			{
				SDL_Window* Window;
				Uint32 WindowID;
				bool WindowOwned;
				SDL_GLContext GLContext;
			}
			extern (C) static void ImGui_ImplSDL2_CreateWindow(ImGuiViewport* viewport);
			extern (C) static void ImGui_ImplSDL2_DestroyWindow(ImGuiViewport* viewport);
			extern (C) static void ImGui_ImplSDL2_ShowWindow(ImGuiViewport* viewport);
			extern (C) static void ImGui_ImplSDL2_GetWindowPos(ImGuiViewport* viewport, ImVec2* _out_vec);
			extern (C) static void ImGui_ImplSDL2_SetWindowPos(ImGuiViewport* viewport, ImVec2 pos);
			extern (C) static void ImGui_ImplSDL2_GetWindowSize(ImGuiViewport* viewport, ImVec2* _out_vec);
			extern (C) static void ImGui_ImplSDL2_SetWindowSize(ImGuiViewport* viewport, ImVec2 size);
			extern (C) static void ImGui_ImplSDL2_SetWindowTitle(ImGuiViewport* viewport, const(char)* title);
			static if (SDL_HAS_WINDOW_ALPHA)
			{
				extern (C) static void ImGui_ImplSDL2_SetWindowAlpha(ImGuiViewport* viewport, float alpha);
			}
			extern (C) static void ImGui_ImplSDL2_SetWindowFocus(ImGuiViewport* viewport);
			extern (C) static bool ImGui_ImplSDL2_GetWindowFocus(ImGuiViewport* viewport);
			extern (C) static bool ImGui_ImplSDL2_GetWindowMinimized(ImGuiViewport* viewport);
			extern (C) static void ImGui_ImplSDL2_RenderWindow(ImGuiViewport* viewport, void*);
			extern (C) static void ImGui_ImplSDL2_SwapBuffers(ImGuiViewport* viewport, void*);
			static if (SDL_HAS_VULKAN && g_UseVulkan)
			{
				import bindbc.vulkan;
				extern (C) static int ImGui_ImplSDL2_CreateVkSurface(ImGuiViewport* viewport, ImU64 vk_instance, const void* vk_allocator, ImU64* out_vk_surface);
			}
			extern (C) static void ImGui_ImplSDL2_InitPlatformInterface(SDL_Window* window, void* sdl_gl_context);
			static void ImGui_ImplSDL2_ShutdownPlatformInterface();
		}
	}
	else
	{
		import bindbc.loader : SharedLib, bindSymbol;
		extern (C) nothrow @nogc 
		{
			alias pImGui_ImplSDL2_InitForOpenGL = bool function(SDL_Window* window, void* sdl_gl_context);
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
		void bindSDLImgui(SharedLib lib);
	}
}
