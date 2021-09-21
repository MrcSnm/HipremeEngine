
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
public import hipengine.api.math.vector;

import hipengine.internal;
public import hipengine.internal:initializeHip;


void function(string s) log;
void initConsole()
{
    loadSymbol!log;
}

//version(Script)
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
void function(ref IHipSprite sprite) destroySprite;
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