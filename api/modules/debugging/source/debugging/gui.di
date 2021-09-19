// D import file generated from 'source\debugging\gui.d'
module debugging.gui;
public struct DebugName
{
	string name;
}
public struct InterfaceImplementation
{
	void function(ref void* u_data) interfaceFunc;
}
version (CIMGUI)
{
	import bindbc.cimgui;
	import bindbc.sdl;
	import error.handler;
	import implementations.imgui.imgui_impl_opengl3;
	import implementations.imgui.imgui_impl_sdl;
	public class DebugInterface
	{
		private this()
		{
		}
		public static bool start(SDL_Window* window);
		public static ImFontConfig getDefaultFontConfig(char[40] fontName);
		public static ImFontConfig mergeFont(string fontName, float fontSize, ImWchar* range, char[40] resultName);
		public static ImFontConfig* mergeFont(string fontName, float fontSize, ImWchar* range, ImFontConfig* config);
		public static void begin();
		public static void update(SDL_Event* e);
		public static void end();
		public static void onDestroy();
		public static enum MAX_COMBOBOX_HEIGHT = 8;
		private static DebugInterface _inst;
		public SDL_Window* window;
		public ImGuiIO* io;
	}
	export alias DI = DebugInterface;
}
