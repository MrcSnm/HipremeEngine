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



interface IHipFrameBuffer
{
    ///Creates the framebuffer using the target width and height
    void create(uint width, uint height);

    ///Resizes the framebuffer, probably this will not be implemented in the backend level
    void resize(uint width, uint height);

    ///Binds the framebuffer, setting it as a target for every draw call
    void bind();
    ///Unbinds the framebuffer, resetting the renderer state and setting the output as the screen
    void unbind();
    ///Must draw the framebuffer content
    void draw();

    ///Clears the current framebuffer content
    void clear();

    ///Gets the texture containing the framebuffer data
    IHipTexture getTexture();

    void dispose();
}

class HipFrameBuffer : IHipFrameBuffer
{
    Shader currentShader;
    protected IHipFrameBuffer impl;
    int width, height;
    this(IHipFrameBuffer fbImpl, int width, int height, Shader framebufferShader = null)
    {
        impl = fbImpl;
        this.width = width;
        this.height = height;
        if(framebufferShader is null)
            currentShader = HipRenderer.newShader(HipShaderPresets.FRAME_BUFFER);
    }
    void create(uint width, uint height){}
    void resize(uint width, uint height){}

    void bind()
    {
        this.impl.bind();
        HipRenderer.exitOnError();
    }
    void unbind()
    {
        this.impl.unbind();
        HipRenderer.exitOnError();
    }
    void clear()
    {
        this.impl.clear();
        HipRenderer.exitOnError();
    }
    IHipTexture getTexture(){return impl.getTexture();}

    void draw()
    {
        currentShader.bind();
        impl.draw();
        HipRenderer.exitOnError();
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