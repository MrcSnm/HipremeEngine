
module hiprenderer.backend.gl.renderer;
import hiprenderer.renderer;
import hiprenderer.framebuffer;
import hiprenderer.shader;
import hiprenderer.backend.gl.framebuffer;
import hiprenderer.backend.gl.shader;
import hiprenderer.viewport;
import math.rect;
import console.log;
import bindbc.sdl;
import bindbc.opengl;

private SDL_Window* createSDL_GL_Window(uint width, uint height);
class Hip_GL3Renderer : IHipRendererImpl
{
	SDL_Window* window;
	SDL_Renderer* renderer;
	Shader currentShader;
	protected static bool isGLBlendEnabled = false;
	protected static GLenum mode;
	public final bool isRowMajor();
	SDL_Window* createWindow(uint width, uint height);
	SDL_Renderer* createRenderer(SDL_Window* window);
	Shader createShader();
	public bool init(SDL_Window* window, SDL_Renderer* renderer);
	version (dll)
	{
		public bool initExternal();
	}
	void setShader(Shader s);
	public int queryMaxSupportedPixelShaderTextures();
	public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
	public IHipFrameBuffer createFrameBuffer(int width, int height);
	public IHipVertexArrayImpl createVertexArray();
	public IHipVertexBufferImpl createVertexBuffer(ulong size, HipBufferUsage usage);
	public IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage);
	public void setViewport(Viewport v);
	public bool setWindowMode(HipWindowMode mode);
	public bool hasErrorOccurred(out string err, string file = __FILE__, int line = __LINE__);
	public void begin();
	public void end();
	public void draw(Texture t, int x, int y);
	public void draw(Texture t, int x, int y, SDL_Rect* clip = null);
	pragma (inline, true)public void clear();
	public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255);
	protected GLenum getGLRendererMode(HipRendererMode mode);
	protected GLenum getGLBlendFunction(HipBlendFunction func);
	protected GLenum getGLBlendEquation(HipBlendEquation eq);
	public void setRendererMode(HipRendererMode mode);
	public void drawVertices(index_t count, uint offset);
	public void drawIndexed(index_t indicesCount, uint offset = 0);
	public void setBlendFunction(HipBlendFunction src, HipBlendFunction dst);
	public void setBlendingEquation(HipBlendEquation eq);
	public void drawRect();
	public void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	public void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	public void drawRect(int x, int y, int w, int h);
	public void fillRect(int x, int y, int width, int height);
	public void drawLine(int x1, int y1, int x2, int y2);
	public void drawPixel(int x, int y);
	public void dispose();
}
