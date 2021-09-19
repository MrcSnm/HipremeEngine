// D import file generated from 'source\hiprenderer\backend\sdl\sdlrenderer.d'
module hiprenderer.backend.sdl.sdlrenderer;
import hiprenderer.backend.sdl.texture;
import hiprenderer.renderer;
import hiprenderer.framebuffer;
import hiprenderer.viewport;
import math.rect;
import error.handler;
import bindbc.sdl;
import bindbc.opengl;
import console.log;
private SDL_Window* createSDL_GL_Window(uint width, uint height);
public class Hip_SDL_Renderer : IHipRendererImpl
{
	private Viewport currentViewport = null;
	private Viewport mainViewport = null;
	public SDL_Renderer* renderer = null;
	public SDL_Window* window = null;
	SDL_Window* createWindow(uint width, uint height);
	public final bool isRowMajor();
	SDL_Renderer* createRenderer(SDL_Window* window);
	public bool init(SDL_Window* window, SDL_Renderer* renderer);
	version (dll)
	{
		public bool initExternal();
	}
	Shader createShader();
	public IHipFrameBuffer createFrameBuffer(int width, int height);
	public IHipVertexArrayImpl createVertexArray();
	public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage);
	public IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage);
	public bool setWindowMode(HipWindowMode mode);
	public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
	public Viewport getCurrentViewport();
	public void setViewport(Viewport v);
	public bool hasErrorOccurred(out string err, string file = __FILE__, int line = __LINE__);
	public int queryMaxSupportedPixelShaderTextures();
	public void draw(Texture t, int x, int y);
	public void draw(Texture t, int x, int y, SDL_Rect* clip = null);
	public void begin();
	public void setRendererMode(HipRendererMode mode);
	public void drawIndexed(index_t count, uint offset = 0);
	public void drawVertices(index_t count, uint offset = 0);
	pragma (inline, true)public void end();
	public void clear();
	pragma (inline, true)public void clear(ubyte r, ubyte g, ubyte b, ubyte a);
	public void fillRect(int x, int y, int width, int height);
	public void drawRect(int x, int y, int width, int height);
	public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	public void drawLine(int x1, int y1, int x2, int y2);
	public void drawPixel(int x, int y);
	public void dispose();
}
