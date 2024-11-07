/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.framebuffer;
import hip.hiprenderer.shader;
import hip.hiprenderer.renderer;
import hip.api.renderer.texture;
public import hip.api.renderer.framebuffer;



class HipFrameBuffer : IHipFrameBuffer
{
    Shader currentShader;
    protected IHipFrameBuffer impl;
    int width, height;
    this(IHipFrameBuffer fbImpl, int width, int height, Shader framebufferShader = null)
    {
        import hip.hiprenderer.initializer;
        impl = fbImpl;
        this.width = width;
        this.height = height;
        if(framebufferShader is null)
            currentShader = newShader(HipShaderPresets.FRAME_BUFFER);
    }
    void create(uint width, uint height){}
    void resize(uint width, uint height){}

    void bind()
    {
        this.impl.bind();
    }
    void unbind()
    {
        this.impl.unbind();
    }
    void clear()
    {
        this.impl.clear();
    }
    IHipTexture getTexture(){return impl.getTexture();}

    void draw()
    {
        currentShader.bind();
        impl.draw();
    }

    void dispose(){impl.dispose();}

}


package const float[24] framebufferVertices = //X, Y, S, T
[
    //First Quad
    //Top Left
    -1.0, -1.0, 0.0, 0.0,

    //Top Right
    1.0, -1.0, 1.0, 0.0,

    //Bot Right
    1.0, 1.0, 1.0, 1.0,

    //Second quad

    //Bot Right
    1.0, 1.0, 1.0, 1.0,

    //Bot Left
    -1.0, 1.0, 0.0, 1.0,

    //Top Left
    -1.0, -1.0, 0.0, 0.0
];