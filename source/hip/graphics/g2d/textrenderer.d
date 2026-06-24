/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d.textrenderer;
import hip.game.mesh;
import hip.game.shader;
import hip.game.vertex;
import hip.math.matrix;
import hip.api.data.font;
import hip.assetmanager;
import hip.graphics.g2d;
public import hip.api.graphics.text : HipTextAlign, Size;

/**
*   This class oculd be refactored in the future to actually
* use a spritebatch for its drawing.
*/
class HipTextRenderer
{
    IHipFont font;
    IHipFont usedFont;
    HipSpriteBatch batch;
    HipColor color = HipColor.white;
    ubyte[] buffer;
    bool shouldRenderLineBreak, shouldRenderSpace;

    this(HipSpriteBatch batch, bool shouldRenderLineBreak = false, bool shouldRenderSpace = false)
    {
        import hip.global.gamedef;
        import hip.math.utils;
        import hip.util.array;
        this.batch = batch;
        this.shouldRenderLineBreak = shouldRenderLineBreak;
        this.shouldRenderSpace = shouldRenderSpace;
        //Promise it won't modify
        setFont(cast(IHipFont)HipDefaultAssets.font);
        buffer = uninitializedArray!(ubyte[])(getClosestMultiple(batch.isInstanced ? HipSpriteVertexInstancedPerInstance.sizeof : HipSpriteVertex.sizeof, ushort.max+1));
    }

    void setFont(IHipFont font)
    {
        this.font = font;
    }
    void setColor(HipColor color)
    {
        this.color = color;
    }
    /**
     * Implementation for unchanging text.
     *  The text will be saved, represented as an internal ID to a managed static HipText. Which means the texture will be baked
     *  so it is possible to actually draw it a lot faster as all the preprocessings are done once.
     */
    void draw(string str, int x, int y, float scale = 1, HipTextAlign align_ = HipTextAlign.centerLeft, Size bounds = Size.init, bool wordWrap = false)
    {
        import hip.api.graphics.text;

        int width, height;
        ushort slot;
        //TODO: THIS IS DONT SET AUTOMATICALLY TEXTURE SLOTS.
        IHipTexture tex = font.getTexture;
        // this.batch.setTexture(tex, width, height, slot);
        int offsetCount = putTextVertices(
            font, buffer, str, x, y, 1, color, scale, align_, bounds, wordWrap, shouldRenderSpace, this.batch.isInstanced(), 0);
        batch.draw(tex, buffer[0..offsetCount], true);
    }

    void bufferDraw(ubyte[] buffer, IHipFont font)
    {
        batch.draw(font.getTexture(), buffer, true);
    }
    
}