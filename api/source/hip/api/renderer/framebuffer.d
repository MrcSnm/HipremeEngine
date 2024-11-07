module hip.api.renderer.framebuffer;
public import hip.api.renderer.texture;

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