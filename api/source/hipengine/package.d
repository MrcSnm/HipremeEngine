
module hipengine;
// version (HipremeAudio)
// {
// 	public import hipaudio;
// }
// version (HipremeRenderer)
// {
// 	public import hiprenderer;
// }
version (HipremeG2D)
{
	public import hipengine.api.graphics.color;
	public import hipengine.api.renderer.texture;
	public import hipengine.api.graphics.g2d.hipsprite;
}
public import hipengine.api.data.image;
public import hipengine.api.graphics.color;
public import hipengine.api.renderer.texture;
public import hipengine.api.graphics.g2d.hipsprite;
public import hipengine.api.view;


void function(string s) log;
void initConsole()
{
    import core.sys.windows.windows;
    log = cast(typeof(log))GetProcAddress(GetModuleHandle(null), "log\0".ptr);
}


void function() beginSprite;
void function() endSprite;
void function() beginGeometry;
void function() endGeometry;
void function(HipColor color) setGeometryColor;
void function(int x, int y) drawPixel;
void function(int x, int y, int w, int h) drawRectangle;
void function(int x1, int y1, int x2, int y2, int x3, int y3) drawTriangle;
void function(int x1, int y1, int x2, int y2) drawLine;
void function(IHipSprite sprite) drawSprite;
IHipSprite function(string texturePath) newSprite;


void initG2D()
{
	import core.sys.windows.windows;
	void* lh = GetModuleHandle(null);
	beginSprite = cast(typeof(beginSprite))GetProcAddress(lh, "beginSprite");
	endSprite = cast(typeof(endSprite))GetProcAddress(lh, "endSprite");
	beginGeometry = cast(typeof(beginGeometry))GetProcAddress(lh, "beginGeometry");
	endGeometry = cast(typeof(endGeometry))GetProcAddress(lh, "endGeometry");
	setGeometryColor = cast(typeof(setGeometryColor))GetProcAddress(lh, "setGeometryColor");
	drawPixel = cast(typeof(drawPixel))GetProcAddress(lh, "drawPixel");
	drawRectangle = cast(typeof(drawRectangle))GetProcAddress(lh, "drawRectangle");
	drawTriangle = cast(typeof(drawTriangle))GetProcAddress(lh, "drawTriangle");
	drawLine = cast(typeof(drawLine))GetProcAddress(lh, "drawLine");
	drawSprite = cast(typeof(drawSprite))GetProcAddress(lh, "drawSprite");
	newSprite = cast(typeof(newSprite))GetProcAddress(lh, "newSprite");
}