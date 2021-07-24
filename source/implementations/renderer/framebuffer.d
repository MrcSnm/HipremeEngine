module implementations.renderer.framebuffer;
import implementations.renderer.shader;
import implementations.renderer.renderer;



interface IHipFrameBuffer
{
    ///Binds the framebuffer, setting it as a target for every draw call
    void bind();
    ///Unbinds the framebuffer, resetting the renderer state and setting the output as the screen
    void unbind();
    ///Must draw the framebuffer content
    void draw();

    ///Clears the current framebuffer content
    void clear();

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

    void bind(){this.impl.bind();}
    void unbind(){this.impl.unbind();}
    void clear(){this.impl.clear();}

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