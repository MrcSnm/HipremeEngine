module graphics.g2d.sprite;
import bindbc.sdl;
import math.rect;
import implementations.renderer.renderer;
import implementations.imgui.imgui_debug;
import graphics.texture;
import graphics.color;
import graphics.abstraction.transformable;

@InterfaceImplementation(function(ref void* data)
{
    import bindbc.cimgui;
    Sprite* s = cast(Sprite*)data;

    igBeginGroup();
    igSliderInt2("Position", &s.x, -1000, 1000,  null, 0);
    igSliderFloat2("Scale", &s.scaleX, -1, 1000,  null, 0);
    igSliderFloat("Rotation", cast(float*)&s.rotation, 0, 360, null, 0);
    igEndGroup();

})public class Sprite
{
    bool dirty;
    Color color;
    Texture texture;
    Rect region;
    mixin Positionable;
    mixin Rotationable;
    mixin Scalable;

    this(Texture t)
    {
        texture = t;
        color = White;
        region = t.getBounds();
        import std.stdio;
        writeln(color.r, color.g, color.b);
    }

    void draw()
    {
        SDL_SetTextureColorMod(texture.data, color.r,color.g,color.b);
        SDL_SetTextureAlphaMod(texture.data, color.a);
        HipRenderer.draw(texture, x, y, &region);
    }
}