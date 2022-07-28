/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.gl.glframebuffer;

import hip.error.handler;
import hip.hiprenderer.renderer;
import hip.hiprenderer.framebuffer;
import hip.hiprenderer.shader;
import hip.hiprenderer.backend.gl.gltexture;


class Hip_GL3_FrameBuffer : IHipFrameBuffer
{
    ///Texture to be returned. It is filled with the opengl framebuffer contents
    Hip_GL3_Texture retTexture;
    uint rbo;
    uint fbo;
    uint texture;
    

    this(int width, int height)
    {
        create(width, height);
    }
    void create(uint width, uint height)
    {
        //Objects initialization
        glGenFramebuffers(1, &this.fbo);
        glGenRenderbuffers(1, &this.rbo);
        glGenTextures(1, &this.texture);

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

        version(HipGL3)
        {
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, this.rbo);
        }
        else
        {
            glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, this.rbo);
        }


        //Check if creation went successful

        ErrorHandler.assertErrorMessage(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE,
        "GL Framebuffer creation", "Framebuffer was unable to complete its creations");
        retTexture = new Hip_GL3_Texture();
        retTexture.textureID = texture;

        //Reset to defaults
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    void resize(uint width, uint height){}

    void bind(){glBindFramebuffer(GL_FRAMEBUFFER, this.fbo);}
    void unbind(){glBindFramebuffer(GL_FRAMEBUFFER, 0);}
    void clear()
    {
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    ITexture getTexture(){return retTexture;}

    void draw()
    {
        // glBindTexture(GL_TEXTURE_2D, this.texture);
        // glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    void dispose()
    {
        glDeleteTextures(1, &this.texture);
        glDeleteFramebuffers(1, &this.fbo);
        glDeleteRenderbuffers(1, &this.rbo);
    }
}