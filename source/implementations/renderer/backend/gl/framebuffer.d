module implementations.renderer.backend.gl.framebuffer;
import bindbc.opengl;
import error.handler;
import implementations.renderer.shader;

private const float[24] vertices = //X, Y, S, T
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

class HipGLFrameBuffer
{
    uint vao;
    uint vbo;
    uint rbo;
    uint fbo;
    uint texture;
    

    this(int width, int height)
    {
        //Objects initialization
        glGenFramebuffers(1, &this.fbo);
        glGenVertexArrays(1, &this.vao);
        glGenBuffers(1, &this.vbo);
        glGenRenderbuffers(1, &this.rbo);
        glGenTextures(1, &this.texture);

        //VAO and VBO initialization
        glBindVertexArray(this.vao);
        glBindBuffer(GL_ARRAY_BUFFER, this.vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, vertices.ptr, GL_DYNAMIC_DRAW);
        glVertexAttribPointer(0, 2, GL_FLOAT, false, 4*float.sizeof, null); //XY
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1, 2, GL_FLOAT, false, 4*float.sizeof, cast(void*)(2*float.sizeof)); //ST
        glEnableVertexAttribArray(1);

        //Texture initialization
        glBindFramebuffer(GL_FRAMEBUFFER, this.fbo);
        glBindTexture(GL_TEXTURE_2D, this.texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        //Attach to the framebuffer
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, this.texture, 0);

        //Render buffer initialization
        glBindRenderbuffer(GL_RENDERBUFFER, this.rbo);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, this.rbo);

        //Check if creation went successful

        ErrorHandler.assertErrorMessage(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE,
        "GL Framebuffer creation", "Framebuffer was unable to complete its creations");

        //Reset to defaults
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindTexture(GL_TEXTURE_2D, 0);
        glBindVertexArray(0);
    }

    void dispose()
    {
        glDeleteBuffers(1, &this.vbo);
        glDeleteVertexArrays(1, &this.vao);
        glDeleteTextures(1, &this.texture);
        glDeleteFramebuffers(1, &this.fbo);
        glDeleteRenderbuffers(1, &this.rbo);
    }
}