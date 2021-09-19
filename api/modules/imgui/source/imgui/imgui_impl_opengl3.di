// D import file generated from 'source\imgui\imgui_impl_opengl3.d'
module imgui.imgui_impl_opengl3;
version (CIMGUI)
{
	import bindbc.cimgui;
	import std.conv : to;
	import core.stdc.stdio;
	import core.stdc.string;
	import core.stdc.stdint : intptr_t;
	enum CIMGUI_USER_DEFINED_GL = true;
	enum _MSC_VER = -1;
	enum IMGUI_IMPL_OPENGL_ES2 = false;
	enum GL_VERSION_3_2 = false;
	enum GL_VERSION_3_3 = false;
	enum IMGUI_IMPL_OPENGL_ES3 = false;
	enum IMGUI_IMPL_OPENGL_MAY_HAVE_BIND_SAMPLER = false;
	enum IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET = false;
	static if (CIMGUI_USER_DEFINED_GL)
	{
		static if (IMGUI_IMPL_OPENGL_ES2)
		{
		}
		else
		{
			static if (IMGUI_IMPL_OPENGL_ES3)
			{
			}
			else
			{
				import bindbc.opengl;
			}
		}
		static if (!IMGUI_IMPL_OPENGL_ES2 && !IMGUI_IMPL_OPENGL_ES3 && GL_VERSION_3_2)
		{
			enum IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET = true;
		}
		static if (!IMGUI_IMPL_OPENGL_ES2 && !IMGUI_IMPL_OPENGL_ES3 && GL_VERSION_3_3)
		{
			enum IMGUI_IMPL_OPENGL_MAY_HAVE_BIND_SAMPLER = true;
		}
		static GLuint g_GlVersion = 0;
		static char[32] g_GlslVersionString;
		static GLuint g_FontTexture = 0;
		static GLuint g_ShaderHandle = 0;
		static GLuint g_VertHandle = 0;
		static GLuint g_FragHandle = 0;
		static GLint g_AttribLocationTex = 0;
		static GLint g_AttribLocationProjMtx = 0;
		static GLuint g_AttribLocationVtxPos = 0;
		static GLuint g_AttribLocationVtxUV = 0;
		static GLuint g_AttribLocationVtxColor = 0;
		static uint g_VboHandle = 0;
		static uint g_ElementsHandle = 0;
		bool ImGui_ImplOpenGL3_Init(const(char)* glsl_version);
		void ImGui_ImplOpenGL3_Shutdown();
		void ImGui_ImplOpenGL3_NewFrame();
		static void ImGui_ImplOpenGL3_SetupRenderState(ImDrawData* draw_data, int fb_width, int fb_height, GLuint vertex_array_object);
		void ImGui_ImplOpenGL3_RenderDrawData(ImDrawData* draw_data);
		bool ImGui_ImplOpenGL3_CreateFontsTexture();
		void ImGui_ImplOpenGL3_DestroyFontsTexture();
		static bool CheckShader(GLuint handle, const(char)* desc);
		static bool CheckProgram(GLuint handle, const(char)* desc);
		bool ImGui_ImplOpenGL3_CreateDeviceObjects();
		void ImGui_ImplOpenGL3_DestroyDeviceObjects();
		extern (C) static void ImGui_ImplOpenGL3_RenderWindow(ImGuiViewport* viewport, void*);
		static void ImGui_ImplOpenGL3_InitPlatformInterface();
		static void ImGui_ImplOpenGL3_ShutdownPlatformInterface();
	}
	else
	{
		extern (C) nothrow @nogc 
		{
			alias pImGui_ImplOpenGL3_Init = bool function(const(char)* glsl_version);
			alias pImGui_ImplOpenGL3_Shutdown = void function();
			alias pImGui_ImplOpenGL3_NewFrame = void function();
			alias pImGui_ImplOpenGL3_RenderDrawData = void function(ImDrawData* draw_data);
			alias pImGui_ImplOpenGL3_CreateFontsTexture = bool function();
			alias pImGui_ImplOpenGL3_DestroyFontsTexture = void function();
			alias pImGui_ImplOpenGL3_CreateDeviceObjects = bool function();
			alias pImGui_ImplOpenGL3_DestroyDeviceObjects = void function();
		}
		__gshared 
		{
			pImGui_ImplOpenGL3_Init ImGui_ImplOpenGL3_Init;
			pImGui_ImplOpenGL3_Shutdown ImGui_ImplOpenGL3_Shutdown;
			pImGui_ImplOpenGL3_NewFrame ImGui_ImplOpenGL3_NewFrame;
			pImGui_ImplOpenGL3_RenderDrawData ImGui_ImplOpenGL3_RenderDrawData;
			pImGui_ImplOpenGL3_CreateFontsTexture ImGui_ImplOpenGL3_CreateFontsTexture;
			pImGui_ImplOpenGL3_DestroyFontsTexture ImGui_ImplOpenGL3_DestroyFontsTexture;
			pImGui_ImplOpenGL3_CreateDeviceObjects ImGui_ImplOpenGL3_CreateDeviceObjects;
			pImGui_ImplOpenGL3_DestroyDeviceObjects ImGui_ImplOpenGL3_DestroyDeviceObjects;
		}
		import bindbc.loader : SharedLib, bindSymbol;
		void bindGLImgui(SharedLib lib);
	}
}
