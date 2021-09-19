// D import file generated from 'source\hiprenderer\renderer.d'
module hiprenderer.renderer;
public import hiprenderer.config;
public import hiprenderer.shader;
public import hiprenderer.texture;
public import hiprenderer.vertex;
import hiprenderer.framebuffer;
import hiprenderer.viewport;
import math.rect;
import error.handler;
import bindbc.sdl;
import console.log;
import core.stdc.stdlib : exit;
public import hiprenderer.backend.gl.renderer;
version (Windows)
{
	import hiprenderer.backend.d3d.renderer;
	import hiprenderer.backend.d3d.texture;
}
import hiprenderer.backend.gl.texture;
import hiprenderer.backend.sdl.texture;
enum HipWindowMode 
{
	WINDOWED,
	FULLSCREEN,
	BORDERLESS_FULLSCREEN,
}
enum HipRendererType 
{
	GL3,
	D3D11,
	SDL,
	NONE,
}
enum HipRendererMode 
{
	POINT,
	LINE,
	LINE_STRIP,
	TRIANGLES,
	TRIANGLE_STRIP,
}
enum HipBlendFunction 
{
	ZERO,
	ONE,
	SRC_COLOR,
	ONE_MINUS_SRC_COLOR,
	DST_COLOR,
	ONE_MINUS_DST_COLOR,
	SRC_ALPHA,
	ONE_MINUS_SRC_ALPHA,
	DST_ALPHA,
	ONE_MINUST_DST_ALPHA,
	CONSTANT_COLOR,
	ONE_MINUS_CONSTANT_COLOR,
	CONSTANT_ALPHA,
	ONE_MINUS_CONSTANT_ALPHA,
}
enum HipBlendEquation 
{
	ADD,
	SUBTRACT,
	REVERSE_SUBTRACT,
	MIN,
	MAX,
}
interface IHipRendererImpl
{
	public bool init(SDL_Window* window, SDL_Renderer* renderer);
	version (dll)
	{
		public bool initExternal();
	}
	public bool isRowMajor();
	public SDL_Window* createWindow(uint width, uint height);
	public SDL_Renderer* createRenderer(SDL_Window* window);
	public Shader createShader();
	public IHipFrameBuffer createFrameBuffer(int width, int height);
	public IHipVertexArrayImpl createVertexArray();
	public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage);
	public IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage);
	public int queryMaxSupportedPixelShaderTextures();
	public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
	public void setViewport(Viewport v);
	public bool setWindowMode(HipWindowMode mode);
	public bool hasErrorOccurred(out string err, string line = __FILE__, int line = __LINE__);
	public void begin();
	public void setRendererMode(HipRendererMode mode);
	public void drawIndexed(index_t count, uint offset = 0);
	public void drawVertices(index_t count, uint offset = 0);
	public void end();
	public void clear();
	public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
	public void fillRect(int x, int y, int width, int height);
	public void drawRect(int x, int y, int w, int h);
	public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	public void drawLine(int x1, int y1, int x2, int y2);
	public void drawPixel(int x, int y);
	public void draw(Texture t, int x, int y);
	public void draw(Texture t, int x, int y, SDL_Rect* rect);
	public void dispose();
}
class HipRenderer
{
	static struct Statistics
	{
		ulong drawCalls;
	}
	__gshared 
	{
		protected static Viewport currentViewport = null;
		protected static Viewport mainViewport = null;
		protected static IHipRendererImpl rendererImpl;
		protected Statistics stats;
		public static SDL_Renderer* renderer = null;
		public static SDL_Window* window = null;
		public static Shader currentShader;
		package static HipRendererType rendererType = HipRendererType.NONE;
		public 
		{
			static uint width;
			static uint height;
		}
		protected static HipRendererConfig currentConfig;
		public static bool init(string confPath);
		version (dll)
		{
			public static bool initExternal(HipRendererType type);
		}
		private static afterInit()
		{
			mainViewport = new Viewport(0, 0, 800, 600);
			setViewport(mainViewport);
			HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
		}
		public static bool init(IHipRendererImpl impl, HipRendererConfig* config, uint width, uint height);
		public static HipRendererType getRendererType();
		public static HipRendererConfig getCurrentConfig();
		public static int getMaxSupportedShaderTextures();
		public static ITexture getTextureImplementation();
		public static void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
		public static Viewport getCurrentViewport();
		public static void setViewport(Viewport v);
		public static T getMatrix(T)(ref T mat)
		{
			if (currentConfig.isMatrixRowMajor && !rendererImpl.isRowMajor())
				return mat.transpose();
			return mat;
		}
		public static Shader newShader(HipShaderPresets shaderPreset = HipShaderPresets.DEFAULT);
		public static Shader newShader(string vertexShader, string fragmentShader);
		public static HipFrameBuffer newFrameBuffer(int width, int height, Shader frameBufferShader = null);
		public static IHipVertexArrayImpl createVertexArray();
		public static IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage);
		public static IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage);
		public static void setShader(Shader s);
		public static bool hasErrorOccurred(out string err, string file = __FILE__, int line = __LINE__);
		public static void exitOnError(string file = __FILE__, int line = __LINE__);
		public static void begin();
		public static void setRendererMode(HipRendererMode mode);
		public static void drawIndexed(index_t count, uint offset = 0);
		public static void drawIndexed(HipRendererMode mode, index_t count, uint offset = 0);
		public static void drawVertices(index_t count, uint offset = 0);
		public static void drawVertices(HipRendererMode mode, index_t count, uint offset = 0);
		public static void end();
		public static void clear();
		public static void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
		public static void fillRect(int x, int y, int width, int height);
		public static void draw(Texture t, int x, int y);
		public static void draw(Texture t, int x, int y, SDL_Rect* rect);
		public static void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
		public static void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
		public static void drawRect(int x, int y, int w, int h);
		public static void drawLine(int x1, int y1, int x2, int y2);
		public static void drawPixel(int x, int y);
		public static void dispose();
	}
}
