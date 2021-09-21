
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

//View + graphics
public import hipengine.api.data.image;
public import hipengine.api.graphics.color;
public import hipengine.api.renderer.texture;
public import hipengine.api.graphics.g2d.hipsprite;
public import hipengine.api.view;


//Math
public import hipengine.api.math;

import hipengine.internal;
public import hipengine.internal:initializeHip;


void function(string s) log;
void initConsole()
{
    loadSymbol!log;
}

//version(Script)
extern(C) void function() beginSprite;
extern(C) void function() endSprite;
extern(C) void function() beginGeometry;
extern(C) void function() endGeometry;
extern(C) void function(HipColor color) setGeometryColor;
extern(C) void function(int x, int y) drawPixel;
extern(C) void function(int x, int y, int w, int h) drawRectangle;
extern(C) void function(int x1, int y1, int x2, int y2, int x3, int y3) drawTriangle;
extern(C) void function(int x1, int y1, int x2, int y2) drawLine;
extern(C) void function(IHipSprite sprite) drawSprite;
extern(C) IHipSprite function(string texturePath) newSprite;
extern(C) void function(ref IHipSprite sprite) destroySprite;
//else version(ReleaseMode)
//import graphics.g2d.renderer2d;


void initG2D()
{
	loadSymbol!beginSprite;
	loadSymbol!endSprite;
	loadSymbol!beginGeometry;
	loadSymbol!endGeometry;
	loadSymbol!setGeometryColor;
	loadSymbol!drawPixel;
	loadSymbol!drawRectangle;
	loadSymbol!drawTriangle;
	loadSymbol!drawLine;
	loadSymbol!drawSprite;
	loadSymbol!newSprite;
	loadSymbol!destroySprite;
}