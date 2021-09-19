// D import file generated from 'source\hiprenderer\backend\d3d\renderer.d'
module hiprenderer.backend.d3d.renderer;
version (Windows)
{
	pragma (lib, "ole32");
	pragma (lib, "user32");
	pragma (lib, "d3dcompiler");
	pragma (lib, "d3d11");
	pragma (lib, "dxgi");
	import core.stdc.string;
	import core.sys.windows.windows;
	import std.conv : to;
	import directx.d3d11;
	import bindbc.sdl;
	import config.opts;
	import error.handler;
	import hiprenderer.shader;
	import hiprenderer.texture;
	import hiprenderer.viewport;
	import hiprenderer.renderer;
	import hiprenderer.framebuffer;
	import hiprenderer.backend.d3d.shader;
	import hiprenderer.backend.d3d.framebuffer;
	import hiprenderer.backend.d3d.vertex;
	import hiprenderer.backend.d3d.utils;
	ID3D11Device _hip_d3d_device = null;
	ID3D11DeviceContext _hip_d3d_context = null;
	IDXGISwapChain _hip_d3d_swapChain = null;
	ID3D11RenderTargetView _hip_d3d_mainRenderTarget = null;
	class Hip_D3D11_Renderer : IHipRendererImpl
	{
		public static SDL_Renderer* renderer = null;
		public static SDL_Window* window = null;
		protected static bool hasDebugAvailable;
		protected static Viewport currentViewport;
		public static Shader currentShader;
		static if (HIP_DEBUG)
		{
			import directx.dxgidebug;
			IDXGIInfoQueue dxgiQueue;
		}
		public SDL_Window* createWindow(uint width, uint height);
		protected void initD3D(HWND hwnd, HipRendererConfig* config);
		public void setState();
		public final bool isRowMajor();
		public SDL_Renderer* createRenderer(SDL_Window* window);
		public bool hasErrorOccurred(out string err, string file = __FILE__, int line = __LINE__);
		public bool setWindowMode(HipWindowMode mode);
		public IHipFrameBuffer createFrameBuffer(int width, int height);
		public IHipVertexArrayImpl createVertexArray();
		public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage);
		public IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage);
		public Shader createShader();
		public bool init(SDL_Window* window, SDL_Renderer* renderer);
		version (dll)
		{
			public bool initExternal();
		}
		public int queryMaxSupportedPixelShaderTextures();
		public void setRendererMode(HipRendererMode mode);
		public void setViewport(Viewport v);
		void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
		void setShader(Shader s);
		void begin();
		void end();
		public void drawVertices(index_t count, uint offset = 0);
		public void drawIndexed(index_t indicesSize, uint offset = 0);
		public void drawRect();
		public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
		public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
		public void drawRect(int x, int y, int w, int h);
		public void draw(Texture t, int x, int y);
		public void draw(Texture t, int x, int y, SDL_Rect* rect);
		public void fillRect(int x, int y, int width, int height);
		public void drawLine(int x1, int y1, int x2, int y2);
		public void drawPixel(int x, int y);
		void clear();
		void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
		public void dispose();
	}
	private void Hip_D3D11_Dispose();
}
